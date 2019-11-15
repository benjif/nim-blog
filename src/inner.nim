import htmlgen, markdown, strutils, os, times, uri
include db

proc updatePosts(): void =
  for f in walkFiles("posts/*.md"):
    let
      md = readFile(f)
      html = markdown(md)
      new_chksm = getMD5(html)
      id = parseInt(f[6..^4])
      old = findPost(id)
    if old.id == -1:
      echo "PRE Attempting adding new post #", id
      echo "New post title: "
      let title = readLine(stdin)
      echo "New post tags (comma separated): "
      let
        tags = readLine(stdin)
                .split(',')
                .map(proc(tag: string): string = tag.strip())
      let res = addPost(
        Post(
          id: id,
          title: title,
          post: html,
          date: getDateStr()
        )
      )
      for tag in tags:
        addPostTag(id, tag)
      if res == -1:
        echo "Failed to add new post #", id
        quit()
    elif old.chksm != new_chksm:
      echo "PRE Updating post #", id
      updatePost(id, html)

proc header(): string =
  head(
    title("Benjamin Frady"),
    link(rel="icon", href="/favicon.png"),
    link(rel="stylesheet", type="text/css", href="/css/style.css"),
    meta(name="viewport", content="width=device-width,height=device-height,initial-scale=1.0"),
    meta(name="author", content="Benjamin Frady")
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
  "<!DOCTYPE html>" &
  html(
    header(),
    body(lang="en",
      `div`(id="content",
        top(),
        `div`(id="right",
          h1("About Me"),
          p("Hi, I'm Benjamin Frady. I enjoy woodworking, fiddling with music, and designing software."),
          h1("Contact"),
          p(
            "If you'd like to get in contact with me, you can ",
            a(href="mailto:benjamin@frady.org", "shoot me an email"), ". My public projects can be found on ",
            a(href="https://github.com/benjif", img(src="/icons/github.svg", style="padding-right: 3px;", alt="", width="16px", class="icon"), "GitHub"), "."
          ),
          h1("Recent Posts"),
          ul(recentString),
        )
      )
    )
  )

proc error(msg: string): string =
  "<!DOCTYPE html>" &
  html(
    header(),
    body(lang="en",
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
  "<!DOCTYPE html>" &
  html(
    header(),
    body(lang="en",
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
    tags = getPostTags(post)
            .map(proc (tag: string): string = a(href="/tag/" & encodeUrl(tag), tag))
    tags_csv = if len(tags) > 0: tags.join(", ") else: "none"
  if p.title != "":
    result =
      "<!DOCTYPE html>" &
      html(
        header(),
        body(lang="en",
          `div`(id="content",
            top(),
            `div`(id="right",
              `div`(id="post",
                `div`(id="post-title", p.title),
                `div`(id="post-info",
                  `div`(class="tags", "tag(s): ", i(tags_csv)),
                  span(class="date", "created: ", i(p.date))
                ),
                p.post
              )
            )
          )
        )
      )
  else: result = error("Page not found")

proc tag(name: string): string =
  var
    taggedString: string
  let
    taggedPosts: seq[int] = getPostsWithTag(name)
  if len(taggedPosts) == 0:
    taggedString = li("No posts found with tag")
  else:
    for pid in taggedPosts:
      let
        p = findPost(pid)
      taggedString &= li(span(class="timestamp", p.date) & " " & a(href = "/blog/" & $(p.id), p.title))
  "<!DOCTYPE html>" &
  html(
    header(),
    body(lang="en",
      `div`(id="content",
        top(),
        `div`(id="right",
          h1("Posts"),
          ul(taggedString)
        )
      )
    )
  )

proc links(): string =
  "<!DOCTYPE html>" &
  html(
    header(),
    body(lang="en",
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
