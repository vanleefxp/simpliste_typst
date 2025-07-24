#import "@preview/elembic:1.1.1" as e
#import "src/lib.typ" as bib-fox: custom-bib-refs, bib-list, bib-entries
#import bib-fox.list: inline-list

#show: custom-bib-refs
#set par(justify: true)
#set text(font: "New Computer Modern")
#show raw: set text(font: "New Computer Modern Mono", size: 10pt)
#show: e.show_(
  inline-list,
  it => {
    set enum(body-indent: 0.125em)
    set list(body-indent: 0.125em)
    it
  },
)
#show: e.show_(
  bib-fox.ref.bib-backref,
  it => {
    // use math font for the backref arrow symbol
    // The symbol is missing in text font
    set text(font: "New Computer Modern Math")
    it
  }
)

lorem ipsum@bib2 dolor@bib1 sit@bib6 amet@c #lorem(10)@bib1 #lorem(20)@bib5@bib11

#lorem(100)

== Bibliography

#bib-list(block: true)[
  / bib1: #lorem(20)
  / bib2: #lorem(30)
  / bib3: #lorem(10)
  / bib4: #lorem(15)
  / bib5: #lorem(50)
]

Something

#bib-list(block: true)[
  / bib6: #lorem(5)
  / bib7: #lorem(10)
  / bib8: #lorem(10)
  / bib9: #lorem(15)
  / bib10: #lorem(5)
]

Something: #bib-list(block: false)[
  / bib11: Lorem
  / bib12: Ipsum
  / bib14: Dolor
  / bib15: Sit
  / bib16: Amet
]. etc.

#bib-entries[
  / a:
    - Lorem
    - Ipsum
    - Dolor
    - Sit
    - Amet

  / b:

    Something before #lorem(10) example text example text

    - Lorem
    - Ipsum
    - Dolor
    - Sit
    - Amet

    - Lorem
    - Ipsum
    - Dolor
    - Sit
    - Amet

    Something after

  / c: Simple *text* and something else #lorem(10)#footnote[and there can even be a footnote]

]