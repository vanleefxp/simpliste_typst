#import "./src/lib.typ" as bib-fox: custom-bib-refs, bib-from-data
#import "@preview/linkify:0.1.0"
#import "@preview/elembic:1.1.1" as e
#import linkify.display: bili

#show: custom-bib-refs
#show: e.show_(
  bib-fox.bib-ref-number,
  super,
)

#let wagner = arguments(uid: 434773406, "sheepherder_wagner")
#let charon = arguments(uid: 24037897, "charon_studio")

_How to Become a Human_ is a series of videos by #bili(..wagner) from Bilibili. It teaches aliens, AI, and doppelgangers how to blend into human society. The techniques taught in the videos range from walking@walk, eating@eat, to breathing@breath and sleeping. Actually, this kind of videos has its origin in an earlier video entitled _How to Distinguish between Shiba Inu and Bread_@dog-bread by #bili(..charon).

== Bibliography

#bib-from-data(
  (
    label: <walk>,
    title: [How to Walk Like a Human],
    id: "14g4y1574R",
    author: wagner,
  ),
  (
    label: <eat>,
    title:[How to Eat Like a Human],
    id: "1pa4y157Bh",
    author: wagner,
  ),
  (
    label: <breath>,
    title: [How to Breath Like a Human],
    id: "14o4y137gE",
    author: wagner
  ),
  (
    label: <dog-bread>,
    title: [How to Distinguish between Shiba Inu and Bread],
    id: "1is4y1d7nA",
    author: charon,
    extra: [Probably the first video of AI-oriented tutorials on Bilibili.]
  ),
  display: data => {
    let (title, id, author) = data
    if "extra" in data { data.extra }
    [
      - #title
      - #bili(id)
      - by #bili(..author)
    ]
  },
)