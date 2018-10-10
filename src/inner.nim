import htmlgen
include db

proc header(): string =
  head(
    title("Codewatch"),
    link(rel="stylesheet", type="text/css", href="/css/style.css")
  )

proc top(): string =
  `div`(id="logo",
    h1(a(href="/", "Codewatch"))
  )

proc index(): string =
  var recent: string
  for p in recentPosts():
    recent &= li(p.date & ": " & a(href = "/blog/" & $(p.id), p.title))
  html(
    header(),
    body(
      top(),
      `div`(id="content",
        `div`(id="left",
          h1("Contact Me"),
          ul(li("Discord: benji#4364"), li("XMPP: benji@wusz.org")),
          h1("About Me"),
          p("I'm a hobbyist woodworker, a capricious musician, and an autodidactic lover of mathematics and physics who is working towards computational solutions.")
        ),
        `div`(id="right",
          h1("Recent Posts"),
          ul(recent),
          a(href="/list", "(Click for full list)")
        )
      )
    )
  )

proc list(): string =
  var posts: string
  for p in getPosts():
    posts &= li(p.date & ": " & a(href = "/blog/" & $(p.id), p.title))
  html(
    header(),
    body(
      top(),
      `div`(id="content",
        h1("All Posts"),
        ul(posts)
      )
    )
  )

proc blog(post: int): string =
  let
    p: Post = findPost(post)
  if p.title != "":
    result =
      html(
        header(),
        body(
          top(),
          `div`(id="content",
            p.post
          )
        )
      )
  else:
    result =
      html(
        header(),
        body(
          top(),
          `div`(id="content",
            h1("Not found")
          )
        )
      )
