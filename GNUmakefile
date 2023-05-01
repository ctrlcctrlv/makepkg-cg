VERSION=0.2.1

.PHONY: all dist onerun

all:
	$(Q)$(MAKE) -C makepkg-cg-prio

dist:
	tar czf dist/makepkg-cg-$(VERSION).tar.gz --exclude-vcs-ignores -C .. makepkg-cg-$(VERSION)

onerun: dist
	cp dist/makepkg-cg-$(VERSION).tar.gz dist/arch/ && \
		cd dist/arch && makepkg -if --noconfirm && \
		cd ../.. && systemctl --user daemon-reload
