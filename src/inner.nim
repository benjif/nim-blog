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
      echo "PRE Attempting adding new post #", id
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
    title("Benjamin Frady"),
    meta(name="viewport", content="width=device-width,height=device-height,initial-scale=1.0"),
    link(rel="icon", href="/favicon.png"),
    link(rel="stylesheet", type="text/css", href="/css/style.css")
  )

proc top(): string =
  `div`(id="left",
    a(href="/",
      img(src="/images/frady.png", alt="", height="84")
    ),
    hr(),
    `div`(id="nav",
      ul(
        li(a(href="/list", "All Posts")),
        li(a(href="/links", "Find Me"))
      )
    )
  )

proc index(): string =
  var
    recentList: seq[Post] = recentPosts()
    recentString: string
  if len(recentList) == 0:
    recentString = li("Nothing here yet!")
  else:
    for p in recentList:
      recentString &= li(span(class="timestamp", p.date) & " " & a(href = "/blog/" & $(p.id), p.title))
  html(
    header(),
    body(
      `div`(id="content",
        top(),
        `div`(id="right",
          h1("About Me"),
          p("Hi, I'm Benjamin Frady. I enjoy woodworking, fiddling with music, and designing software."),
          h1("Contact"),
          p(
            "If you'd like to get in contact with me, you can ",
            a(href="mailto:benjamin@frady.org", "shoot me an email"), ". You can follow my public projects on ",
            a(href="https://github.com/benjif", img(src="/icons/github.svg", style="padding-right: 3px;", alt="", width="16px", class="icon"), "GitHub"), "."
          ),
          h1("Recent Posts"),
          ul(recentString),
        )
      )
    )
  )

proc error(msg: string): string =
  html(
    header(),
    body(
      `div`(id="content",
        top(),
        `div`(id="right", h1(msg))
      )
    )
  )

proc list(): string =
  var
    recentList: seq[Post] = recentPosts()
    recentString: string
  if len(recentList) == 0:
    recentString = li("Nothing here yet!")
  else:
    for p in recentList:
      recentString &= li(span(class="timestamp", p.date) & " " & a(href = "/blog/" & $(p.id), p.title))
  html(
    header(),
    body(
      `div`(id="content",
        top(),
        `div`(id="right",
          h1("All Posts"),
          ul(recentString)
        )
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
          `div`(id="content",
            top(),
            `div`(id="right",
              `div`(id="post",
                h1(class="post-title", p.title),
                span(class="date", p.date),
                p.post
              )
            )
          )
        )
      )
  else: result = error("Page not found")

proc links(): string =
  html(
    header(),
    body(
      `div`(id="content",
        top(),
        `div`(id="right",
          h1("Personal Links"),
          ul(
            li(
              a(href="https://github.com/benjif",
                img(src="/icons/github.svg", alt="", width="16px", class="icon"),
                "GitHub"
              )
            ),
            li(
              a(href="https://last.fm/user/benji_is_me",
                img(src="/icons/last-dot-fm.svg", alt="", width="16px", class="icon"),
                "Last.fm"
              )
            ),
            li(
              a(href="https://linkedin.com/in/benjamin-frady",
                img(src="/icons/linkedin.svg", alt="", width="16px", class="icon"),
                "LinkedIn"
              )
            ),
            li(
              a(href="https://news.ycombinator.com/user?id=benji_is_me",
                img(src="/icons/ycombinator.svg", alt="", width="16px", class="icon"),
                "HackerNews"
              )
            )
          )
        )
      )
    )
  )
