import QtQuick
import QtQuick.Controls

import GitEase
import GitEase_Style
import GitEase_Style_Impl

/*! ***********************************************************************************************
 * DockAblePage
 * Page with dockable panels arranged in four sides (left/top/right/bottom).
 * Supports drag-drop repositioning, layout persistence, and dynamic resizing.
 * ************************************************************************************************/

Item {
    id: root

    /* Property Declarations
     * ****************************************************************************************/
    property var page: null
    property var layoutController: null
    property var docks: []

    property var leftSideTabGroupDocks:   []
    property var topSideTabGroupDocks:    []
    property var rightSideTabGroupDocks:  []
    property var bottomSideTabGroupDocks: []

    property bool showDropZone: false
    property bool layoutIsEditing: false
    property var activeDraggingDock: null
    property int hoveredDockPosition: -1

    readonly property real defaultWidth: 300
    readonly property real defaultHeight: 180

    /* Signal Handlers
     * ****************************************************************************************/
    onDocksChanged: updateSideDocks()
    
    onLeftSideTabGroupDocksChanged:   registerDocks()
    onTopSideTabGroupDocksChanged:    registerDocks()
    onRightSideTabGroupDocksChanged:  registerDocks()
    onBottomSideTabGroupDocksChanged: registerDocks()

    onLayoutControllerChanged: applyLoadedLayout()
    onPageChanged: applyLoadedLayout()

    onLayoutIsEditingChanged: {
        docks.forEach(dock => { dock.layoutIsEditing = layoutIsEditing })
    }

    onShowDropZoneChanged: {
        if (!showDropZone) {
            hoveredDockPosition = -1
            activeDraggingDock = null
        }
    }
    
    
    function registerDocks() {
        if (!layoutController || !page)
            return
        
        layoutController.registerPageLayout(
            page.id,
            leftSideTabGroupDocks,
            topSideTabGroupDocks,
            rightSideTabGroupDocks,
            bottomSideTabGroupDocks,
            leftTabGroup.preferredSize,
            topTabGroup.preferredSize,
            rightTabGroup.preferredSize,
            bottomTabGroup.preferredSize
        )
    }
    
    function applyLoadedLayout() {
        if (!layoutController || !page)
            return
        
        const savedLayout = layoutController.getPageLayout(page.id)
        if (!savedLayout)
            return
        
        leftTabGroup.preferredSize   = savedLayout.left?.preferredSize   || defaultWidth
        topTabGroup.preferredSize    = savedLayout.top?.preferredSize    || defaultHeight
        rightTabGroup.preferredSize  = savedLayout.right?.preferredSize  || defaultWidth
        bottomTabGroup.preferredSize = savedLayout.bottom?.preferredSize || defaultHeight
        
        restoreDockPositions(savedLayout)
    }
    
    function restoreDockPositions(savedLayout) {
        // Build dock lookup map
        const dockMap = {}
        docks.forEach(dock => {
            if (dock?.title) dockMap[dock.title] = dock
        })
        
        // Find target position for each dock
        const positionMap = {
            [Enums.DockPosition.Left]:   savedLayout.left?.dockTitles   || [],
            [Enums.DockPosition.Top]:    savedLayout.top?.dockTitles    || [],
            [Enums.DockPosition.Right]:  savedLayout.right?.dockTitles  || [],
            [Enums.DockPosition.Bottom]: savedLayout.bottom?.dockTitles || []
        }
        
        // Apply positions or close unsaved docks
        Object.keys(dockMap).forEach(title => {
            const dock = dockMap[title]
            let targetPosition = -1
            
            for (const [position, titles] of Object.entries(positionMap)) {
                if (titles.includes(title)) {
                    targetPosition = parseInt(position)
                    break
                }
            }
            
            if (targetPosition >= 0) {
                if (dock.position !== targetPosition) {
                    dock.position = targetPosition
                    dock.isFloating = false
                }
            } else {
                closeDock(dock.dockId)
            }
        })
        
        updateSideDocks()
        registerDocks()
    }

    /* UI Components
     * ****************************************************************************************/
    
    PageDropZone {
        id: pageDropZone
        anchors.fill: parent
        visible: showDropZone
        opacity: 0.7
        z: 9
        defaultWidth: root.defaultWidth * 0.6
        defaultHeight: root.defaultHeight * 0.6
        activePosition: hoveredDockPosition
    }

    Timer {
        id: dropZoneHoverTimer
        interval: 16
        repeat: true
        running: showDropZone && activeDraggingDock
        onTriggered: updateHoveredDockPosition()
    }

    Row {
        anchors.fill: parent
        spacing: 1

        // Left Side
        Item {
            id: leftColumn
            width: leftSideTabGroupDocks.length > 0 ? leftTabGroup.preferredSize : 0
            height: parent.height

            TabGroupSide {
                id: leftTabGroup
                anchors.fill: parent
                position: Enums.DockPosition.Left
                docks: leftSideTabGroupDocks
                isEditing: layoutIsEditing
                minPreferredSize: 160
                maxPreferredSize: Math.max(minPreferredSize, 
                    root.width - (rightSideTabGroupDocks.length > 0 ? rightTabGroup.preferredSize : 0))
                onPreferredSizeChanged: registerDocks()
            }
        }

        // Center Column
        Column {
            width: parent.width - leftColumn.width - rightColumn.width
            height: parent.height
            spacing: 1

            // Top Side
            Item {
                id: topArea
                width: parent.width
                height: topSideTabGroupDocks.length > 0 ? topTabGroup.preferredSize : 0

                TabGroupSide {
                    id: topTabGroup
                    anchors.fill: parent
                    position: Enums.DockPosition.Top
                    docks: topSideTabGroupDocks
                    isEditing: layoutIsEditing
                    minPreferredSize: 120
                    maxPreferredSize: Math.max(minPreferredSize, 
                        root.height - (bottomSideTabGroupDocks.length > 0 ? bottomTabGroup.preferredSize : 0))
                    onPreferredSizeChanged: registerDocks()
                }
            }

            // Center Content Area
            Item {
                id: centerArea
                width: parent.width
                height: parent.height - topArea.height - bottomArea.height

                Label {
                    anchors.centerIn: parent
                    visible: docks.length === 0 && parent.height > 50
                    text: "No Docks Open"
                    color: "#a0a0a0"
                    font.pointSize: Style.appFont.h3Pt
                    font.bold: true
                }
            }

            // Bottom Side
            Item {
                id: bottomArea
                width: parent.width
                height: bottomSideTabGroupDocks.length > 0 ? bottomTabGroup.preferredSize : 0

                TabGroupSide {
                    id: bottomTabGroup
                    anchors.fill: parent
                    position: Enums.DockPosition.Bottom
                    docks: bottomSideTabGroupDocks
                    isEditing: layoutIsEditing
                    minPreferredSize: 120
                    maxPreferredSize: Math.max(minPreferredSize, 
                        root.height - (topSideTabGroupDocks.length > 0 ? topTabGroup.preferredSize : 0))
                    onPreferredSizeChanged: registerDocks()
                }
            }
        }

        // Right Side
        Item {
            id: rightColumn
            width: rightSideTabGroupDocks.length > 0 ? rightTabGroup.preferredSize : 0
            height: parent.height

            TabGroupSide {
                id: rightTabGroup
                anchors.fill: parent
                position: Enums.DockPosition.Right
                docks: rightSideTabGroupDocks
                isEditing: layoutIsEditing
                minPreferredSize: 160
                maxPreferredSize: Math.max(minPreferredSize, 
                    root.width - (leftSideTabGroupDocks.length > 0 ? leftTabGroup.preferredSize : 0))
                onPreferredSizeChanged: registerDocks()
            }
        }
    }

     * ****************************************************************************************/
    
    /**
     * Redistribute docks into side arrays based on their position
     */
    function updateSideDocks() {
        const sides = {
            [Enums.DockPosition.Left]: [],
            [Enums.DockPosition.Top]: [],
            [Enums.DockPosition.Right]: [],
            [Enums.DockPosition.Bottom]: []
        }

        docks.forEach(dock => {
            if (sides[dock.position]) {
                sides[dock.position].push(dock)
            }
        })

        leftSideTabGroupDocks   = sides[Enums.DockPosition.Left]
        topSideTabGroupDocks    = sides[Enums.DockPosition.Top]
        rightSideTabGroupDocks  = sides[Enums.DockPosition.Right]
        bottomSideTabGroupDocks = sides[Enums.DockPosition.Bottom]
    }

    /**
     * Move dock based on its current drag position
     */
    function moveDock(dockId) {
        const dock = docks.find(d => d.dockId === dockId)
        if (!dock) {
            console.warn("[DockAblePage] Dock not found:", dockId)
            return
        }

        const globalPos = dock.mapToGlobal(dock.width / 3, 15)
        const pagePos = mapFromGlobal(globalPos.x, globalPos.y)
        dock.position = getDropPosition(pagePos.x, pagePos.y)
        
        updateSideDocks()
    }

    /**
     * Update hovered position during drag
     */
    function updateHoveredDockPosition() {
        if (!activeDraggingDock)
            return

        const globalPos = activeDraggingDock.mapToGlobal(activeDraggingDock.width / 3, 15)
        const pagePos = mapFromGlobal(globalPos.x, globalPos.y)
        hoveredDockPosition = getDropPosition(pagePos.x, pagePos.y)
    }

    /**
     * Calculate drop position based on coordinates
     */
    function getDropPosition(x, y) {
        if (x < defaultWidth)
            return Enums.DockPosition.Left
        if (x > width - defaultWidth)
            return Enums.DockPosition.Right
        if (y < defaultHeight)
            return Enums.DockPosition.Top
        if (y > height - defaultHeight)
            return Enums.DockPosition.Bottom
        return -1
    }

    /**
     * Close and destroy a dock
     */
    function closeDock(dockId) {
        const index = docks.findIndex(d => d.dockId === dockId)
        if (index === -1) {
            console.warn("[DockAblePage] Dock not found:", dockId)
            return
        }

        const dock = docks[index]
        docks = docks.slice(0, index).concat(docks.slice(index + 1))
        dock.destroy()
    }
}
