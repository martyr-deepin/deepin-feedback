/*************************************************************
*File Name: TextButton.qml
*Author: Match
*Email: Match.YangWanQing@gmail.com
*Created Time: Tue 03 Feb 2015 10:26:21 AM CST
*Description:
*
*************************************************************/
import QtQuick 2.1

ButtonFrame {
    width: 60
    height: 30

    property alias textItem: text_item
    property alias text: text_item.text

    onEntered: {
        text_item.color = "#000000"
    }
    onExited: {
        text_item.color = textNormalColor
    }

    Text {
        id:text_item
        anchors.centerIn: parent
        width: contentWidth + 40
        height: contentHeight
        wrapMode: Text.Wrap
        color: textNormalColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 13
        clip: true
    }
}

