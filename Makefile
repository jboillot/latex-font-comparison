FONTS_JSON = fonts.json

TEXFILE = testmath.tex
FIRST_LINE = 115
LAST_LINE = 2317
PAGE_HEIGHT = 841.89

FONTS := $(shell jq -r 'keys[]' $(FONTS_JSON))
TARGETS = $(addprefix generate-,$(FONTS))
LATEXMK_PDF = $(TEXFILE:.tex=.pdf)

all: $(TARGETS)

generate-%: doc-%.pdf map-%.json ;

doc-%.pdf map-%.json: $(TEXFILE)
	@echo "Generating $*"
	tmpdir=$$(mktemp -d) && \
	font=$* && \
	font_line=$$(jq -r ".$*.command" $(FONTS_JSON) | sed 's/\\/\\\\/g') && \
	awk -v font_line="$$font_line" '{ print; if ($$0 ~ /\\usepackage{amsmath,amsthm}/) { print font_line } }' $(TEXFILE) | sed 's/P_\\X/P_{\\X}/g' > "$$tmpdir/$(TEXFILE)" && \
	( \
		cd $$tmpdir && \
		latexmk -lualatex -synctex=1 -interaction=nonstopmode $(TEXFILE) 2>&1 > /dev/null; \
		lasty=0 && \
		echo '[ { "line": 0, "y": 0 }' > map.json && \
		i=$(FIRST_LINE) && \
		while [ "$$i" -le $(LAST_LINE) ]; do \
			ypos=$$(synctex view -i $$i:1:$(TEXFILE) -o $(LATEXMK_PDF) | awk 'BEGIN { FS=":" } /^Page/ {page=$$2} /^y/ {y=$$2; position = $(PAGE_HEIGHT) * (page - 1) + y; printf "%.6f\n", position; exit}') && \
			if [ "$$(echo "$$ypos > $$lasty" | bc -l)" -eq 1 ]; then \
				lasty=$$ypos && \
				echo ", { \"line\": $$i, \"y\": $$ypos }" >> map.json; \
			fi && \
			i=$$(( i + 1 )); \
		done && \
		echo " ]" >> map.json; \
	) && \
	mv $$tmpdir/$(LATEXMK_PDF) doc-$*.pdf && \
	mv $$tmpdir/map.json map-$*.json

clean:
	rm -f doc-*.pdf map-*.json

.PRECIOUS: doc-%.pdf map-%.json
