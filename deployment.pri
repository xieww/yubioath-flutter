unix:!android {
    isEmpty(target.path) {
        qnx {
            target.path = /tmp/$${TARGET}/bin
        } else {
            target.path = /usr/bin
        }
        export(target.path)
    }
    INSTALLS += target
}

export(INSTALLS)
