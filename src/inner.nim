import htmlgen, markdown, strutils, os, times
include db

proc updatePosts(): void =
  for f in walkFiles("posts/*.md"):
    let
      md = readFile(f)
      html = markdown(md)
      id = parseInt(f[6..^4])
      old = findPost(id)
    if old.id == -1:
      echo "PRE Attepting adding new post #", id
      echo "New post title: "
      let title = readLine(stdin)
      let res = addPost(
        Post(
          id: id,
          title: title,
          post: html,
          date: getDateStr()
        )
      )
      if res == -1:
        echo "Failed to add new post #", id
        quit()
    elif old.post != html:
      echo "PRE Updating post #", id
      updatePost(id, html)

proc header(dark: bool = false): string =
  head(
    title("Codewatch"),
    link(rel="icon", href="/favicon.png"),
    link(rel="stylesheet", type="text/css", href="/css/style.css")
  )

proc top(): string =
  `div`(id="logo",
    h1(a(href="/", "Codewatch"))
  )

proc index(): string =
  var recent: string
  for p in recentPosts():
    recent &= li(span(class="timestamp", p.date) & " " & a(href = "/blog/" & $(p.id), p.title))
  html(
    header(),
    body(
      top(),
      `div`(id="content",
        `div`(id="left",
          h1("About Me"),
          p("Hi, I'm Benjamin. I enjoy woodworking, fiddling with music, and designing software."),
          h1("Contact"),
          p(
            "If you need to get in contact with me, you can ",
            a(href="mailto:benji@codewat.ch", "shoot me an email"), "."
          ),
          p(
            "To follow my projects, connect with me on ",
            a(href="https://www.linkedin.com/in/benjamin-frady", img(src="/icons/linkedin.svg", alt="", width="16px", class="icon"), "Linkedin"),
            " or browse the projects that I put on ",
            a(href="https://github.com/ijneb", img(src="/icons/github.svg", alt="", width="16px", class="icon"), "GitHub"), "."
          )
        ),
        `div`(id="right",
          h1("Recent Posts"),
          ul(recent),
          a(href="/list", "Click for full list")
        )
      )
    )
  )

proc error(msg: string): string =
  html(
    header(),
    body(
      top(),
      `div`(id="content",
        h1(msg)
      )
    )
  )

proc list(): string =
  var posts: string
  for p in getPosts():
    posts &= li(span(class="timestamp", p.date) & " " & a(href = "/blog/" & $(p.id), p.title))
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
            h1(p.title),
            img(src="/icons/clock.svg", alt="", width="14px", class="icon"),
            span(class="timestamp", style="margin-top:2px; margin-left:2px;", p.date),
            p.post
          )
        )
      )
  else: result = error("Page not found")
