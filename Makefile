NAME = txt2regex
VERSION	= 0.2

SHSKEL = $(NAME)-$(VERSION).sh
DISTDIR = $(NAME)-$(VERSION)
PODIR = po
FILES = Makefile README Changelog COPYRIGHT TODO $(SHSKEL) $(PODIR)


DESTDIR = 
BINDIR	= $(DESTDIR)/usr/bin
LOCALEDIR = $(DESTDIR)/usr/share/locale

TARGET=all

clean:
	rm -f po/messages po/*.{mo,old,tmp} $(NAME)
	find po -mindepth 1 -type d -exec rm -rf {} \;

check-po-dir: 
	@if [ ! -d $(PODIR) ]; then \
	echo "warning: directory '$(PODIR)' not found. nothing to do."; \
	exit 1;\
	fi

pot: check-po-dir
	cd $(PODIR) && \
	bash --dump-po-strings ../$(SHSKEL) > $(NAME).pot

# all the later sed festival to strip po-header discarded by bash
# --dump-po-strings...
po:	check-po-dir
	@cd $(PODIR) && \
	for pot in *.po; do \
		echo -n "merging $$pot..."; \
		poti=`echo $$pot | sed 's/\.po$$//'`; \
		cp $$pot $$pot.old && \
		msgmerge $$pot.old $(NAME).pot > $$pot && \
		cp $$pot $$pot.tmp && \
		sed '/^$$/q' $$pot.old > $$pot && \
		sed '/^$$/{N;N;N;/\n#~ "Project-Id/{:a;$$!N;s/.*\n//;ta;d;};}' \
			$$pot.tmp >> $$pot; \
	done

mo: check-po-dir
	@cd $(PODIR) && \
	for pot in *.po; do \
		echo -n "compiling $$pot..."; \
		poti=`echo $$pot | sed 's/\.po$$//'`; \
		msgfmt -o $$poti.mo $$pot && \
		echo ok; \
	done

check-po: check-po-dir
	@cd $(PODIR) && \
	for pot in *.po; do \
		echo -n "checking $$pot... "; \
		msgfmt -vv $$pot || exit 1; \
	done

update-po: pot po mo

tgz: clean check-po
	mkdir $(DISTDIR) && \
	cp -a $(FILES) $(DISTDIR) && \
	tar cvzf $(DISTDIR).tgz $(DISTDIR) && \
	rm -rf $(DISTDIR)

install: mo
	@[ -d $(LOCALEDIR) ] || mkdir -p $(LOCALEDIR); \
	for pot in `cd $(PODIR) && ls *.mo`; do \
		poti=`echo $$pot | sed 's/\.mo$$//'`; \
		modir=$(LOCALEDIR)/$$poti/LC_MESSAGES; \
		[ -d $$modir ] || mkdir -p $$modir; \
		install -m644 $(PODIR)/$$pot $$modir/$(NAME).mo; \
	done; \
	sed 's,^\(TEXTDOMAINDIR=\).*,\1$(LOCALEDIR),' $(SHSKEL) > $(BINDIR)/$(NAME) && \
	chmod +x $(BINDIR)/$(NAME) && \
	echo "program '$(NAME)' installed. just run $(BINDIR)/$(NAME)"
