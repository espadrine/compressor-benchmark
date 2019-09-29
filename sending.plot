set terminal svg
set title '{/*1.2:Bold Sending} (bottom right is better)'
set xlabel 'Ratio'
set ylabel 'Sending time (s/MB)'
set datafile separator tab
set key left
plot [] [0:1] for [table in "lz4 gzip bzip2 zstd brotli xz lzip"] "tables/".table.".tsv" using "Ratio":"Send time (s/MB)" with lines linewidth 2 title table
