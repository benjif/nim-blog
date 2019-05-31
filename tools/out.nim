import db_sqlite, strutils, os

if paramCount() < 1:
  quit()

let
  db = open("../blog.db", "", "", "")

var id = paramStr(1)

db.exec(sql"BEGIN")
#db.exec(sql"UPDATE posts SET post=? WHERE id=?", post, $(id))
echo db.getValue(sql"SELECT post FROM posts WHERE id=?", id)
db.exec(sql"COMMIT")
