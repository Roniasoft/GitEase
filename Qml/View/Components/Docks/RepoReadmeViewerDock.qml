import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import GitEase_Style_Impl
import GitEase_Style
import GitEase

/*! ***********************************************************************************************
 * RebaseDock
 * ************************************************************************************************/

UtilitiesCard {
    id: root

    /* Property Declarations
     * ****************************************************************************************/
    property RepositoryController repositoryController: null
    property string repoDir: root.repositoryController.appModel.currentRepository.path ?? ""
    property var possibleFileNames: ["README.md", "README.rst", "README.txt"]

    /* Object Properties
     * ****************************************************************************************/
    title: "README Preview"
    icon: Style.icons.file

    /* Slots
     * ****************************************************************************************/
    onRepoDirChanged: {
        loadReadmeFile()
    }

    Component.onCompleted: {
        loadReadmeFile()
    }

    /* Children
     * ****************************************************************************************/
    FilePreviewController {
        id: previewController
    }

    content: ScrollView {
        clip: true

        TextArea {
            readOnly: true
            wrapMode: TextEdit.Wrap
            textFormat: TextEdit.MarkdownText
            text: previewController.exists ? previewController.content : ""
            background: Item {}
        }
    }

    /* functions
     * ****************************************************************************************/
    function loadReadmeFile() {
        if (!repoDir)
            return
        const filePath = previewController.findTheFile(repoDir, possibleFileNames)
        previewController.getFileContent(filePath)
    }
}
