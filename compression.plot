set terminal svg
set title '{/*1.2:Bold Compression} (higher is better)'
set xtics nomirror rotate offset 1.3,0 scale 0
set grid ytics
set ylabel 'Ratio'
set datafile separator tab
set style data histograms
set style fill solid
set boxwidth 2 absolute
plot [-0.18:6.52] [1:] "<cat -" using 2:xtic(1) fc '#7700ff' lw 0 title ''
