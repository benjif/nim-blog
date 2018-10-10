import db_sqlite, strutils

type
  Post = object
    id:     int
    title:  string
    post:   string
    date:   string

let
  db = open("blog.db", "", "", "")

db.exec(
  sql("""
  CREATE TABLE IF NOT EXISTS posts (
    id    INTEGER PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    post  TEXT NOT NULL,
    date  VARCHAR(8) NOT NULL
  )
  """)
)

proc findPost(id: int): Post =
  let
    res = db.getAllRows(sql"SELECT * FROM posts WHERE id=?", $(id))
  if len(res) > 0:
    result =
      Post(
        id:     parseInt(res[0][0]),
        title:  res[0][1],
        post:   res[0][2],
        date:   res[0][3]
      )
  else:
    result = Post()

proc recentPosts(): seq[Post] =
  let
    res = db.getAllRows(sql"SELECT * FROM posts ORDER BY id DESC LIMIT 3")
  for post in res:
    result.add(
      Post(
        id:     parseInt(post[0]),
        title:  post[1],
        post:   post[2],
        date:   post[3]
      )
    )

proc getPosts(): seq[Post] =
  let
    res = db.getAllRows(sql"SELECT * FROM posts ORDER BY id DESC")
  for post in res:
    result.add(
      Post(
        id:     parseInt(post[0]),
        title:  post[1],
        post:   post[2],
        date:   post[3]
      )
    )
