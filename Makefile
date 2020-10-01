start: build
	$(HTTPD) .

build: content.html

clean:
	rm content.html

.PHONY: start build clean

download:
	mkdir -p $@

download/%.html: | download
	pandoc "https://html.spec.whatwg.org/multipage/$(*F).html" -t html5 -o $@ --lua-filter=process/download.lua

content.html: download/sections.html
content.html: download/grouping-content.html
content.html: download/text-level-semantics.html
content.html: download/edits.html
content.html: download/embedded-content.html
content.html: download/tabular-data.html
content.html: download/forms.html
content.html: download/input.html
content.html: download/form-elements.html
content.html: download/interactive-elements.html
content.html:
	pandoc $^ -t html5 -o $@ --lua-filter=process/content.lua --standalone --css=content.css --toc --toc-depth=4 --metadata pagetitle="HTML Demo"
