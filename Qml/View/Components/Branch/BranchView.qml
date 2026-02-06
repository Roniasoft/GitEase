import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import GitEase_Style_Impl
import GitEase_Style
import GitEase

/*! ***********************************************************************************************
 * BranchView
 * Management of local and remote branches with Checkout, Create, and Delete capabilities
 * ************************************************************************************************/

UtilitiesCard {
    id: root

    /* Property Declarations
     * ****************************************************************************************/
    property BranchController branchController: null
    property CreateBranchPopup createBranchPopup: null

    title: "Branch Management"
    icon: "\uf126"

    /* Children
     * ****************************************************************************************/
    content: ColumnLayout {
        id: content
        spacing: 12

        Connections {
            target: root
            function onBranchControllerChanged() {
                content.update()
            }
        }

        Connections {
            target: root.createBranchPopup
            function onAboutToHide() {
                content.update()
            }
        }

        Button {
            id: createBtn
            Layout.fillWidth: true
            implicitHeight: 40

            background: Rectangle {
                radius: 8
                color: createBtn.pressed ? "#7ccd7c" : (createBtn.hovered ? "#a9f5a9" : "#90ee90")
                border.color: "#7ccd7c"
            }

            contentItem: RowLayout {
                spacing: 8
                Item { Layout.fillWidth: true }
                Text {
                    text: Style.icons.plus
                    font.family: Style.fontTypes.font6Pro
                    font.pixelSize: 12
                    color: "#1a5e1a"
                }
                Text {
                    text: "Create New Branch"
                    font.pixelSize: 13
                    font.bold: true
                    color: "#1a5e1a"
                }
                Item { Layout.fillWidth: true }
            }

            onClicked: {
                openCreateBranchPopup()
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6
            clip: true

            model: []

            delegate: Rectangle {
                readonly property var branchData: modelData

                width: listView.width
                height: 52
                color: branchData.isCurrent ? "#ffffff" : "#fcfcfc"
                border.color: branchData.isCurrent ? Style.colors.accent : "#eeeeee"
                border.width: branchData.isCurrent ? 1.5 : 1
                radius: 8

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    Text {
                        text: branchData.isRemote ? "\ue09a" : "\uf126"
                        font.family: Style.fontTypes.font6Pro
                        font.pixelSize: 14
                        color: branchData.isCurrent ? Style.colors.accent : (branchData.isRemote ? "#6a1b9a" : Style.colors.mutedText)
                    }

                    ColumnLayout {
                        spacing: 0
                        Text {
                            text: branchData.name
                            font.bold: branchData.isCurrent
                            font.pixelSize: 12
                            color: Style.colors.foreground
                            elide: Text.ElideRight
                        }
                        Text {
                            text: branchData.targetHash ? branchData.targetHash.substring(0, 7) : "no commit"
                            font.family: "Cascadia Mono"
                            font.pixelSize: 9
                            color: Style.colors.mutedText
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        visible: branchData.isCurrent
                        color: Style.colors.accent
                        radius: 4
                        implicitWidth: 40
                        implicitHeight: 16
                        Text {
                            anchors.centerIn: parent
                            text: "HEAD"
                            color: "white"
                            font.pixelSize: 8
                            font.bold: true
                        }
                    }

                    Row {
                        spacing: 8
                        visible: !branchData.isCurrent

                        Button {
                            id: checkoutBtn
                            anchors.verticalCenter: parent.verticalCenter
                            flat: true

                            contentItem: Text {
                                text: "Checkout"
                                font.pixelSize: 11
                                font.bold: true
                                color: checkoutBtn.hovered ? Style.colors.accent : Style.colors.mutedText
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                implicitWidth: 65
                                implicitHeight: 26
                                color: checkoutBtn.pressed ? "#eee" : (checkoutBtn.hovered ? "#f5f5f5" : "transparent")
                                radius: 4
                                border.color: checkoutBtn.hovered ? Style.colors.accent : "transparent"
                            }

                            onClicked: {
                                if (root.branchController) {
                                    root.branchController.checkoutBranch(branchData.name)
                                    content.update()
                                }
                            }
                        }

                        ActionIconButton {
                            iconText: Style.icons.trash
                            tooltip: "Delete Branch"
                            textColor: Style.colors.deletededFile
                            onClicked: {
                                if (root.branchController) {
                                    root.branchController.deleteBranch(branchData.name)
                                    content.update()
                                }
                            }
                        }
                    }
                }
            }
        }

        /* Functions
         * ****************************************************************************************/
        function update() {
            if (root.branchController) {
                let res = root.branchController.getBranches();
                listView.model = null;
                listView.model = res;
            }
        }
    }

    /* Helper Functions
     * ****************************************************************************************/
    function openCreateBranchPopup() {
        if (createBranchPopup) {
            createBranchPopup.branchController = root.branchController
            createBranchPopup.open()
        }
    }

    Component.onCompleted: {
        content.update()
    }
}
