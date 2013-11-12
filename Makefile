default:
	@cat README

clean:
	@echo ""
	@echo "--> clean directory"
	rm -f trustdb.gpg secring.gpg *~
	rm -rf ldstable-repository*
	rm -rf ldtesting-repository*
	rm -rf ldnightly-repository*
	rm -f *.log

list:
	gpg --no-permission-warning --homedir ./ --list-keys

upload-keys:
	ssh root@stack.linkeddata.org "rm /home/packaging/.ssh/PublicKeys/*.pub"
	scp keys/*.pub root@stack.linkeddata.org:/home/packaging/.ssh/PublicKeys/
	ssh root@stack.linkeddata.org "cat /home/packaging/.ssh/PublicKeys/*.pub >/home/packaging/.ssh/authorized_keys"

ldrepository: clean ldrepository-newversion ldrepository-build

ldrepository-newversion:
	@echo ""
	@echo "--> create new changelog entry"
	dch -D ldstack-nightly --force-distribution -v ChangeMe -b

LDREP_VERSION=$(shell dpkg-parsechangelog | grep Version: | head -1 | cut -d " " -f 2 | cut -d "-" -f 1)
ldrepository-build:
	@echo ""
	@echo "--> build the package "
	@echo "nightly"
	mkdir -p ldnightly-repository-$(LDREP_VERSION)
	cp -R debian        ldnightly-repository-$(LDREP_VERSION)
	cp ldnightly.list ldnightly-repository-$(LDREP_VERSION)
	cp pubring.gpg      ldnightly-repository-$(LDREP_VERSION)/ld-keyring.gpg
	cp install_nightly  ldnightly-repository-$(LDREP_VERSION)/debian/ldnightly-repository.install
	cp prerm_nightly  ldnightly-repository-$(LDREP_VERSION)/debian/prerm
	sed -i -e "s/ldrepository/ldnightly-repository/g" ldnightly-repository-$(LDREP_VERSION)/debian/changelog
	sed -i -e "s/ldrepository/ldnightly-repository/g" ldnightly-repository-$(LDREP_VERSION)/debian/control
	cd ldnightly-repository-$(LDREP_VERSION) && debuild
	@echo "testing"
	mkdir -p ldtesting-repository-$(LDREP_VERSION)
	cp -R debian        ldtesting-repository-$(LDREP_VERSION)
	cp ldtesting.list ldtesting-repository-$(LDREP_VERSION)
	cp pubring.gpg      ldtesting-repository-$(LDREP_VERSION)/ld-keyring.gpg
	cp install_testing  ldtesting-repository-$(LDREP_VERSION)/debian/ldtesting-repository.install
	cp prerm_testing  ldtesting-repository-$(LDREP_VERSION)/debian/prerm
	sed -i -e "s/ldrepository/ldtesting-repository/g" ldtesting-repository-$(LDREP_VERSION)/debian/changelog
	sed -i -e "s/ldrepository/ldtesting-repository/g" ldtesting-repository-$(LDREP_VERSION)/debian/control
	cd ldtesting-repository-$(LDREP_VERSION) && debuild
	@echo "stable"
	mkdir -p ldstable-repository-$(LDREP_VERSION)
	cp -R debian        ldstable-repository-$(LDREP_VERSION)
	cp ldstable.list ldstable-repository-$(LDREP_VERSION)
	cp pubring.gpg      ldstable-repository-$(LDREP_VERSION)/ld-keyring.gpg
	cp install_stable  ldstable-repository-$(LDREP_VERSION)/debian/install
	cp install_stable  ldstable-repository-$(LDREP_VERSION)/debian/ldstable-repository.install
	cp prerm_stable  ldstable-repository-$(LDREP_VERSION)/debian/prerm
	sed -i -e "s/ldrepository/ldstable-repository/g" ldstable-repository-$(LDREP_VERSION)/debian/changelog
	sed -i -e "s/ldrepository/ldstable-repository/g" ldstable-repository-$(LDREP_VERSION)/debian/control
	cd ldstable-repository-$(LDREP_VERSION) && debuild
	@echo ""
	@echo "now test the package, then run \"dput ld ldnightly-repository_xxx.changes\""
	@echo "now test the package, then run \"dput ld ldtesting-repository_xxx.changes\""
	@echo "now test the package, then run \"dput ld ldstable-repository_xxx.changes\""

