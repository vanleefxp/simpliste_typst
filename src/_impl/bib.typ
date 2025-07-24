#import "@preview/elembic:1.1.1" as e
#import "./ref.typ": st_ref-labels, st_backrefs, bib-number, bib-ref-number, bib-backref
#import "./list.typ": inline-list
#import "./utils.typ": dict-sep, is-empty-content
#import "./init.typ": debug-box-stroke

#let space = [ ].func()
#let sequence = [a *b*].func()
#let mod = calc.rem-euclid

#let bib-list = e.element.declare(
  "bib-list",
  prefix: "bib-fox",
  fields: (
    e.field(
      "body",
      content,
      required: true,
      named: false,
    ),
    e.field(
      "block",
      bool,
      default: false,
      named: true,
    ),
    e.field(
      "separator",
      e.types.option(e.types.union(str, content, symbol)),
      default: [, ],
      named: true,
    ),
    e.field(
      "backref",
      bool,
      default: true,
      named: true,
    ),
    e.field(
      "backref-prefix",
      e.types.option(e.types.union(content, str, symbol, dictionary)),
      default: (inline: h(0.125em), block: h(1fr)),
      named: false,
    ),
    e.field(
      "backref-sep",
      e.types.option(e.types.union(str, content, symbol)),
      default: h(0.125em),
      named: false,
    )
  ),
  allow-unknown-fields: true,
  display: el => {
    let ((body, block, separator, backref, backref-prefix, backref-sep), args) = dict-sep(
      e.fields(el),
      "body", "block", "separator", "backref", "backref-prefix", "backref-sep"
    )
    if type(backref-prefix) == dictionary {
      backref-prefix = if block { backref-prefix.block } else { backref-prefix.inline }
    }
    assert.eq(body.func(), sequence)
    let (bib-number-args, args) = dict-sep(args, "numbering")

    let terms-items = body.children.filter(
      it => (
        it.func() == terms.item and
        type(it.term) == content and
        it.term.func() == text
      )
    )
    let labels = terms-items.map(it => label(it.term.text))
    let enum-items = terms-items.zip(labels).enumerate().map(
      ((i, (terms-item, label))) => {
        enum.item(
          i,
          {
            terms-item.description
            if backref {
              let backref-count = st_backrefs
                .final()
                .at(str(label), default: 0)
              if backref-count > 0 {
                backref-prefix
                range(backref-count)
                  .map(i => bib-backref(label, i))
                  .join(backref-sep)
              }
            }
          }
        )
      }
    )
    let res = enum(
      numbering: i => {
        bib-number(
          label: labels.at(i),
          ..bib-number-args,
        )
      },
      ..enum-items,
      ..args,
    )
    if not block { res = inline-list(res) }
    res
  }
)

#let separate-sequence-helper(contents) = {
  let parts = ()
  let part = ()
  let last-is-list-item = false
  let fn

  // group consecutive `terms.item`s together
  for it in contents {
    fn = it.func()
    if fn == space {
      if not last-is-list-item { part.push(it) }
      continue
    }
    if last-is-list-item != (fn == list.item) {
      parts.push((
        contents: part,
        is-columns: last-is-list-item
      ))
      part = ()
    }
    if fn == list.item {
      part.push(it.body)
    } else {
      part.push(it)
    }
    last-is-list-item = fn == list.item
  }

  // add non-empty last part
  if part.len() > 0 {
    parts.push((
      contents: part,
      is-columns: last-is-list-item
    ))
  }

  // remove empty first part
  let first-part = parts.at(0)
  if (
    first-part.contents.len() == 0 or
    first-part.contents.all(is-empty-content)
  ) {
    parts = parts.slice(1)
  }

  parts
}

#let separate-sequence(children) = {
  let result = children
    .split(parbreak())
    .map(separate-sequence-helper)
    .join()
  result
}

