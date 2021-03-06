
tools/safeexec: tools/safeexec.c
	gcc tools/safeexec.c -o tools/safeexec

install-bocawww:
	mkdir -p  $(DESTDIR)/var/www/boca/
	cp -r src $(DESTDIR)/var/www/boca/
	cp -r doc $(DESTDIR)/var/www/boca/

install-bocaapache: install-bocawww
	mkdir -p $(DESTDIR)/etc/apache2/sites-enabled/
	cp tools/etc/apache2/conf.d/boca $(DESTDIR)/etc/apache2/sites-enabled/000-boca.conf

install-scripts:
	mkdir -p $(DESTDIR)/usr/sbin/
	install tools/dump.sh $(DESTDIR)/usr/sbin/boca-dump
	install tools/etc/icpc/createbocajail.sh $(DESTDIR)/usr/sbin/boca-createjail
	install tools/boca-createdb.sh $(DESTDIR)/usr/sbin/boca-createdb
	install tools/boca-autojudge.sh $(DESTDIR)/usr/sbin/boca-autojudge
	install tools/boca-config-dbhost.sh $(DESTDIR)/usr/sbin/boca-config-dbhost

install: install-bocawww install-bocaapache install-scripts tools/safeexec
	mkdir -p $(DESTDIR)/usr/bin/
	mkdir -p $(DESTDIR)/etc/
	cp tools/boca.conf $(DESTDIR)/etc/
	install tools/safeexec $(DESTDIR)/usr/bin/safeexec
	chmod 4555 $(DESTDIR)/usr/bin/safeexec
