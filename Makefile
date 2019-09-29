SHELL = /bin/bash
SIZE != <webster wc -c
COMPRESSORS = lz4 gzip zstd bzip2 brotli xz lzip
STATS = $(patsubst %,tables/%.tsv,$(COMPRESSORS))

all: $(STATS) clean

# Download the Webster collection from the Silesia corpus: http://sun.aei.polsl.pl/~sdeor/index.php?page=silesia
webster:
	curl -s http://sun.aei.polsl.pl/~sdeor/corpus/webster.bz2 -O
	<webster.bz2 bzip2 -d >webster
	rm webster.bz2

# ratio: size of uncompressed data for every MB of compressed payload.
# compression: average number of MB that can get compressed every second.
# decompression: average number of MB that can get decompressed every second.
# load time: assuming a 1 MB/s Internet connection, how much time does it
#   take to transmit 1 MB of raw data by transmitting the (already-compressed)
#   payload, and uncompressing it on the client?
# send time: same as load time, including compression time.

tables/stats.tsv: webster $(STATS)

stats.tsv-header:
	echo -e 'Compressor\tRatio\tCompression (MB/s)\tDecompression (MB/s)\tLoad time (s/MB)\tSend time (s/MB)' >tables/stats.tsv

tables/lz4.tsv:
	compressor=lz4; file=/tmp/webster.lz4; \
	echo -e 'Compressor\tRatio\tCompression (MB/s)\tDecompression (MB/s)\tLoad time (s/MB)\tSend time (s/MB)' >$@; \
	for l in `seq -12 -1`; do \
	  comp="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <webster $$compressor $$l 2>&1 >$$file)")"; \
	  ratio="$$(bc <<<"scale=3; $(SIZE)/$$(<$$file wc -c)")"; \
	  dec="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <$$file $$compressor -d 2>&1 >/dev/null)")"; \
	  echo -e "$$compressor $$l\t$$ratio\t$$comp\t$$dec\t$$(bc <<<"scale=3;1/$$ratio+1/$$dec")\t$$(bc <<<"scale=3;1/$$comp+1/$$ratio+1/$$dec")" >>$@; \
	done

tables/gzip.tsv:
	compressor=gzip; file=/tmp/webster.gz; \
	echo -e 'Compressor\tRatio\tCompression (MB/s)\tDecompression (MB/s)\tLoad time (s/MB)\tSend time (s/MB)' >$@; \
	for l in `seq -9 -1`; do \
	  comp="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <webster $$compressor $$l 2>&1 >$$file)")"; \
	  ratio="$$(bc <<<"scale=3; $(SIZE)/$$(<$$file wc -c)")"; \
	  dec="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <$$file $$compressor -d 2>&1 >/dev/null)")"; \
	  echo -e "$$compressor $$l\t$$ratio\t$$comp\t$$dec\t$$(bc <<<"scale=3;1/$$ratio+1/$$dec")\t$$(bc <<<"scale=3;1/$$comp+1/$$ratio+1/$$dec")" >>$@; \
	done

tables/zstd.tsv:
	compressor=zstd; file=/tmp/webster.zst; \
	echo -e 'Compressor\tRatio\tCompression (MB/s)\tDecompression (MB/s)\tLoad time (s/MB)\tSend time (s/MB)' >$@; \
	for l in `seq -22 -1`; do \
	  comp="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <webster $$compressor --ultra $$l 2>&1 >$$file)")"; \
	  ratio="$$(bc <<<"scale=3; $(SIZE)/$$(<$$file wc -c)")"; \
	  dec="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <$$file $$compressor -d 2>&1 >/dev/null)")"; \
	  echo -e "$$compressor $$l\t$$ratio\t$$comp\t$$dec\t$$(bc <<<"scale=3;1/$$ratio+1/$$dec")\t$$(bc <<<"scale=3;1/$$comp+1/$$ratio+1/$$dec")" >>$@; \
	done

tables/bzip2.tsv:
	compressor=bzip2; file=/tmp/webster.bz2; \
	echo -e 'Compressor\tRatio\tCompression (MB/s)\tDecompression (MB/s)\tLoad time (s/MB)\tSend time (s/MB)' >$@; \
	for l in `seq -9 -1`; do \
	  comp="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <webster $$compressor $$l 2>&1 >$$file)")"; \
	  ratio="$$(bc <<<"scale=3; $(SIZE)/$$(<$$file wc -c)")"; \
	  dec="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <$$file $$compressor -d 2>&1 >/dev/null)")"; \
	  echo -e "$$compressor $$l\t$$ratio\t$$comp\t$$dec\t$$(bc <<<"scale=3;1/$$ratio+1/$$dec")\t$$(bc <<<"scale=3;1/$$comp+1/$$ratio+1/$$dec")" >>$@; \
	done

tables/brotli.tsv:
	compressor=brotli; file=/tmp/webster.br; \
	echo -e 'Compressor\tRatio\tCompression (MB/s)\tDecompression (MB/s)\tLoad time (s/MB)\tSend time (s/MB)' >$@; \
	for l in `seq 0 11`; do \
	  comp="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <webster $$compressor -q $$l 2>&1 >$$file)")"; \
	  ratio="$$(bc <<<"scale=3; $(SIZE)/$$(<$$file wc -c)")"; \
	  dec="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <$$file $$compressor -d 2>&1 >/dev/null)")"; \
	  echo -e "$$compressor $$l\t$$ratio\t$$comp\t$$dec\t$$(bc <<<"scale=3;1/$$ratio+1/$$dec")\t$$(bc <<<"scale=3;1/$$comp+1/$$ratio+1/$$dec")" >>$@; \
	done

tables/xz.tsv:
	compressor=xz; file=/tmp/webster.xz; \
	echo -e 'Compressor\tRatio\tCompression (MB/s)\tDecompression (MB/s)\tLoad time (s/MB)\tSend time (s/MB)' >$@; \
	for l in `seq -9 -1` -0; do \
	  comp="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <webster $$compressor $$l 2>&1 >$$file)")"; \
	  ratio="$$(bc <<<"scale=3; $(SIZE)/$$(<$$file wc -c)")"; \
	  dec="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <$$file $$compressor -d 2>&1 >/dev/null)")"; \
	  echo -e "$$compressor $$l\t$$ratio\t$$comp\t$$dec\t$$(bc <<<"scale=3;1/$$ratio+1/$$dec")\t$$(bc <<<"scale=3;1/$$comp+1/$$ratio+1/$$dec")" >>$@; \
	done

tables/lzip.tsv:
	compressor=lzip; file=/tmp/webster.lz; \
	echo -e 'Compressor\tRatio\tCompression (MB/s)\tDecompression (MB/s)\tLoad time (s/MB)\tSend time (s/MB)' >$@; \
	for l in `seq -9 -1` -0; do \
	  comp="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <webster $$compressor $$l 2>&1 >$$file)")"; \
	  ratio="$$(bc <<<"scale=3; $(SIZE)/$$(<$$file wc -c)")"; \
	  dec="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <$$file $$compressor -d 2>&1 >/dev/null)")"; \
	  echo -e "$$compressor $$l\t$$ratio\t$$comp\t$$dec\t$$(bc <<<"scale=3;1/$$ratio+1/$$dec")\t$$(bc <<<"scale=3;1/$$comp+1/$$ratio+1/$$dec")" >>$@; \
	done

sending.svg: $(STATS) plots sending.plot
	gnuplot sending.plot >plots/sending.svg

tables:
	mkdir -p tables

plots:
	mkdir -p plots

clean:
	rm -f /tmp/webster.*

.PHONY: all stats.tsv-header clean
