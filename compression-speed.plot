set terminal svg
set title '{/*1.2:Bold Compression} (top left is better)'
set xlabel 'Compression time of a megabyte (s)'
set ylabel 'Ratio'
set datafile separator tab
set key bottom
set logscale x
plot for [table in "lz4 gzip bzip2 zstd brotli xz lzip"] \
  "tables/".table.".tsv" using (1/column("Compression (MB/s)")):"Ratio" \
  with lines linewidth 2 title table
