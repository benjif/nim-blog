import jester, re, strutils, uri
include inner

if updatePosts():
  updateRss()

routes:
  get "/":
    resp index()

  get re"^\/blog\/([1-9]\d*)$":
    if len(request.matches) > 0:
      resp blog(parseInt(request.matches[0]))

  get "/tag":
    resp tagList()

  get "/tag/@tag":
    if @"tag" == "":
      resp error("Page not found")
    else:
      let
        decoded = decodeUrl(@"tag")
        isalphanum =
          all(mapIt(decoded, it), proc(c: char): bool = isAlphaNumeric(c) or c == ' ')
      if isalphanum:
        resp tag(decoded)
      else:
        resp(error("Invalid tag"))

  get "/list":
    resp list()

  get "/rss":
    redirect("/rss.xml")

  get "/links":
    resp links()

  error Http404:
    resp Http404, error("Page not found")

  error Exception:
    resp Http500, error("Something went wrong")

closeDb()
