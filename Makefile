BUILD_DIR := build

LATEXMK ?= latexmk
TTFAUTOHINT ?= ttfautohint
PDF2HTMLEX ?= pdf2htmlEX
PDF2HTMLEX_OPTS ?= \
	--process-outline 0 \
	--dest-dir $(BUILD_DIR) \
	--bg-format svg

ifneq ($(shell command -v "$(TTFAUTOHINT)" 2> /dev/null),)
		PDF2HTMLEX_OPTS += --external-hint-tool ttfautohint
endif

SRCS := $(wildcard cv-*.tex)
VARIANTS := $(patsubst cv-%.tex,%,$(SRCS))
LIBS := $(shell find third_party -type f)

PDFS := $(addprefix $(BUILD_DIR)/cv-, $(addsuffix .pdf,$(VARIANTS)))
HTMLS := $(addprefix $(BUILD_DIR)/cv-, $(addsuffix .html,$(VARIANTS)))

.PHONY: all pdf html clean clean-pdf clean-html

all: pdf html

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.pdf: %.tex main.tex variants.sty .latexmkrc $(LIBS) | $(BUILD_DIR)
	$(LATEXMK) "$<"
	find $(BUILD_DIR) -type f -iname "%.*" ! -iname "*.pdf" -delete

$(BUILD_DIR)/%.html: $(BUILD_DIR)/%.pdf $(LIBS)
	$(PDF2HTMLEX) $(PDF2HTMLEX_OPTS) "$<" "$(notdir $@)"

pdf: $(PDFS)
html: $(HTMLS)

clean-pdf:
	$(LATEXMK) -C
	rm -f $(PDFS)

clean-html:
	rm -f $(HTMLS)

clean: clean-pdf clean-html
	rm -rf $(BUILD_DIR)
