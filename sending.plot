set terminal svg
set title '{/*1.2:Bold Sending} (bottom left is better)'
set xlabel 'Size of compressed megabyte (MB)'
set ylabel 'Sending time (s/MB)'
set datafile separator tab
plot [] [0:1] for [table in "lz4 gzip bzip2 zstd brotli xz lzip"] \
  "tables/".table.".tsv" using (1/column("Ratio")):"Send time (s/MB)" \
  with lines linewidth 2 title table
