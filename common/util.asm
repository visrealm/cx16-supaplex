

!macro dec16 addr {
  lda addr
  bne +
  dec addr + 1
+
  dec addr
}

!macro inc16 addr {
  inc addr
  bne +
  inc addr + 1
+
}