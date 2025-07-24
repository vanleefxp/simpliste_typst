#import "@preview/elembic:1.1.1" as e

#let st_ref-labels = state("bib-fox.ref-labels", (:))
#let st_backrefs = state("bib-fox.backrefs", (:))
#let backref-prefix = "__bibfox.backref"

#let bib-number = e.element.declare(
  "bib-number",
  prefix: "bib-fox",
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
    std.numbering(numbering, ..e.counter(el).get())
  },
)

#let bib-ref-number = e.element.declare(
  "bib-ref-number",
  prefix: "bib-fox",
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
    let backref-count = st_backrefs.get().at(str(target), default: 0)
    st_backrefs.update(value => {
      value.insert(str(target), backref-count + 1)
      value
    })
    let backref-label = std.label(
      backref-prefix + "_" + str(target) + "_" + str(backref-count)
    )
    [#link(
      target,
      std.numbering(numbering, ..e.counter(bib-number).at(target))
    )#backref-label]
  }
)

#let bib-backref = e.element.declare(
  "bib-backref",
  prefix: "bib-fox.ref",
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
    let label = std.label(backref-prefix + "_" + target + "_" + str(index))
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
