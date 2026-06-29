import QtQuick
import GitEase

/*! ***********************************************************************************************
 * FilePreviewController
 * ************************************************************************************************/

QtObject {
    id: root

    property FileContentWatcher watcher: FileContentWatcher {}

    readonly property alias filePath: watcher.filePath
    readonly property alias content: watcher.content
    readonly property alias exists: watcher.exists
    readonly property alias error: watcher.error

    function findTheFile(possibleFileNames) {
        return watcher.findFiles(possibleFileNames)[0]
    }

    function getFileContent(filePath) {
    }
}
