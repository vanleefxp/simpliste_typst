# Typst Package: `simpliste`

`simplist` is a package that provides you with customized list styles.

## Inline Lists

Sometimes you want to use numbered or unnumbered lists to display a sequence of simple items that you don't want the items to be separated into different lines, then you may use the `inline-list` function provided by `simpliste` to create an inline-style list. Compared to manually writing the numbers, using this `inline-list` makes more sense semantically and can adapt to the insertion and deletion of items.

```typst
#import "@preview/simpliste:0.1.0": inline-list

There are three basic mechanisms of heat transfer, which are #inline-list[
    + thermal conduction
    + thermal convection
    + thermal radiation
].

The three basic parameters of a musical tone are its #inline-list[
    - pitch
    - volume
    - timbre
].
```

## Aligned Terms Lists

Typst by default displays terms lists by inserting a fixed amount of space between term and its definition and applying a hanging indent to the rest lines of the definition. This causes the starting of term definition texts not being aligned. `simpliste` provides an `aligned-terms` function that allows you to create neatly aligned term lists. You can even use a `show` rule to make it the default style for `terms`.

```typst
#import "@preview/simpliste:0.1.0"
#show terms: aligned-terms

/ Ligature: A merged glyph.
/ Kerning: A spacing adjustment between two adjacent letters.
/ Character Advance: The size of the character in the direction the text flows, which refers to the character width in horizontal writing mode, or character hight in vertical writing mode.
```

The default behavior of `aligned-terms` takes the longest term text's width as the width of the left-side term column, and the definitions are aligned in the right-side column. However when some terns in the list are considerably longer than others, you may specify a fixed width for the terms column using the `hanging-indent` parameter. This allows overly long terms to intrude into the definitions text, which conforms to Typst's default layout behavior of a `terms` item.

```typst
#import "@preview/simpliste:0.1.0"
#show terms: aligned-terms.with(hanging-indent: 4em)

/ Ligature: A merged glyph.
/ Kerning: A spacing adjustment between two adjacent letters.
/ Character Advance: The size of the character in the direction the text flows, which refers to the character width in horizontal writing mode, or character hight in vertical writing mode.
```

# `simpliste.bib`: Customized Bibliography Display Style

The `bib` submodule of `simpliste` allows you to create customized bibliography display style as an alternative to Typst's default `bibliography` function. It gives you full access to every detail of how your bibliography is displayed. This package can be useful when your writing is not a journal essay and you don't want to make the bibliography list look too formal.

With this package, you can use `ref` to reference your custom bibliography items, when the following `show` rule is applied:

```typst
#import "@preview/simpliste:0.1.0"
#import simpliste.bib: custom-bib-refs

#show: custom-bib-refs
```

`simpliste.bib` provides two main bibliography formats: the `bib-list` which displays bibliography as a numbered list, and `bib-entries`, which displays different fields of a bibliography item in neatly-aligned columns. The package automatically numbers the bibliography items in the order you write them and can create a "backref" link at the end of each item that leads you back to where the item is referenced.

To write a bibliography list, just wrap a `terms` list inside the `bib-list` function. The "term" of the `terms` list should be a string that can become a Typst `label` which will allow you to refer to the items with.

```typst
#import "@preview/simpliste:0.1.0"
#import simpliste.bib: bib-list

To blend in to human society, you need to be familiar with the behavior of humans, such as walking@walk, eating@eat, breathing@breathe and sleeping. If you exhibit abnormal behavior, your alien's identity is very likely to be discovered.

#bib-list[
    / walk : How to Walk Like a Human
    / eat: How to Eat Like a Human
    / breathe: How to Breathe Like a Human
    / bread-dog: How to Distinguish between Shiba Inu and Bread
]
```


