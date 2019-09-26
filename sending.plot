set terminal svg
set title 'Sending'
set xlabel 'Ratio'
set ylabel 'Send time (s/MB)'
set datafile separator tab
set key left
plot [] [0:1] for [table in "gzip bzip2 brotli zstd xz lzip"] "tables/".table.".tsv" using "Ratio":"Send time (s/MB)" with lines linewidth 2 title table
