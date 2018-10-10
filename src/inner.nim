import htmlgen
include db

proc header(): string =
  head(
    title("Codewatch"),
    link(rel="stylesheet", type="text/css", href="css/style.css")
  )

proc index(): string =
  html(
    header(),
    `div`(id="content",
      `div`(id="logo",
        h1(a(href="/", "Codewatch"))
      ),
      `div`(id="left",
        h1("Contact Me"),
        ul(li("Discord: benji#4364"), li("XMPP: benji@wusz.org")),
        h1("About Me"),
        p("I'm a hobbyist woodworker, a capricious musician, and an autodidactic lover of mathematics and physics who is working towards computational solutions.")
      ),
      `div`(id="right",
        h1("Recent Posts"),
        span(a(href="/list", "(Click for full list)"))
      )
    )
  )

proc blog(post: int): string =
  let
    post: Post = findPost(post)
  if post.title != "":
    result =
      html(
        header(),
        `div`(id="content",
          h1("Found")
        )
      )
  else:
    result =
      html(
        header(),
        `div`(id="content",
          h1("Not found")
        )
      )
