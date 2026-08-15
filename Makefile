DRAFT := draft-mih-sato-agent-accountability-composition

# .html is intentionally not built here: it is dropped from the submission set
# entirely (not a hashed/published artifact for this draft). See SOURCE-OF-TRUTH.md.
.PHONY: all clean
all: $(DRAFT).txt

$(DRAFT).xml: $(DRAFT).md
	kramdown-rfc2629 $< > $@

$(DRAFT).txt: $(DRAFT).xml
	xml2rfc $< --text --out $@

clean:
	rm -f $(DRAFT).xml $(DRAFT).txt
