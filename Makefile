all: download unzip repair clean tif2pdf combine upload cleanup

downlod:
	mkdir -p data/zip
	wget --input-file=links.txt --directory-prefix=data/zip

unzip:
	mkdir -p data/unzip
	parallel "unzip -d data/unzip {}" ::: data/zip/*.zip

repair:
	find data/unzip -type d -exec chmod 755 {} \;

clean:
	find data/unzip -type f -name Thumbs.db -delete
	find data/unzip -type f -name debug.log -delete
	find data/unzip -type f -name desktop.ini -delete
	find data/unzip -type f -name 'Customize Links.url' -delete
	find data/unzip -type f -name '*.tmp' -delete
	find data/unzip -type f -name '*.lnk' -delete

tif2pdf:
	parallel "tiff2pdf -o {.}.pdf {}" ::: data/unzip/*/*.tif
	parallel "rm -f {}" ::: data/unzip/*/*.tif

combine:
	mkdir -p data/upload
	find data/unzip/* -mindepth 1 -maxdepth 1 -exec mv {} data/upload \;

upload:
	b2 sync --delete --excludeAllSymlinks --threads 50 data/upload b2://bucket/VIC_TrafficSignalDataSheets/

cleanup:
	rm -rf data
