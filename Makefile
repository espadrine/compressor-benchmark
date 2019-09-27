SHELL = /bin/bash
SIZE != <webster wc -c
GZIP = gz
BZIP2 = bz2
BROTLI = br
ZSTD = zst
XZ = xz
LZIP = lz
EXTENSIONS = $(GZIP) $(BZIP2) $(BROTLI) $(ZSTD) $(XZ) $(LZIP)
WEBSTER_COMPRESSED = $(patsubst %,webster.%,$(EXTENSIONS))
COMPRESSORS = gzip bzip2 brotli zstd xz lzip

all: webster stats.tsv $(WEBSTER_COMPRESSED) clean

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

stats.tsv: | stats.tsv-header $(WEBSTER_COMPRESSED)

stats.tsv-header:
	echo -e 'Compressor\tRatio\tCompression (MB/s)\tDecompression (MB/s)\tLoad time (s/MB)\tSend time (s/MB)' >stats.tsv

webster.$(GZIP):
	compressor=gzip; file=/tmp/webster.$(GZIP); \
	for l in `seq -9 -1`; do \
	  comp="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <webster $$compressor $$l 2>&1 >$$file)")"; \
	  ratio="$$(bc <<<"scale=3; $(SIZE)/$$(<$$file wc -c)")"; \
	  dec="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <$$file $$compressor -d 2>&1 >/dev/null)")"; \
	  echo -e "$$compressor $$l\t$$ratio\t$$comp\t$$dec\t$$(bc <<<"scale=3;1/$$ratio+1/$$dec")\t$$(bc <<<"scale=3;1/$$comp+1/$$ratio+1/$$dec")" >>stats.tsv; \
	done

webster.$(ZSTD):
	compressor=zstd; file=/tmp/webster.$(ZSTD); \
	for l in `seq -19 -1`; do \
	  comp="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <webster $$compressor $$l 2>&1 >$$file)")"; \
	  ratio="$$(bc <<<"scale=3; $(SIZE)/$$(<$$file wc -c)")"; \
	  dec="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <$$file $$compressor -d 2>&1 >/dev/null)")"; \
	  echo -e "$$compressor $$l\t$$ratio\t$$comp\t$$dec\t$$(bc <<<"scale=3;1/$$ratio+1/$$dec")\t$$(bc <<<"scale=3;1/$$comp+1/$$ratio+1/$$dec")" >>stats.tsv; \
	done

webster.$(BZIP2):
	compressor=bzip2; file=/tmp/webster.$(BZIP2); \
	for l in `seq -9 -1`; do \
	  comp="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <webster $$compressor $$l 2>&1 >$$file)")"; \
	  ratio="$$(bc <<<"scale=3; $(SIZE)/$$(<$$file wc -c)")"; \
	  dec="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <$$file $$compressor -d 2>&1 >/dev/null)")"; \
	  echo -e "$$compressor $$l\t$$ratio\t$$comp\t$$dec\t$$(bc <<<"scale=3;1/$$ratio+1/$$dec")\t$$(bc <<<"scale=3;1/$$comp+1/$$ratio+1/$$dec")" >>stats.tsv; \
	done

webster.$(BROTLI):
	compressor=brotli; file=/tmp/webster.$(BROTLI); \
	for l in `seq 0 11`; do \
	  comp="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <webster $$compressor -q $$l 2>&1 >$$file)")"; \
	  ratio="$$(bc <<<"scale=3; $(SIZE)/$$(<$$file wc -c)")"; \
	  dec="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <$$file $$compressor -d 2>&1 >/dev/null)")"; \
	  echo -e "$$compressor $$l\t$$ratio\t$$comp\t$$dec\t$$(bc <<<"scale=3;1/$$ratio+1/$$dec")\t$$(bc <<<"scale=3;1/$$comp+1/$$ratio+1/$$dec")" >>stats.tsv; \
	done

webster.$(XZ):
	compressor=xz; file=/tmp/webster.$(XZ); \
	for l in `seq -9 -1` -0; do \
	  comp="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <webster $$compressor $$l 2>&1 >$$file)")"; \
	  ratio="$$(bc <<<"scale=3; $(SIZE)/$$(<$$file wc -c)")"; \
	  dec="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <$$file $$compressor -d 2>&1 >/dev/null)")"; \
	  echo -e "$$compressor $$l\t$$ratio\t$$comp\t$$dec\t$$(bc <<<"scale=3;1/$$ratio+1/$$dec")\t$$(bc <<<"scale=3;1/$$comp+1/$$ratio+1/$$dec")" >>stats.tsv; \
	done

webster.$(LZIP):
	compressor=lzip; file=/tmp/webster.$(LZIP); \
	for l in `seq -9 -1` -0; do \
	  comp="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <webster $$compressor $$l 2>&1 >$$file)")"; \
	  ratio="$$(bc <<<"scale=3; $(SIZE)/$$(<$$file wc -c)")"; \
	  dec="$$(bc <<<"scale=3; $(SIZE)/1000000/$$(/usr/bin/time -f '%U' <$$file $$compressor -d 2>&1 >/dev/null)")"; \
	  echo -e "$$compressor $$l\t$$ratio\t$$comp\t$$dec\t$$(bc <<<"scale=3;1/$$ratio+1/$$dec")\t$$(bc <<<"scale=3;1/$$comp+1/$$ratio+1/$$dec")" >>stats.tsv; \
	done

sending.svg: stats.tsv tables plots sending.plot
	for compressor in $(COMPRESSORS); do \
	  <stats.tsv head -1 >tables/"$$compressor".tsv; \
	  <stats.tsv grep "$$compressor" >>tables/"$$compressor".tsv; \
	done
	gnuplot sending.plot >plots/sending.svg

tables:
	mkdir -p tables

plots:
	mkdir -p plots

clean:
	rm -f /tmp/webster.*

.PHONY: all stats.tsv-header clean
