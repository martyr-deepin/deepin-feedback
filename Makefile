PREFIX = /usr

ifndef USE_GCCGO
    GOBUILD = go build
else
   LDFLAGS = $(shell pkg-config --libs gio-2.0)
   GOBUILD = go build -compiler gccgo -gccgoflags "${LDFLAGS}"
endif

build: configure
	(cd daemon; ${GOBUILD} -o deepin-feedback-daemon)
	(cd gui; qmake; make)

configure:
	sed "s=@PREFIX@=${PREFIX}=" misc/com.deepin.Feedback.service.in > misc/com.deepin.Feedback.service

pot:
	deepin-update-pot locale/locale_config.ini

install:
	install -dm0755 ${DESTDIR}${PREFIX}/bin/
	install -m0755 cli/deepin-feedback-cli.sh ${DESTDIR}${PREFIX}/bin/deepin-feedback-cli
	install -m0755 gui/deepin-feedback ${DESTDIR}${PREFIX}/bin/deepin-feedback
	install -dm0755 ${DESTDIR}${PREFIX}/lib/deepin-feedback
	install -m0755 daemon/deepin-feedback-daemon ${DESTDIR}${PREFIX}/lib/deepin-feedback/
	install -dm0755 ${DESTDIR}/etc/dbus-1/system.d/
	install -m0644 misc/com.deepin.Feedback.conf ${DESTDIR}/etc/dbus-1/system.d/
	install -dm0755 ${DESTDIR}${PREFIX}/share/dbus-1/system-services/
	install -m0644 misc/com.deepin.Feedback.service ${DESTDIR}${PREFIX}/share/dbus-1/system-services/

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/deepin-feedback-cli
	rm -f ${DESTDIR}${PREFIX}/bin/deepin-feedback
	rm -f ${DESTDIR}${PREFIX}/lib/deepin-feedback/deepin-feedback-daemon
	rmdir ${DESTDIR}${PREFIX}/lib/deepin-feedback
	rm -f ${DESTDIR}/etc/dbus-1/system.d/com.deepin.Feedback.conf
	rm -f ${DESTDIR}${PREFIX}/share/dbus-1/system-services/com.deepin.Feedback.service

clean:
	rm -f daemon/deepin-feedback-daemon
	rm -f misc/com.deepin.Feedback.service
	rm -f gui/deepin-feedback
	(cd gui; make clean || true)
