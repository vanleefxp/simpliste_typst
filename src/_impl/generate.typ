#import "./bib.typ": bib-list, bib-entries

#let bib-from-data(
  ..args,
  display: none,
  kind: "entries"
) = {
  assert.eq(type(display), function, message: "A data display function must be specified. It should be a function that takes an entry's data as input argument")
  let data = args.pos()
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
    }
  )
}
