import QtQuick
import GitEase

/*! ***********************************************************************************************
 * FilePreviewController
 * ************************************************************************************************/

QtObject {
    id: root

    property FileContentWatcher watcher: FileContentWatcher {
        id: fileWatcher
    }

    readonly property alias filePath: fileWatcher.filePath
    readonly property alias content: fileWatcher.content
    readonly property alias exists: fileWatcher.exists
    readonly property alias error: fileWatcher.error

    function findTheFile(repoDir, possibleFileNames) {
        const files = fileWatcher.findFiles(repoDir, possibleFileNames)

        return files.length > 0 ? files[0] : ""
    }

    function getFileContent(filePath) {
        fileWatcher.filePath = filePath
    }

    function openExternally() {
        return fileWatcher.openExternally()
    }
}
