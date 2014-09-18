.PHONY: \
	crank \
	clean \
	prereq

BUILD=build
SOURCE=s
TEXTDOMAIN=com.bobby-tables

default: crank

prereq:
	perl ./modules.pl

clean:
	rm -fr $(BUILD)
	rm -fr $(SOURCE)/*.tt2

crank: prereq clean messages
	mkdir -p $(BUILD)/ || true > /dev/null 2>&1
	# force English for top directory
	LANG=C perl crank.pl --sourcepath=$(SOURCE) --buildpath=$(BUILD)
	cp -R static/* $(BUILD)/

test: crank
	prove t/*.t

messages:
	# wrap markdown paragraphs into TT loc fragments
	for markdownfile in $(SOURCE)/*.md; do \
	    perl -lne'BEGIN {$$/ = "\n\n";}; print "[% |loc %]$${_}[% END %]\n" if $${_}' \
	    < $$markdownfile > $$markdownfile.tt2 ; done

# This is only useful for Andy
rsync:
	rsync -azu -e ssh --delete --verbose \
	    $(BUILD)/ andy@huggy.petdance.com:/srv/bobby
