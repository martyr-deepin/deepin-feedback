import QtQuick 2.2
import Deepin.Widgets 1.0
import "Widgets"


Row {
    id:windowButtonRow
    anchors.top:parent.top
    anchors.right: parent.right
    state: "zoomin"

    DImageButton {
        id:minimizeButton
        normal_image: "qrc:/views/Widgets/images/minimise_normal.png"
        hover_image: "qrc:/views/Widgets/images/minimise_hover.png"
        press_image: "qrc:/views/Widgets/images/minimise_press.png"
        onClicked: {
            mainWindow.showMinimized()
        }
    }

    DImageButton {
        id:maximizeButton
        normal_image: "qrc:/views/Widgets/images/%1_normal.png".arg(windowButtonRow.state)
        hover_image: "qrc:/views/Widgets/images/%1_hover.png".arg(windowButtonRow.state)
        press_image: "qrc:/views/Widgets/images/%1_press.png".arg(windowButtonRow.state)
        onClicked: {
            windowButtonRow.state = windowButtonRow.state == "zoomin" ? "zoomout" : "zoomin"
        }
    }

    DImageButton {
        id:closeWindowButton
        normal_image: "qrc:/views/Widgets/images/close_normal.png"
        hover_image: "qrc:/views/Widgets/images/close_hover.png"
        press_image: "qrc:/views/Widgets/images/close_press.png"
        onClicked: {
            saveDraft()
            mainWindow.close()
            Qt.quit()
        }
    }

    states: [
        State {
            name: "zoomout"
            PropertyChanges {target: mainWindow; width: maxWidth; height: maxHeight}
        },
        State {
            name: "zoomin"
            PropertyChanges {target: mainWindow; width: normalWidth; height: normalHeight}
        }
    ]

//            transitions:[
//                Transition {
//                    from: "zoomout"
//                    to: "zoomin"
//                     SequentialAnimation {
//                        NumberAnimation {target: mainWindow;property: "width";duration: animationDuration;easing.type: Easing.OutCubic}
//                        NumberAnimation {target: mainWindow;property: "height";duration: animationDuration;easing.type: Easing.OutCubic}
//                    }
//                },
//                Transition {
//                    from: "zoomin"
//                    to: "zoomout"
//                     SequentialAnimation {
//                        NumberAnimation {target: mainWindow;property: "width";duration: animationDuration;easing.type: Easing.OutCubic}
//                        NumberAnimation {target: mainWindow;property: "height";duration: animationDuration;easing.type: Easing.OutCubic}
//                    }
//                }
//            ]
}