#let bib-entries = e.element.declare(
  "bib-entries",
  prefix: "bib-fox",
  fields: (
    e.field(
      "body",
      content,
      required: true,
      named: false,
    ),
    e.field(
      "align",
      e.types.smart(
        e.types.union(
          alignment,
          function,
          e.types.array(e.types.smart(alignment))
        )
      ),
      named: true,
    ),
    e.field(
      "number-align",
      e.types.smart(alignment),
      named: true,
      default: end,
    ),
    e.field(
      "body-indent",
      length,
      named: true,
      default: 0.5em,
    ),
    e.field(
      "column-gutter",
      e.types.union(length, e.types.array(length)),
      named: true,
      default: 1em,
    ),
    e.field(
      "backref",
      bool,
      default: true,
      named: true,
    ),
    e.field(
      "backref-prefix",
      e.types.option(e.types.union(content, str, symbol)),
      default: h(1fr),
      named: false,
    ),
    e.field(
      "backref-sep",
      e.types.option(e.types.union(str, content, symbol)),
      default: h(0.125em),
      named: false,
    ),
    e.field(
      "debug",
      bool,
      default: false,
      named: true
    )
  ),
  allow-unknown-fields: true,
  display: el => {
    let (body, align, number-align, body-indent, column-gutter, backref, backref-prefix, backref-sep, debug) = e.fields(el)
    assert.eq(body.func(), sequence)
    let terms-items = body.children.filter(
      it => (
        it.func() == terms.item and
        type(it.term) == content and
        it.term.func() == text
      )
    )
    let labels = terms-items.map(it => label(it.term.text))
    let items = terms-items.map(it => {
      let desc = it.description
      if desc.func() == sequence {
        separate-sequence(it.description.children)
      } else {
        ((contents: (desc,), is-columns: false),)
      }
    })

    let has-backref-col = false
    let backref-col-min-width = 0pt
    if backref {
      let backref-counts = st_backrefs.final()
      for (i, label) in labels.enumerate()  {
        let backref-count = backref-counts.at(str(label), default: 0)
        if backref-count > 0 {
          let backref-content = range(backref-count)
            .map(j => bib-backref(label, j))
            .join(backref-sep)
          let last-line = items.at(i).pop()
          if last-line.is-columns {
            has-backref-col = true
            last-line.contents.push(
              grid.cell(
                backref-prefix + backref-content,
                // align: end,
                colspan: 2,
              )
            )
            backref-col-min-width = calc.max(measure(backref-content).width, backref-col-min-width)
          } else {
            last-line.contents.push(backref-prefix)
            last-line.contents.push(backref-content)
          }
          items.at(i).push(last-line)
        }
      }
    }

    let n-columns = calc.max(
      ..items
        .join()
        .filter(((is-columns,)) => is-columns)
        .map(((contents,)) => contents.len()),
      1 // ensure there is at least one item
    )

    let cells = ()
    for (label, item) in labels.zip(items) {
      for (i, line) in item.enumerate() {
        cells.push(
          if i == 0 { bib-number(label: label) }
          else { [] }
        )
        if line.is-columns {
          cells += line.contents
          let line-n-columns = line.contents.len()
          if line-n-columns < n-columns {
            cells += ([],) * (n-columns - line-n-columns + if has-backref-col { 1 } else { 0 })
          }
        } else {
          cells.push(grid.cell(line.contents.join(), colspan: if has-backref-col { 1 } else { 0 } + n-columns))
        }
      }
    }

    column-gutter = if type(column-gutter) == array {
      column-gutter
    } else if type(column-gutter) == function {
      range(n-columns - 1).map(i => column-gutter(i))
    } else {
      (column-gutter,) * (n-columns - 1)
    }

    grid(
      ..cells,
      columns: if has-backref-col {
        (auto,) * n-columns + (1fr, backref-col-min-width)
      } else {
        (auto,) * (n-columns + 1)
      },
      row-gutter: par.leading,
      column-gutter: (body-indent,) + column-gutter + (0pt,),
      align: (i, j) => {
        if (i == 0) { number-align } else {
          if type(align) == function {
            align(i - 1)
          } else if type(align) == array {
            align.at(mod(i - 1, align.len()))
          } else {
            align
          }
        }
      },
      stroke: if debug { debug-box-stroke },
    )
  },
  doc: "A multi-column version of `bib-list`. Displays nicely-aligned information of bibliography items in multiple columns.",
)
