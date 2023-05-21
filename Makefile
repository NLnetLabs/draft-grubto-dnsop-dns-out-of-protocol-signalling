VERSION = 02
DOCNAME = draft-grubto-dnsop-dns-out-of-protocol-signalling
today := $(shell TZ=UTC date +%Y-%m-%dT00:00:00Z)

all: $(DOCNAME)-$(VERSION).txt $(DOCNAME)-$(VERSION).html

pages: $(DOCNAME)-$(VERSION).txt $(DOCNAME)-$(VERSION).html
	cp -p $(DOCNAME)-$(VERSION).txt docs/$(DOCNAME)-$(VERSION).txt
	cp -p $(DOCNAME)-$(VERSION).html docs/$(DOCNAME)-$(VERSION).html
	
$(DOCNAME)-$(VERSION).txt: $(DOCNAME).xml
	xml2rfc --text -o $@ $<

$(DOCNAME)-$(VERSION).html: $(DOCNAME).xml
	xml2rfc --html -o $@ $<

$(DOCNAME).xml: $(DOCNAME).md
	sed -e 's/@DOCNAME@/$(DOCNAME)-$(VERSION)/g' \
	    -e 's/@TODAY@/${today}/g'  $< | mmark > $@ || rm -f $@

clean:
	rm -f $(DOCNAME).xml $(DOCNAME)-$(VERSION).txt $(DOCNAME)-$(VERSION).html
