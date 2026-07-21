import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import GitEase_Style_Impl
import GitEase_Style
import GitEase

/*! ***********************************************************************************************
 * RepoReadmeViewerDock
 * ************************************************************************************************/

UtilitiesCard {
    id: root

    /* Property Declarations
     * ****************************************************************************************/
    required property RepositoryController repositoryController
    readonly property string repoDir: root.repositoryController.appModel.currentRepository.path ?? ""
    readonly property var possibleFileNames: ["README.md", "README.rst", "README.txt"]

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

    content: ColumnLayout {
        id: content
        anchors.fill: parent
        spacing: 8

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            TextArea {
                width: parent.width
                readOnly: true
                wrapMode: TextEdit.Wrap
                textFormat: TextEdit.MarkdownText
                text: previewController.exists ? previewController.content : ""
                background: Item {}
            }
        }

        Button {
            id: openBtn
            Layout.fillWidth: true
            implicitHeight: 44

            enabled: previewController.exists

            background: Rectangle {
                radius: 8
                color: openBtn.enabled ? (openBtn.hovered) ? Style.colors.accentHover : Style.colors.accent : (Style.colors.disabledButton)
            }

            contentItem: Item {
                anchors.fill: parent
                Row {
                    spacing: 10
                    anchors.centerIn: parent

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Style.icons.file
                        font.family: Style.fontTypes.font6Pro
                        font.pixelSize: 12
                        color: Style.colors.selectedText
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Open in editor"
                        color: Style.colors.selectedText
                        font.pixelSize: 13
                    }
                }
            }

            onClicked: {
                previewController.openExternally()
            }
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
