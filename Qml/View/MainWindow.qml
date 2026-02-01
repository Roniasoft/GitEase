import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import GitEase_Style
import GitEase_Style_Impl
import GitEase

/*! ***********************************************************************************************
 * MainWindow
 * ************************************************************************************************/
Rectangle {
    id: root

    /* Property Declarations
     * ****************************************************************************************/
    property UiSession uiSession: null

    /* Object Properties
     * ****************************************************************************************/
    color: Style.colors.primaryBackground


    /* Children
     * ****************************************************************************************/
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        //Header
        Header {
            Layout.fillHeight: true
            Layout.fillWidth: true

            content: (pageLoader.item && pageLoader.item.hasOwnProperty("headerContent")) ? pageLoader.item.headerContent : null
        }

        // Design Mode Banner
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            visible: root.uiSession?.appModel?.appSettings?.appearanceSettings?.designPagesLayout ?? false
            color: Qt.rgba(Style.colors.accent.r, Style.colors.accent.g, Style.colors.accent.b, 0.15)
            Layout.leftMargin: 4
            Layout.topMargin: 1
            Layout.rightMargin: 4
            Layout.bottomMargin: 1
            radius: 3
            border.color: Style.colors.accent
            border.width: 1
            
            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 3
                    Layout.preferredHeight: 18
                    color: Style.colors.accent
                    radius: 2
                }

                Text {
                    Layout.fillWidth: true
                    text: "Designing Pages Layout"
                    font.pixelSize: 12
                    color: Style.colors.foreground
                    verticalAlignment: Text.AlignVCenter
                }

                Item { Layout.fillWidth: true }

                Button {
                    implicitHeight: 24
                    topInset: 0
                    bottomInset: 0
                    topPadding: 0
                    bottomPadding: 0
                    text: "Cancel"
                    font.pixelSize: 11
                    hoverEnabled: true
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: Style.colors.foreground
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.centerIn: parent
                    }
                    background: Rectangle {
                        implicitWidth: 80
                        implicitHeight: 24
                        color: parent.down ? Qt.darker(Style.colors.secondaryBackground, 1.15) : (parent.hovered ? Qt.lighter(Style.colors.secondaryBackground, 1.1) : Style.colors.secondaryBackground)
                        border.color: Qt.darker(Style.colors.secondaryBackground, 1.2)
                        border.width: 1
                        radius: 4
                    }
                    onClicked: {
                        root.uiSession.appModel.appSettings.appearanceSettings.designPagesLayout = false
                    }
                }

                Button {
                    implicitHeight: 24
                    topInset: 0
                    bottomInset: 0
                    topPadding: 0
                    bottomPadding: 0
                    text: "Set Default"
                    font.pixelSize: 11
                    hoverEnabled: true
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: Style.colors.foreground
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.centerIn: parent
                    }
                    background: Rectangle {
                        implicitWidth: 100
                        implicitHeight: 24
                        color: parent.down ? Qt.darker(Style.colors.secondaryBackground, 1.15) : (parent.hovered ? Qt.lighter(Style.colors.secondaryBackground, 1.1) : Style.colors.secondaryBackground)
                        border.color: Qt.darker(Style.colors.secondaryBackground, 1.2)
                        border.width: 1
                        radius: 4
                    }
                    onClicked: {
                        // Reset to default logic here
                    }
                }

                Button {
                    implicitHeight: 24
                    topInset: 0
                    bottomInset: 0
                    topPadding: 0
                    bottomPadding: 0
                    text: "Save"
                    font.pixelSize: 11
                    hoverEnabled: true
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: Style.colors.secondaryForeground
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.centerIn: parent
                    }
                    background: Rectangle {
                        implicitWidth: 80
                        implicitHeight: 24
                        color: parent.down ? Qt.darker(Style.colors.accent, 1.15) : (parent.hovered ? Qt.lighter(Style.colors.accent, 1.15) : Style.colors.accent)
                        border.width: 0
                        radius: 4
                    }
                    onClicked: {
                        // TODO Save Layout
                        root.uiSession.appModel.appSettings.appearanceSettings.designPagesLayout = false
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            NavigationRail {
                id: navigationRail
                Layout.fillHeight: true

                appModel: root.uiSession?.appModel
                pageController: root.uiSession?.pageController
                repositoryController: root.uiSession?.repositoryController
                userProfileController: root.uiSession?.userProfileController
                onNewRepositoryRequested: function () {
                    let popup = root.uiSession?.popups?.repositorySelectorPopup
                    popup.repositoryController = Qt.binding(function () {return uiSession.repositoryController})
                    popup.recentRepositories = Qt.binding(function () {return uiSession.appModel.recentRepositories})
                    popup.appModel = Qt.binding(function () {return uiSession.appModel})
                    popup.open()
                }
                onOpenSettingsRequested: {
                    let settingsPopup = root.uiSession?.popups?.settingsPopup
                    settingsPopup.appModel = root.uiSession.appModel
                    settingsPopup.fileIO = root.uiSession.appModel.fileIO
                    settingsPopup.open()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 4
                Layout.rightMargin: 4
                Layout.leftMargin: 4
                Layout.bottomMargin: 4

                color: Style.colors.primaryBackground
                radius: 6

                SwipeView {
                    id: pageSwipeView
                    anchors.fill: parent
                    clip: true
                    interactive: false

                    Repeater {
                        model: root.uiSession?.appModel?.pages || []

                        Loader {
                            width: pageSwipeView.width
                            height: pageSwipeView.height

                            active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                            asynchronous: true

                            source: modelData?.source ?? ""

                            onLoaded: {
                                if (!item)
                                    return

                                // Bind common context properties if the loaded page exposes them.
                                if (item.hasOwnProperty("page")) {
                                    // Bind to the page model represented by this SwipeView index.
                                    item.page = Qt.binding(function() { return modelData })
                                }

                                if (item.hasOwnProperty("appModel")) {
                                    item.appModel = Qt.binding(function() { return root.uiSession?.appModel })
                                }
                                if (item.hasOwnProperty("branchController")) {
                                    item.branchController = Qt.binding(function() { return root.uiSession?.branchController })
                                }
                                if (item.hasOwnProperty("commitController")) {
                                    item.commitController = Qt.binding(function() { return root.uiSession?.commitController })
                                }
                                if (item.hasOwnProperty("statusController")) {
                                    item.statusController = Qt.binding(function() { return root.uiSession?.statusController })
                                }
                                if (item.hasOwnProperty("repositoryController")) {
                                    item.repositoryController = Qt.binding(function() { return root.uiSession?.repositoryController })
                                }
                                if (item.hasOwnProperty("remoteController")) {
                                    item.remoteController = Qt.binding(function() { return root.uiSession?.remoteController })
                                }
                                if (item.hasOwnProperty("userProfileController")) {
                                    item.userProfileController = Qt.binding(function() { return root.uiSession?.userProfileController })
                                }
                                if (item.hasOwnProperty("bundleController")) {
                                    item.bundleController = Qt.binding(function() { return root.uiSession?.bundleController })
                                }
                                if (item.hasOwnProperty("userAuthenticationPopup")) {
                                    item.userAuthenticationPopup = Qt.binding(function() { return root.uiSession?.popups?.userAuthenticationPopup })
                                }
                            }

                            onStatusChanged: {
                                if (status === Loader.Error)
                                    console.error("[MainWindow] Failed to load page:", source)
                            }
                        }
                    }

                    onCurrentIndexChanged: {
                        if (!contentItem)
                            return

                        contentItem.contentX = currentIndex * width
                    }

                    Connections {
                        target: root.uiSession?.appModel ?? null

                        function onCurrentPageChanged() {
                            pageSwipeView.currentIndex = root.uiSession?.appModel?.currentPage.pageIndex ?? 0
                        }
                    }
                }
            }
        }
    }
}
