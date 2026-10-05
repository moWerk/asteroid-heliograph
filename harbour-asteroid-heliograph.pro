TARGET = harbour-asteroid-heliograph

CONFIG += sailfishapp sailfishapp_i18n sailfishapp_i18n_idbased sailfishapp_i18n_unfinished

SOURCES += src/main.cpp \
    src/FileHelper.cpp

HEADERS += src/FileHelper.h

custom.files = custom.txt
custom.path = /usr/share/$${TARGET}
INSTALLS += custom

DISTFILES += qml/harbour-asteroid-heliograph.qml \
    qml/game/*.qml \
    qml/game/qmldir \
    rpm/harbour-asteroid-heliograph.spec \
    harbour-asteroid-heliograph.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# qsTrId() with //% engineering English: the id based build keeps the
# unfinished entries, so the default .qm carries that English.
TRANSLATIONS += translations/harbour-asteroid-heliograph.ts
