import jester, re, strutils
include inner

routes:
  get "/":
    resp index()
  get re"^\/blog\/(\d)$":
    resp blog(parseInt(request.matches[0]))
  get "/list":
    resp list()

db.close()
