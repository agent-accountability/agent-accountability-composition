DRAFT := draft-mih-sato-agent-accountability-composition

.PHONY: all clean
all: $(DRAFT).txt $(DRAFT).html

$(DRAFT).xml: $(DRAFT).md
	kramdown-rfc2629 $< > $@

$(DRAFT).txt: $(DRAFT).xml
	xml2rfc $< --text --out $@

$(DRAFT).html: $(DRAFT).xml
	xml2rfc $< --html --out $@

clean:
	rm -f $(DRAFT).xml $(DRAFT).txt $(DRAFT).html
