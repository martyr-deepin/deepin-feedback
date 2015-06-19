/*************************************************************
*File Name: TitleRow.qml
*Author: Match
*Email: Match.YangWanQing@gmail.com
*Created Time: 2015年06月19日 星期五 09时46分30秒
*Description:
*
*************************************************************/
import QtQuick 2.1

Item {
    width: parent.width
    height: 16

    Image {
        id: appIcon
        width: 16
        height: 16
        anchors.left: parent.left
        anchors.top: parent.top
        source: "qrc:///views/Widgets/images/deepin-feedback.png"
    }

    Text {
        id: appTitleText
        color: "#999999"
        font.pixelSize: 12
        text: dsTr("Deepin User Feedback")
        verticalAlignment: Text.AlignVCenter
        anchors {left: appIcon.right; leftMargin: 4; verticalCenter: appIcon.verticalCenter}
    }

}
