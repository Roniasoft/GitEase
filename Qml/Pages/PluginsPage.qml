import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import GitEase_Style
import GitEase_Style_Impl
import GitEase

/*!
 * PluginsPage
 * Responsive plugins page showing list of plugins.
 * - On open: fetches page 1 from the server and saves it as the initial state.
 * - Search: local results shown immediately; server results merged in on response.
 * - Cleared search: restores the saved initial state.
 * - Pagination: fetches the next page when the user scrolls to the bottom.
 */

Page {
    id: root

    /* Property Declarations
     * ****************************************************************************************/
    pageId: "plugins"
    title: "Plugins"
    icon: Style.icons.plugins

    property AppModel       appModel:           null
    property var            pluginController:   null

    readonly property var   defaultCategories: [
        { "color": "#60a5fa", "icon_url": "https://img.icons8.com/puffy-filled/32/warehouse-1.png", "id": "hosting", "name": "Hosting" },
        { "color": "#fbbf24", "icon_url": "https://img.icons8.com/fluency-systems-filled/48/apps-tab.png", "id": "workflow", "name": "Workflow" },
        { "color": "#4ADE80", "icon_url": "https://img.icons8.com/forma-bold/24/merge-git.png", "id": "merge", "name": "Merge" },
        { "color": "#d97706", "icon_url": "https://img.icons8.com/ios-filled/50/squiggly-line.png", "id": "inspection", "name": "Inspection" },
        { "color": "#a855f7", "icon_url": "https://img.icons8.com/ios-filled/50/electronic-brain.png", "id": "ai", "name": "AI" },
        { "color": "#F87171", "icon_url": "https://img.icons8.com/fluency-systems-filled/48/keyhole-shield.png", "id": "security", "name": "Security" }
    ]

    readonly property var   defaultPlugins: [
        { "id": "plug_013", "name": "AI Commit Writer", "description": "Generate high-quality commit messages instantly.", "author": "OpenAI Labs", "latest_version": "1.7.0", "min_app_version": "1.0.0", "size_kb": 1850, "icon_url": "https://img.icons8.com/glyph-neue/64/bard--v1.png", "release_date": "2026-06-14", "category": "ai", "downloads_count": 79100 },
        { "id": "plug_008", "name": "Conflict Resolver", "description": "Resolve merge conflicts using a visual editor.", "author": "Community", "latest_version": "1.6.1", "min_app_version": "1.0.0", "size_kb": 760, "icon_url": "https://img.icons8.com/ios-glyphs/30/conflict--v1.png", "release_date": "2026-04-07", "category": "merge", "downloads_count": 29980 },
        { "id": "plug_001", "name": "GitHub Hosting", "description": "Manage GitHub repositories, pull requests, and issues directly from GitEase.", "author": "GitEase", "latest_version": "2.0.1", "min_app_version": "1.0.0", "size_kb": 920, "icon_url": "https://img.icons8.com/glyph-neue/64/github.png", "release_date": "2026-06-01", "category": "hosting", "downloads_count": 54120 },
        { "id": "plug_011", "name": "Large File Detector", "description": "Find oversized files before committing.", "author": "Community", "latest_version": "1.0.9", "min_app_version": "1.0.0", "size_kb": 290, "icon_url": "https://img.icons8.com/ios-glyphs/30/skyscrapers.png", "release_date": "2026-05-02", "category": "inspection", "downloads_count": 15680 },
        { "id": "plug_020", "name": "Release Workflow", "description": "Automate tagging, changelogs, and release creation.", "author": "GitEase", "latest_version": "2.4.0", "min_app_version": "1.0.0", "size_kb": 1240, "icon_url": "https://img.icons8.com/ios-glyphs/30/code-fork.png", "release_date": "2026-06-18", "category": "workflow", "downloads_count": 33710 },
        { "id": "plug_016", "name": "Secret Scanner", "description": "Detect API keys and secrets before pushing.", "author": "Security Team", "latest_version": "2.1.0", "min_app_version": "1.0.0", "size_kb": 720, "icon_url": "https://img.icons8.com/material-rounded/24/password1.png", "release_date": "2026-06-09", "category": "security", "downloads_count": 46800 },
        { "id": "plug_004", "name": "Smart Workflow", "description": "Automate repetitive Git actions with custom workflows.", "author": "GitEase", "latest_version": "2.2.0", "min_app_version": "1.0.0", "size_kb": 840, "icon_url": "https://img.icons8.com/fluency-systems-filled/48/apps-tab.png", "release_date": "2026-06-12", "category": "workflow", "downloads_count": 42290 },
        { "id": "plug_014", "name": "Code Reviewer AI", "description": "Review code changes using AI suggestions.", "author": "OpenAI Labs", "latest_version": "1.5.3", "min_app_version": "1.0.0", "size_kb": 2140, "icon_url": "https://img.icons8.com/parakeet-filled/48/code.png", "release_date": "2026-05-11", "category": "ai", "downloads_count": 58230 },
        { "id": "plug_002", "name": "GitLab Integration", "description": "Browse projects and merge requests without leaving GitEase.", "author": "GitEase", "latest_version": "1.8.3", "min_app_version": "1.0.0", "size_kb": 1104, "icon_url": "https://img.icons8.com/windows/32/gitlab.png", "release_date": "2026-05-18", "category": "hosting", "downloads_count": 31250 },
        { "id": "plug_010", "name": "Repository Inspector", "description": "Analyze repository health and code quality.", "author": "GitEase", "latest_version": "2.3.0", "min_app_version": "1.0.0", "size_kb": 1520, "icon_url": "https://img.icons8.com/puffy-filled/32/check-file.png", "release_date": "2026-06-03", "category": "inspection", "downloads_count": 37450 }
    ]

    property var            pluginsData:        root.appModel ? root.appModel.plugins : root.defaultPlugins
    property var            categoriesData:     root.appModel ? root.appModel.pluginsCategories : root.defaultCategories
    property var            categoriesCounts:     ({})
    readonly property int   minCardWidth:       400
    readonly property int   minCardHeight:      250

    property string         currentMode:        ""
    property string         currentSearch:      ""
    property var            initialPlugins:     []   // full list from the last no-search fetch
    property bool           isSearchActive:     false
    property bool           fetchingMore:       false

    property var installedModel: [
        { name: "Enabled",      iconName: Style.icons.check,   iconColor: Style.colors.compatible },
        { name: "Disabled",     iconName: Style.icons.pause,   iconColor: "#363650" },
        { name: "Needs Update", iconName: Style.icons.warning, iconColor: Style.colors.warning }
    ]

    // Header exposed to MainWindow
    headerContent: Component {
        PluginsPageHeader {
            id: pluginsPageHeader
            onFilterRequested: (text, mode) => root.applyFilter(text, mode)
        }
    }

    /* Lifecycle
     * ****************************************************************************************/


    onPluginControllerChanged: refreshPlugins()

    onVisibleChanged: {
        if (visible)
            refreshPlugins()
    }

    onPluginsDataChanged: {
        // Save the full list as initial state whenever we are NOT in search mode
        if (!root.isSearchActive)
            root.initialPlugins = root.pluginsData ? root.pluginsData.slice() : []

        root.fetchingMore = false
        applyCurrentMode()
        buildCategoriesCounts()
    }

    onCategoriesDataChanged: {
        leftPanel.categoriesData = root.categoriesData.slice()
    }

    Component.onCompleted: {
        if (!root.appModel || !root.appModel.plugins || root.appModel.plugins.length === 0) {
            root.pluginsData = root.defaultPlugins
        }
        if (!root.appModel || !root.appModel.pluginsCategories || root.appModel.pluginsCategories.length === 0) {
            root.categoriesData = root.defaultCategories
        }
        applyCurrentMode()
        buildCategoriesCounts()
    }

    /* Children
     * ****************************************************************************************/
    EmptyStateView {
        title: "No plugins to show"
        details: "No plugins available at the moment"
        visible: pluginsModel.count === 0
    }

    // Debounce timer — fires the API search after the user stops typing
    Timer {
        id: searchDebounceTimer
        interval: 400
        repeat: false
        onTriggered: root.pluginController?.fetchAvailablePlugins(1, root.currentSearch)
    }

    ListModel {
        id: pluginsModel
    }

    RowLayout {
        anchors.fill: parent

        PluginsLeftPanel {
            id: leftPanel
            pluginsCount: root.pluginsData.length
            categoriesData: root.categoriesData
            installedModel: root.installedModel
            categoriesCounts: root.categoriesCounts

            onCategorySelected:  (category) => {
                pluginsModel.clear()
                for (var i = 0; i < root.pluginsData.length; i++) {
                    var plugin = root.pluginsData[i]

                    var matchesCategory = plugin.category === category || category === "All"

                    if (matchesCategory) pluginsModel.append(plugin)
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: Style.colors.obsidianDark

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: "INSTALLED"
                        color: "#363650"
                        font.pixelSize: Style.appFont.largePt
                        font.family: Style.fontTypes.roboto
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Style.colors.primaryBorder
                    }

                    Text {
                        text: "4 plugins"
                        color: "#363650"
                        font.pixelSize: Style.appFont.largePt
                        font.family: Style.fontTypes.roboto
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: "AVAILABLE"
                        color: "#363650"
                        font.pixelSize: Style.appFont.largePt
                        font.family: Style.fontTypes.roboto
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Style.colors.primaryBorder
                    }

                    Text {
                        text: "6 plugins"
                        color: "#363650"
                        font.pixelSize: Style.appFont.largePt
                        font.family: Style.fontTypes.roboto
                    }
                }

                GridView {
                    id: gridView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    model: pluginsModel

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    property int columns: Math.max(1, Math.floor(width / root.minCardWidth))

                    cellWidth: width / columns
                    cellHeight: root.minCardHeight

                    delegate: Item {
                        width: gridView.cellWidth
                        height: gridView.cellHeight

                        PluginCard {
                            anchors.centerIn: parent
                            width: gridView.cellWidth - 20
                            height: gridView.cellHeight - 20
                            plugin: model

                            onInstallClicked: function(pluginId) {
                                root.pluginController?.installPlugin(pluginId)
                            }
                            onUninstallClicked: function(pluginId) {
                                root.pluginController?.uninstallPlugin(pluginId)
                            }
                            onUpdateClicked: function(pluginId) {
                                root.pluginController?.updatePlugin(pluginId)
                            }
                            onEnableToggled: function(pluginId, enabled) {
                                root.pluginController?.togglePlugin(pluginId, enabled)
                            }
                        }
                    }

                    // Load next page when the user scrolls within one row of the bottom
                    onContentYChanged: {
                        if (contentHeight <= height)
                            return

                        if (contentY + height >= contentHeight - gridView.cellHeight
                                && !root.fetchingMore
                                && root.pluginController?.hasMorePages) {
                            root.loadNextPage()
                        }
                    }
                }

            }



        }
    }


    /* Functions
     * ****************************************************************************************/
    function applyFilter(text, mode) {
        root.currentMode = mode || ""

        if (text === root.currentSearch) {
            // Only mode changed — re-filter the current list locally
            applyCurrentMode()
            return
        }

        root.currentSearch = text

        if (text !== "") {
            root.isSearchActive = true

            // 1. Show local matches immediately for instant feedback
            const lower = text.toLowerCase()
            const localMatches = initialPlugins.filter(function(p) {
                return p.name.toLowerCase().indexOf(lower)        !== -1
                    || p.description.toLowerCase().indexOf(lower) !== -1
            })
            root.appModel.plugins = localMatches

            // 2. Debounce the API call so we merge in server results shortly after
            searchDebounceTimer.restart()
        } else {
            // Search cleared — restore the saved initial state
            root.isSearchActive = false
            searchDebounceTimer.stop()
            root.appModel.plugins = initialPlugins.slice()
        }
    }

    function loadNextPage() {
        if (!root.pluginController || root.fetchingMore || !root.pluginController.hasMorePages)
            return

        root.fetchingMore = true
        root.pluginController.fetchNextPage(root.pluginController.currentPage + 1, currentSearch)
    }

    function refreshPlugins() {
        if (!root.pluginController)
            return

        root.isSearchActive = false
        root.currentSearch  = ""
        root.currentMode    = ""
        root.pluginController.fetchPluginsCategories()
    }

    // Refills pluginsModel from appModel.plugins, applying the active mode filter.
    function applyCurrentMode() {
        pluginsModel.clear()

        if (!root.pluginsData)
            return

        for (var i = 0; i < root.pluginsData.length; i++) {
            var plugin = root.pluginsData[i]

            var matchesMode = currentMode === ""
                || (currentMode === "Installed" && plugin.isInstalled)
                || (currentMode === "Enabled"   && plugin.isEnabled)
                || (currentMode === "Available"  && !plugin.isInstalled)

            if (matchesMode)
                pluginsModel.append(plugin)
        }
    }

    function buildCategoriesCounts() {
        let counts = {}

        // Initialize all categories to 0
        for (const category of root.categoriesData)
            counts[category.id] = 0

        // Count plugins
        for (const plugin of root.pluginsData) {
            if (!counts.hasOwnProperty(plugin.category))
                counts[plugin.category] = 0

            counts[plugin.category]++
        }

        root.categoriesCounts = counts
    }
}
