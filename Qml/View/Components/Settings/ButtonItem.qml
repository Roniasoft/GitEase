import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import GitEase_Style
import GitEase_Style_Impl
import GitEase

/*! ***********************************************************************************************
 * ButtonItem
 * ************************************************************************************************/
RowLayout {
    id: root

    /* Property Declarations
     * ****************************************************************************************/
    property     string            title:       ""

    property     string            description: ""

    property     string            buttonText:  "Button"

    /* Signals
     * ****************************************************************************************/
    signal clicked()

    /* Children
     * ****************************************************************************************/
    ColumnLayout {
        Layout.fillWidth: true

        Text {
            Layout.fillWidth: true
            text: root.title
            font.pointSize: Style.appFont.h4Pt
            color: Style.colors.foreground
        }

        Text {
            Layout.fillWidth: true
            text: root.description
            font.pointSize: Style.appFont.secondaryPt
            color: Style.colors.mutedText
        }
    }

    Button {
        Material.accent: Style.colors.accent
        Material.background: Style.colors.accent
        Material.foreground: Style.colors.secondaryForeground

        contentItem: Text {
            text: root.buttonText
            font.family: Style.fontTypes.roboto
            color: Style.colors.secondaryForeground
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            radius: 3
            color: Style.colors.accent
        }

        onClicked: root.clicked()
    }
}
