import os, strutils, times, markdown
include db

echo "Refreshing posts..."
if updatePosts():
  updateRss()
closeDb()
