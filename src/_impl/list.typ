// MIT No Attribution
//
// Copyright (c) 2025 Pg Biel
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the "Software"), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// Target version: Typst v0.13
// (Check https://gist.github.com/PgBiel/c530ae8ac937469510ab382e03a6ba2b for the latest version)

#import "@preview/elembic:1.1.1" as e
#import "./utils.typ": dict-sep

#let inline-list = e.element.declare(
  "inline-list",
  prefix: "bib-fox.list",
  fields: (
    e.field(
      "body",
      content,
      required: true,
      named: false,
    ),
    e.field(
      "separator",
      e.types.option(e.types.union(content, str)),
      default: [; ],
      named: true,
    ),
  ),
  display: el => {
    let (body, separator) = e.fields(el)

    let enum-number = state("bib-fox.list.enum-number")
    show enum: it => context {
      let prev = enum-number.get()

      let reversed = it.at("reversed", default: false)
      let i = if it.start != auto { it.start + if reversed { 1 } else { -1 } } else if reversed { it.children.len() + 1 } else { 0 }

      let items = ()
      for item in it.children {
        let number = if item.at("number", default: none) != none {
          item.number
        } else if reversed { i - 1 }
        else { i + 1 }
        i = number // `array.map` cannot be used because we need to modify `i`
        let rendered-number = if it.full {
          [#numbering(it.numbering, ..prev, number)]
        } else {
          [#numbering(it.numbering, number)]
        }
        let body = {
          enum-number.update(prev => (..prev, number))
          item.body
          enum-number.update(((..prev, _)) => prev)
        }
        items.push(rendered-number + h(it.body-indent) + body)
      }

      items.join(separator)
    }

    let list-level = counter("bib-fox.list.list-level")
    show list: it => list-level.step() + context {
      let marker = [#if type(it.marker) == array {
        // Only read the level if necessary
        let level = list-level.get().first() - 1
        it.marker.at(calc.rem(level, it.marker.len()))
      } else if type(it.marker) == function {
        let level = list-level.get().first() - 1
        (it.marker)(level)
      } else {
        it.marker
      }]
      let marker-width = measure(marker).width

      it.children
      .map(item => marker + h(it.body-indent) + item.body)
      .join(separator)
    } + list-level.update(i => i - 1)

    body
  }
)
