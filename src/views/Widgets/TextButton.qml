/*************************************************************
*File Name: TextButton.qml
*Author: Match
*Email: Match.YangWanQing@gmail.com
*Created Time: Tue 03 Feb 2015 10:26:21 AM CST
*Description:
*
*************************************************************/
import QtQuick 2.1

Rectangle {
    width: 60
    height: 30
    radius: 2
    color: bgNormalColor
    border.color: buttonBorderColor

    property alias textItem: text_item
    property alias text: text_item.text

    signal entered()
    signal exited()
    signal clicked()

    Text {
        id:text_item
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        wrapMode: Text.Wrap
        color: textNormalColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 13
        clip: true

    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            parent.entered()
        }

        onExited: {
            parent.exited()
        }

        onClicked: {
            parent.clicked()
        }
    }
}

