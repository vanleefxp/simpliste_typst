#import "@preview/elembic:1.1.1" as e
#import "./list.typ": inline-list
#import "./utils.typ": dict-sep, is-empty-content, content2str
#import "./init.typ": debug-box-stroke

#let space = [ ].func()
#let sequence = [a *b*].func()
#let mod = calc.rem-euclid

#let st_ref-labels = state("simpliste.bib.ref-labels", (:))
#let backref-counter-name-prefix = "__simpliste.backref"

#let bib-number = e.element.declare(
  "bib-number",
  prefix: "simpliste.bib",
  fields: (
    e.field(
      "numbering",
      e.types.union(str, function),
      default: "[1]",
    ),
  ),
  display: el => {
    let (numbering, label) = el
    st_ref-labels.update(value => {
      let label = str(label)
      value.insert(label, true)
      value
    })
    sym.zwj
    std.numbering(numbering, ..e.counter(el).get())
  },
)

#let bib-ref-number = e.element.declare(
  "bib-ref-number",
  prefix: "simpliste.bib",
  fields: (
    e.field(
      "target",
      e.types.union(str, label),
      required: true,
    ),
    e.field(
      "numbering",
      e.types.union(str, function),
      default: "[1]",
    ),
  ),
  display: el => {
    let (target, numbering) = el
    if type(target) == str {
      target = label(target)
    }
    let backref-counter = counter(backref-counter-name-prefix + "_" + str(target))
    let backref-count = backref-counter.get().at(0)

    let backref-label = std.label(
      "__simpliste.backref" + "_" + str(target) + "_" + str(backref-count)
    )

    backref-counter.step()

    [#link(
      target,
      std.numbering(numbering, ..e.counter(bib-number).at(target))
    )#backref-label]
  }
)

#let bib-backref = e.element.declare(
  "bib-backref",
  prefix: "simpliste.bib.ref",
  fields: (
    e.field(
      "target",
      e.types.union(str, label),
      required: true,
      named: false,
    ),
    e.field(
      "index",
      int,
      default: 0,
      required: false,
      named: false,
    ),
    e.field(
      "mark",
      e.types.union(str, content, symbol),
      named: true,
      default: sym.arrow.l.hook,
    ),
  ),
  display: el => {
    let (target, index, mark) = e.fields(el)
    assert(index >= 0)
    if type(target) == label {
      target = str(target)
    }
    let label = std.label("__simpliste.backref" + "_" + target + "_" + str(index))
    link(label, mark)
  },
)

#let custom-bib-refs(body) = {
  show ref: it => {
    let target = it.target
    let ref-labels = st_ref-labels.final()
    if str(target) in ref-labels {
      bib-ref-number(target)
    } else { it }
  }
  body
}


#let bib-list = e.element.declare(
  "bib-list",
  prefix: "simpliste.bib",
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
      it => it.func() == terms.item
    )
    let labels = terms-items.map(it => label(content2str(it.term)))
    let enum-items = terms-items.zip(labels).enumerate().map(
      ((i, (terms-item, label))) => {
        enum.item(
          i,
          {
            terms-item.description
            if backref {
              let backref-count = counter(backref-counter-name-prefix + "_" + str(label)).get().at(0)
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
  prefix: "simpliste.bib",
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
    // assert.eq(body.func(), sequence)
    let terms-items = if body.func() == sequence {
      body.children
      .filter(it => it.func() == terms.item)
    } else if body.func() == terms.item {
      (body,)
    } else {
      panic("Unsupported content type")
    }
    let labels = terms-items.map(it => label(content2str(it.term)))
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
      for (i, label) in labels.enumerate()  {
        let backref-count = counter(backref-counter-name-prefix + "_" + str(label)).get().at(0)
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
        (auto,) * n-columns + (1fr,)
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

#let bib-from-data(
  ..args,
  display: none,
  kind: "entries"
) = {
  assert.eq(type(display), function, message: "A data display function must be specified. It should be a function that takes an entry's data as input argument")
  let data = args.pos()
  let kwargs = args.named()
  let fn = if kind == "list" { bib-list } else { bib-entries }
  fn(
    for entry-data in data {
      assert("label" in entry-data)
      let label = entry-data.label
      if type(label) == std.label {
        label = str(label)
      }
      assert.eq(type(label), str)
      terms.item(label, display(entry-data))
    },
    ..kwargs,
  )
}
