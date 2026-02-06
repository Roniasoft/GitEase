import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import GitEase
import GitEase_Style
import GitEase_Style_Impl

/*! ***********************************************************************************************
 * CreateBranchPopup
 * Popup for creating a new local branch
 * ************************************************************************************************/

IPopup {
    id: root

    /* Property Declarations */
    property BranchController branchController

    readonly property bool isNameValid: nameInput.text.trim().length > 0
    readonly property bool canAccept: isNameValid

    width: 340
    height: 230
    padding: 20

    contentItem: Rectangle {
        color: Style.colors.primaryBackground
        radius: 16
        clip: true
        border.color: Style.colors.accent
        border.width: 1

        ColumnLayout {
            spacing: 20
            anchors.fill: parent
            anchors.margins: 20

            Text {
                text: "Create New Branch"
                color: Style.colors.foreground
                font.family: Style.fontTypes.roboto
                font.bold: true
                font.pixelSize: 16
                Layout.alignment: Qt.AlignHCenter
            }

            ColumnLayout {
                spacing: 8
                Layout.fillWidth: true

                TextField {
                    id: nameInput
                    placeholderText: "Branch Name (e.g. feature-login)"
                    Layout.fillWidth: true
                    selectByMouse: true
                    focus: true

                    background: Rectangle {
                        implicitHeight: 40
                        color: Style.colors.secondaryBackground
                        radius: 8
                        border.color: nameInput.activeFocus ? Style.colors.accent : "transparent"
                    }

                    onAccepted: if(root.canAccept) createBtn.clicked()
                }
            }

            RowLayout {
                spacing: 12
                Layout.fillWidth: true

                Button {
                    text: "Cancel"
                    Layout.preferredWidth: parent.width * 0.4
                    onClicked: root.close()

                    background: Rectangle {
                        implicitHeight: 38
                        color: "transparent"
                        border.color: Style.colors.accent
                        radius: 8
                    }
                }

                Button {
                    id: createBtn
                    text: "Create Branch"
                    Layout.fillWidth: true
                    enabled: root.canAccept
                    opacity: enabled ? 1.0 : 0.5

                    background: Rectangle {
                        implicitHeight: 38
                        color: (createBtn.hovered && createBtn.enabled) ? Style.colors.accent : Style.colors.secondaryBackground
                        border.color: Style.colors.accent
                        radius: 8
                    }

                    onClicked: {
                        if (root.branchController) {
                            let res = root.branchController.createBranch(nameInput.text.trim());
                            if (res.success) {
                                root.close();
                            }
                        }
                    }
                }
            }
        }
    }

    onAboutToHide: {
        nameInput.text = "";
    }
}
