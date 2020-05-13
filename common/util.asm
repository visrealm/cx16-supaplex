

!macro dec16 addr {
  pha
  lda #0
  cmp addr
  bne +
  dec addr + 1
+
  dec addr
  pla
}

!macro inc16 addr {
  inc addr
  bne +
  inc addr + 1
+
}