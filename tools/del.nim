import db_sqlite, strutils, times

let
  db = open("../blog.db", "", "", "")

echo "Post ID: "
var id = parseInt(readLine(stdin))

db.exec(sql"BEGIN")
db.exec(sql"DELETE FROM posts WHERE id=?", id)
db.exec(sql"COMMIT")
