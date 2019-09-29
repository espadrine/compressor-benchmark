set terminal svg
set title '{/*1.2:Bold Loading} (bottom left is better)'
set xlabel 'Size of compressed megabyte (MB)'
set ylabel 'Loading time (s/MB)'
set datafile separator tab
set key left
plot for [table in "lz4 gzip bzip2 zstd brotli xz lzip"] \
  "tables/".table.".tsv" using (1/column("Ratio")):"Load time (s/MB)" \
  with lines linewidth 2 title table
