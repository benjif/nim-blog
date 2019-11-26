import os, strutils, times, markdown
include db

echo "Refreshing posts..."
updatePosts()
closeDb()
