NAME=osg-info-services
VERSION=1.2.0

MAIN_SCRIPT=$(NAME)
CRON_JOB=$(NAME).cron
INIT_SCRIPT=$(NAME).init
HELPER_SCRIPTS=run-with-timeout cronjob-wrapper

SBIN_DIR=/usr/sbin
CRON_DIR=/etc/cron.d
INIT_DIR=/etc/rc.d/init.d
HELPER_DIR=/usr/libexec/$(NAME)

_default:
	@echo "Nothing to make.  Try make install"

install:
	mkdir -p $(DESTDIR)$(SBIN_DIR)
	install -m 755 $(MAIN_SCRIPT) $(DESTDIR)$(SBIN_DIR)/

	mkdir -p $(DESTDIR)$(CRON_DIR)
	install -m 644 $(CRON_JOB) $(DESTDIR)$(CRON_DIR)/$(NAME)

	mkdir -p $(DESTDIR)$(INIT_DIR)
	install -m 755 $(INIT_SCRIPT) $(DESTDIR)$(INIT_DIR)/$(NAME)

	mkdir -p $(DESTDIR)$(HELPER_DIR)
	install -m 755 $(HELPER_SCRIPTS) $(DESTDIR)$(HELPER_DIR)/

dist:
	mkdir -p $(NAME)-$(VERSION)

	cp -p Makefile LICENSE \
		$(MAIN_SCRIPT) \
		$(CRON_JOB) \
		$(INIT_SCRIPT) \
		$(HELPER_SCRIPTS) \
		$(NAME)-$(VERSION)/

	tar czf $(NAME)-$(VERSION).tar.gz \
		$(NAME)-$(VERSION)/ \
		--exclude='*/.svn*' --exclude='*/*.py[co]' --exclude='*/*~'


.PHONY: _default install dist
