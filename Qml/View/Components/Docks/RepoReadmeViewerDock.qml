import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import GitEase
import GitEase_Style
import GitEase_Style_Impl

/*! ***********************************************************************************************
 * RebaseDock
 * ************************************************************************************************/

UtilitiesCard {
    id: root

    /* Property Declarations
     * ****************************************************************************************/
    property RepositoryController repoController: null
    property string markdownText: ""

    /* Object Properties
     * ****************************************************************************************/
    title: "README Preview"
    icon: Style.icons.file

    content: ScrollView {

        TextArea {
            readOnly: true
            wrapMode: TextEdit.Wrap
            textFormat: TextEdit.MarkdownText
            text: root.markdownText
        }
    }
}
