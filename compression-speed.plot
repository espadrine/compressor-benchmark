set terminal svg
set title '{/*1.2:Bold Compression} (top right is better)'
set xlabel 'Compression speed (MB/s)'
set ylabel 'Ratio'
set datafile separator tab
set logscale x
plot for [table in "lz4 gzip bzip2 zstd brotli xz lzip"] \
  "tables/".table.".tsv" using "Compression (MB/s)":"Ratio" \
  with lines linewidth 2 title table
