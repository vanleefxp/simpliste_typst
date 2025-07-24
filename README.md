# Typst Package: `bib-fox`

`bib-fox` is a package that allows you to create customized bibliography display style as an alternative to Typst's default `bibliography` function. It gives you full access to every detail of how your bibliography is displayed. This package can be useful when your writing is not a journal essay and you just want to point your readers to some simple external materials and don't want to make it look too formal.

With this package, you can use `ref` to reference your custom bibliography items, when the following `show` rule is applied:

```typst
#import "@preview/bib-fox:0.1.0": custom-bib-refs
#show: custom-bib-refs
```

`bib-fox` provides two main bibliography formats: the `bib-list` which displays bibliography as a numbered list, and `bib-entries`, which displays different fields of a bibliography item in neatly-aligned columns.