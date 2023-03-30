VERSION=0.1.0

.PHONY: all dist onerun

all:
	$(Q)$(MAKE) -C makepkg-cg-prio

dist:
	tar czf dist/makepkg-cg-$(VERSION).tar.gz --exclude-vcs-ignores -C .. makepkg-cg-$(VERSION)

onerun:
	make dist ; cd dist/arch ; cp ../makepkg-cg-0.1.0.tar.gz  . ; makepkg -if --noconfirm ; cd ../.. ; systemctl --user daemon-reload
