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
    property string file_path: filePath
    property double load_percent: loadPercent
    /*from model*****************************************/

    signal deleteAdjunct(string filePath)

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
        normal_image: "qrc:/views/Widgets/images/delete_normal.png"
        hover_image: "qrc:/views/Widgets/images/delete_hover.png"
        press_image: "qrc:/views/Widgets/images/delete_press.png"

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: width / 2

        onClicked: adjunctItem.deleteAdjunct(file_path)
    }

    PercentCircle {
        anchors.centerIn: parent
        lineWidth: 3
        width: 30
        height: 30

        Component.onCompleted: updatePercentage(0.6)
    }
}

