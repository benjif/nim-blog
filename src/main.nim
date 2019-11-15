import jester, re, strutils
include inner

updatePosts()

routes:
  get "/":
    resp index()
  get re"^\/blog\/(\d)$":
    if len(request.matches) > 0:
      resp blog(parseInt(request.matches[0]))
  get "/tag/@tag":
    if @"tag" == "":
      resp error("Page not found")
    else:
      let isalphanum =
        all(mapIt(@"tag", it), proc(c: char): bool = isAlphaNumeric(c))
      if isalphanum:
        resp tag(@"tag")
      else:
        resp(error("Invalid tag"))
  get "/list":
    resp list()
  get "/links":
    resp links()
  error Http404:
    resp Http404, error("Page not found")
  error Exception:
    resp Http500, error("Something went wrong")

closeDb()
