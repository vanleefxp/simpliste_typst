#let dict-sep(m, ..args, ignore-non-exist: true) = {
  let removed = (:)
  let keys-to-remove = args.pos()
  for key in keys-to-remove {
    if key not in m and ignore-non-exist { continue }
    removed.insert(key, m.remove(key))
  }
  (removed, m)
}

#let space = [ ].func()

#let is-empty-content(it) = {
  (
    type(it) == content and
    (
      it == [] or
      {
        let fn = it.func()
        (
          fn == space or
          fn == parbreak or
          fn == linebreak
        )
      }
    )
  )
}
