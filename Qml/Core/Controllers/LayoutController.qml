import QtQuick
import GitEase

/*! ***********************************************************************************************
 * LayoutController
 * Manages page dock layouts with persistence (save/load/restore).
 * Tracks dock positions and TabGroupSide sizes for each page.
 * ************************************************************************************************/

QtObject {
    id: root

    /* Property Declarations
     * ****************************************************************************************/
    readonly property string filename: "layouts.json"
    required property var appModel
    
    property var pageLayoutMap: ({})  // Maps pageId -> layout config
    property var layoutBackup: null   // For cancel/restore operations

    /* Functions
     * ****************************************************************************************/
    /**
     * Register/update layout for a page
     */
    function registerPageLayout(pageId, leftDocks, topDocks, rightDocks, bottomDocks, 
                                leftSize, topSize, rightSize, bottomSize) {
        if (!pageId) {
            console.warn("[LayoutController] Invalid pageId")
            return
        }
        
        pageLayoutMap[pageId] = {
            left:{
                dockTitles: getDockTitles(leftDocks),
                preferredSize: leftSize || 300
            },
            top:{
                dockTitles: getDockTitles(topDocks),
                preferredSize: topSize || 180
            },
            right:{
                dockTitles: getDockTitles(rightDocks),
                preferredSize: rightSize || 300
            },
            bottom:{
                dockTitles: getDockTitles(bottomDocks),
                preferredSize: bottomSize || 180
            }
        }
    }
    
    /**
     * Retrieve layout for a page
     */
    function getPageLayout(pageId) {
        return pageLayoutMap[pageId] || null
    }

    /**
     * Save layouts to disk
     */
    function saveLayouts() {
        if (!root.appModel?.pages || !root.appModel?.fileIO) {
            return false
        }

        try {
            const layoutData = serializeAllLayouts()
            const filePath = `${root.appModel.fileIO.configFilePath}/${root.filename}`
            
            root.appModel.fileIO.fileName = filePath
            root.appModel.fileIO.fileContent = JSON.stringify(layoutData, null, 2)
            root.appModel.fileIO.write()
            
            layoutBackup = null
            return true
        } catch (error) {
            console.error("[LayoutController] Save failed:", error)
            return false
        }
    }

    /**
     * Load layouts from disk
     */
    function loadLayouts() {
        if (!appModel?.fileIO) {
            console.warn("[LayoutController] FileIO not available")
            return false
        }

        try {
            const filePath = `${appModel.fileIO.configFilePath}/${filename}`
            
            if (!appModel.fileIO.isFileExist(filePath)) {
                console.log("[LayoutController] No saved layouts found")
                return true
            }

            appModel.fileIO.fileName = filePath
            appModel.fileIO.read()
            
            const content = appModel.fileIO.fileContent?.trim()
            if (!content) {
                console.warn("[LayoutController] Empty layouts file")
                return true
            }

            const data = JSON.parse(content)
            const layouts = data.layouts || []
            
            layouts.forEach(layout => {
                if (layout.pageId && layout.tabGroups) {
                    pageLayoutMap[layout.pageId] = layout.tabGroups
                }
            })

            return true
        } catch (error) {
            console.error("[LayoutController] Load failed:", error)
            return false
        }
    }

    /**
     * Save current state as default
     */
    function setDefaultLayouts() {
        return saveLayouts()
    }

    /**
     * Create backup for restore
     */
    function createBackup() {
        try {
            layoutBackup = JSON.parse(JSON.stringify(pageLayoutMap))
        } catch (error) {
            console.error("[LayoutController] Backup failed:", error)
        }
    }

    /**
     * Restore from backup
     */
    function restoreFromBackup() {
        if (!layoutBackup) {
            console.warn("[LayoutController] No backup available")
            return false
        }

        try {
            pageLayoutMap = JSON.parse(JSON.stringify(layoutBackup))
            layoutBackup = null
            return true
        } catch (error) {
            console.error("[LayoutController] Restore failed:", error)
            return false
        }
    }

    function getDockTitles(docks) {
        if (!Array.isArray(docks)) return []
        return docks.filter(d => d?.title).map(d => d.title)
    }
    
    function serializeAllLayouts() {
        const pages = appModel?.pages || []
        const layouts = pages.map(page => ({
            pageId: page.id || "",
            pageTitle: page.title || "",
            tabGroups: pageLayoutMap[page.id] || {
                left:   { dockTitles: [], preferredSize: 300 },
                top:    { dockTitles: [], preferredSize: 180 },
                right:  { dockTitles: [], preferredSize: 300 },
                bottom: { dockTitles: [], preferredSize: 180 }
            }
        }))
        
        return {
            version: "1.0",
            layouts: layouts
        }
    }

    Component.onCompleted: loadLayouts()
}


