#let dict-sep(m, ..args, ignore-non-exist: true) = {
  let removed = (:)
  let keys-to-remove = args.pos()
  for key in keys-to-remove {
    if key not in m and ignore-non-exist { continue }
    removed.insert(key, m.remove(key))
  }
  (removed, m)
}

#let transpose(..args) = {
  let arrs = args.pos()
  if arrs.len() == 0 {
    return ()
  } else {
    arrs.at(0).zip(..arrs.slice(1))
  }
}

#let is-multi-line(content, width: auto) = {
  if type(width) != length { false }
  else {
    let (height: h1) = measure(content, width: width)
    let (height: h2) = measure(content)
    return h1 > h2
  }
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
