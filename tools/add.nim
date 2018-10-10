import db_sqlite, strutils, times, os

let
  db = open("../blog.db", nil, nil, nil)
  now = getDateStr()

echo "ADDING POST AT ", now, "\n"

echo "New Post Title: "
var title = readLine(stdin)

echo "New Post: "
var post, buf: string
while buf != "STOP":
  post &= buf & "\n"
  buf = readLine(stdin)

db.exec(sql"BEGIN")
db.exec(sql"INSERT INTO posts (title, post, date) VALUES (?,?,?)", title, post, now)
db.exec(sql"COMMIT")
