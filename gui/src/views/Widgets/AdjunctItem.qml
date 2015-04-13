/*************************************************************
*File Name: AdjunctItem.qml
*Author: Match
*Email: Match.YangWanQing@gmail.com
*Created Time: Tue 03 Feb 2015 03:11:47 PM CST
*Description:
*
*************************************************************/
import QtQuick 2.1
import Deepin.Widgets 1.0

Item {
    id: adjunctItem
    /*from model*****************************************/
    property bool show_icon_only: showIconOnly
    property string icon_path: show_icon_only ? iconPath : ""
    property string file_path: !show_icon_only ? filePath : ""
    property double load_percent: !show_icon_only ? loadPercent : 0
    /*from model*****************************************/

    signal deleteAdjunct(string filePath)

    Item {
        enabled: !show_icon_only
        visible: !show_icon_only
        width: parent.width
        height: parent.height
        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: deleteButton.visible = true
            onExited: deleteButton.visible = false
        }

        DIcon {
            id:fileIcon
            anchors.centerIn: parent

            height: 48
            width: 48
            theme: "Deepin"
            icon: dfcdAide.getIconName(file_path)

            Rectangle {
                anchors.centerIn: parent
                width: 40
                height: 40
                color: "#000000"
                opacity: 0.8
            }
        }


        DImageButton {
            id: deleteButton
            visible: false
            normal_image: "qrc:/views/Widgets/images/delete_normal.png"
            hover_image: "qrc:/views/Widgets/images/delete_hover.png"
            press_image: "qrc:/views/Widgets/images/delete_press.png"

            anchors.top: parent.top
            anchors.right: fileIcon.right
//            anchors.rightMargin: width / 2

            onClicked: adjunctItem.deleteAdjunct(file_path)

            onEntered: visible = true
            onExited: visible = false
        }

        PercentCircle {
            id: progressCir
            anchors.centerIn: parent
            lineWidth: 3
            width: 30
            height: 30

            Connections {
                target: adjunctItem
                onLoad_percentChanged: {
                    progressCir.updatePercentage(load_percent)
                }
            }
        }
    }

    Image {
        id:addIcon
        anchors.centerIn: parent
        height: 40
        width: 40
        source: icon_path
    }
}

