set terminal svg
set title '{/*1.2:Bold Loading} (bottom right is better)'
set xlabel 'Ratio'
set ylabel 'Loading time (s/MB)'
set datafile separator tab
plot for [table in "lz4 gzip bzip2 zstd brotli xz lzip"] "tables/".table.".tsv" using "Ratio":"Load time (s/MB)" with lines linewidth 2 title table
