PREFIX = /usr

ifndef USE_GCCGO
    GOBUILD = go build
else
   LDFLAGS = $(shell pkg-config --libs gio-2.0)
   GOBUILD = go build -compiler gccgo -gccgoflags "${LDFLAGS}"
endif

build: check
	(cd cli; go build feedbackserver.go)

configure:
	sed "s=@PREFIX@=${PREFIX}=" misc/com.deepin.Feedback.service.in > misc/com.deepin.Feedback.service

pot:
	deepin-update-pot locale/locale_config.ini

install:
	install -dm0755 ${DESTDIR}${PREFIX}/bin/
	mkdir -p ${DESTDIR}/var/lib/deepin-feedback/
	cp -rf feedback_logpath.json ${DESTDIR}/var/lib/deepin-feedback/feedback_logpath.json
	install -m0755 cli/deepin-feedback-cli.sh ${DESTDIR}${PREFIX}/bin/deepin-feedback-cli
	install -m0755 cli/feedbackserver ${DESTDIR}${PREFIX}/bin/
	install -m0755 deepin-feedback ${DESTDIR}${PREFIX}/bin/
	install -dm0755 ${DESTDIR}${PREFIX}/share/applications
	install -m0755 deepin-feedback.desktop ${DESTDIR}${PREFIX}/share/applications/
	install -dm0755 ${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps
	install -m0644 misc/deepin-feedback.svg ${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/
	install -dm0755 ${DESTDIR}${PREFIX}/share/polkit-1/actions/
	install -m0644 com.deepin.deepin-feedback.policy ${DESTDIR}${PREFIX}/share/polkit-1/actions/

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/deepin-feedback-cli
	rm -f /var/lib/deepin-feedback/feedback_logpath.json
	rm -f ${DESTDIR}${PREFIX}/share/applications/deepin-feedback.desktop
	rm -f ${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/deepin-feedback.svg

check:
	bash --norc -n -- cli/deepin-feedback-cli.sh

clean:
	rm -f cli/feedbackserver
