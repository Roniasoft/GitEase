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
    readonly property alias content: fileWatcher.content
    readonly property alias exists: fileWatcher.exists

    function findTheFile(repoDir, possibleFileNames) {
        const files = fileWatcher.findFiles(repoDir, possibleFileNames, false)

        return files.length > 0 ? files[0] : ""
    }

    function getFileContent(filePath) {
        fileWatcher.filePath = filePath
    }

    function openExternally() {
        return fileWatcher.openExternally()
    }
}
