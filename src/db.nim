import db_sqlite, strutils, sequtils, times, md5

type
  Post = object
    id:     int
    title:  string
    post:   string
    date:   string
    chksm:  string

let
  db = open("blog.db", "", "", "")

db.exec(
  sql("""
  CREATE TABLE IF NOT EXISTS posts (
    id      INTEGER PRIMARY KEY,
    title   VARCHAR(50) NOT NULL,
    post    TEXT NOT NULL,
    chksm   CHARACTER(16) NOT NULL,
    date    VARCHAR(8) NOT NULL
  )
  """)
)

db.exec(
  sql("""
  CREATE TABLE IF NOT EXISTS tags (
    id    INTEGER PRIMARY KEY,
    name  VARCHAR(32),
    UNIQUE(name)
  )
  """)
)

db.exec(
  sql("""
  CREATE TABLE IF NOT EXISTS post_tags (
    post_id INTEGER,
    tag_id  INTEGER,
    UNIQUE(post_id, tag_id)
  )
  """)
)

proc closeDb(): void =
  db.close()

proc findPost(id: int): Post =
  let
    res = db.getAllRows(sql"SELECT * FROM posts WHERE id=?", $(id))
  if len(res) > 0:
    result =
      Post(
        id:     parseInt(res[0][0]),
        title:  res[0][1],
        post:   res[0][2],
        date:   format(parse(res[0][3], "yyyy-MM-dd"), "dd MMM yyyy"),
        chksm: res[0][4]
      )
  else:
    result = Post(id: -1)

proc getPosts(): seq[Post] =
  for post in db.fastRows(sql"SELECT * FROM posts ORDER BY id DESC"):
    result.add(
      Post(
        id:     parseInt(post[0]),
        title:  post[1],
        post:   post[2],
        date:   format(parse(post[3], "yyyy-MM-dd"), "dd MMM yyyy"),
        chksm:  post[4]
      )
    )

proc addPost(p: Post): int =
  let postCount = getPosts().len
  if p.id == postCount+1:
    db.exec(
      sql"INSERT INTO posts (title, post, date, chksm) VALUES (?,?,?,?)",
      p.title,
      p.post,
      p.date,
      getMD5(p.post)
    )
  else:
    return -1
  return 0

proc updatePost(id: int, content: string): void =
  db.exec(sql"UPDATE posts SET post=?, chksm=? WHERE id=?", content, getMD5(content), id)

proc recentPosts(): seq[Post] =
  let
    res = db.getAllRows(sql"SELECT * FROM posts ORDER BY id DESC LIMIT 3")
  for post in res:
    result.add(
      Post(
        id:     parseInt(post[0]),
        title:  post[1],
        post:   post[2],
        date:   format(parse(post[3], "yyyy-MM-dd"), "dd MMM yyyy"),
        chksm:  post[4]
      )
    )

proc addTag(name: string): void =
  db.exec(
    sql"INSERT OR IGNORE INTO tags (name) VALUES (?)",
    name
  )

proc addPostTag(post_id: int, name: string): void =
  addTag(name)
  let tag_id = db.getRow(sql"SELECT id FROM tags WHERE name=(?)", name)[0]
  db.exec(
    sql"INSERT OR IGNORE INTO post_tags (post_id, tag_id) VALUES (?, ?)",
    post_id,
    tag_id
  )

proc getPostTags(post_id: int): seq[string] =
  let res = db.getAllRows(sql"""
    SELECT tags.name
    FROM 
    post_tags
    JOIN posts ON post_id = posts.id
    JOIN tags ON tag_id = tags.id
    WHERE posts.id=(?)
    """,
    post_id
  )
  return map(res, proc(row: Row): string = row[0])

proc getPostsWithTag(name: string): seq[int] =
  let res = db.getAllRows(sql"""
  SELECT posts.id
  FROM
  post_tags
  JOIN posts ON post_id = posts.id
  JOIN tags ON tag_id = tags.id
  WHERE tags.name=(?)
  """,
  name
  )
  for row in res:
    result.add(parseInt(row[0]))
