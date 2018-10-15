# Makefile
#
# Converts Markdown to other formats (HTML, PDF) using Pandoc
# <http://johnmacfarlane.net/pandoc/>
#
# Run "make" (or "make all") to convert to all other formats
# Run "make clean" to delete converted files

# Convert all files in this directory that have a .md suffix
SOURCEDIR := src
SOURCES := $(wildcard $(SOURCEDIR)/*.md)
BUILDDIR := build

HTML = $(patsubst $(SOURCEDIR)/%.md,$(BUILDDIR)/%.html,$(SOURCES))
PDF = $(patsubst $(SOURCEDIR)/%.md,$(BUILDDIR)/%.pdf,$(SOURCES))

RM=/bin/rm
PANDOC=/usr/bin/pandoc
PANDOC_OPTIONS=-f gfm
PANDOC_HTML_OPTIONS=--to html5 --lua-filter=pandoc_rules/links-to-html.lua

# Pattern-matching Rules
$(BUILDDIR)/%.html : $(SOURCEDIR)/%.md
	$(PANDOC) $(PANDOC_OPTIONS) $(PANDOC_HTML_OPTIONS) -o $@ $<
$(BUILDDIR)/%.pdf : $(SOURCEDIR)/%.md
	$(PANDOC) $(PANDOC_OPTIONS) $(PANDOC_PDF_OPTIONS) -o $@ $<

# Targets and dependencies
.PHONY: all clean
all : $(PDF) $(HTML)
pdf : clean prepare $(PDF)
html : clean prepare $(HTML)

prepare:
	mkdir -p $(BUILDDIR)

clean:
	$(RM) -rf $(BUILDDIR)
