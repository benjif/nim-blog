import db_sqlite, strutils

let
  db = open("../blog.db", "", "", "")

echo "Post ID: "
var id = parseInt(readLine(stdin))

echo "EDITING POST ", $(id)

echo "New Post: "
var post, buf: string
while buf != "STOP":
  post &= buf & "\n"
  buf = readLine(stdin)

db.exec(sql"BEGIN")
db.exec(sql"UPDATE posts SET post=? WHERE id=?", post, $(id))
db.exec(sql"COMMIT")
