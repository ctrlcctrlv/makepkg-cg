VERSION:=0.2.3
PREFIX:=/usr
INPUTS:=templates/makepkg-cg.in
OUTS:=makepkg-cg makechrootpkg-cg

.PHONY: all dist onerun

all:
	#$(Q)$(MAKE) -C makepkg-cg-prio
	$(Q)$(MAKE) $(OUTS)

$(OUTS): $(INPUTS)
	$(Q)>&2 echo "Generating $@…"
	$(Q)cp $< $@ && \
		$(Q)sed -e 's/@VERSION@/$(VERSION)/g' $< > $@ && \
		$(Q)sed -i -e 's!@PREFIX@!$(PREFIX)!g' $@ && \
		PROGNAME=$@ \
		PROGNAME=$${PROGNAME%%-cg} \
		$(Q)sed -i -e 's/@PROGNAME@/$${PROGNAME}/g' $@ && \
		$(Q)chmod +x $@
	$(Q)>&2 echo "$@ generated!"

dist:
	rm dist/*.tar.gz || true
	mkdir -p dist/makepkg-cg-$(VERSION)
	for f in make*pkg-cg ./{LICENSE,README.md,GNUmakefile} inner.sh {src,doc,templates}; do \
		cp -r $$f dist/makepkg-cg-$(VERSION)/; \
	done
	tar -C dist -czf dist/makepkg-cg-$(VERSION).tar.gz makepkg-cg-$(VERSION)

onerun: dist
	cp dist/makepkg-cg-$(VERSION).tar.gz dist/arch/ && \
		cd dist/arch && makepkg -if --noconfirm --skipinteg --cleanbuild && \
		cd ../.. && systemctl --user daemon-reload
