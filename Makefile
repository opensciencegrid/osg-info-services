NAME=osg-info-services
VERSION=1.2.2

MAIN_SCRIPT=$(NAME)
CRON_JOB=$(NAME).cron
INIT_SCRIPT=$(NAME).init
HELPER_SCRIPTS=run-with-timeout cronjob-wrapper
LOGROTATE_CFG=$(NAME).logrotate

SBIN_DIR=/usr/sbin
CRON_DIR=/etc/cron.d
INIT_DIR=/etc/rc.d/init.d
HELPER_DIR=/usr/libexec/$(NAME)
LOGROTATE_DIR=/etc/logrotate.d

_default:
	@echo "Nothing to make.  Try make install or make dist"

install:
	mkdir -p $(DESTDIR)$(SBIN_DIR)
	install -m 755 $(MAIN_SCRIPT) $(DESTDIR)$(SBIN_DIR)/

	mkdir -p $(DESTDIR)$(CRON_DIR)
	install -m 644 $(CRON_JOB) $(DESTDIR)$(CRON_DIR)/$(NAME)

	mkdir -p $(DESTDIR)$(INIT_DIR)
	install -m 755 $(INIT_SCRIPT) $(DESTDIR)$(INIT_DIR)/$(NAME)

	mkdir -p $(DESTDIR)$(HELPER_DIR)
	install -m 755 $(HELPER_SCRIPTS) $(DESTDIR)$(HELPER_DIR)/

	mkdir -p $(DESTDIR)$(LOGROTATE_DIR)
	install -m 644 $(LOGROTATE_CFG) $(DESTDIR)$(LOGROTATE_DIR)/$(NAME)

dist:
	mkdir -p $(NAME)-$(VERSION)

	cp -p Makefile LICENSE \
		$(MAIN_SCRIPT) \
		$(CRON_JOB) \
		$(INIT_SCRIPT) \
		$(HELPER_SCRIPTS) \
		$(LOGROTATE_CFG) \
		$(NAME)-$(VERSION)/

	tar czf $(NAME)-$(VERSION).tar.gz \
		$(NAME)-$(VERSION)/ \
		--exclude='*/.svn*' --exclude='*/*.py[co]' --exclude='*/*~'


.PHONY: _default install dist
