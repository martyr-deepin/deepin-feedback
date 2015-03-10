/*************************************************************
*File Name: AppTextInput.qml
*Author: Match
*Email: Match.YangWanQing@gmail.com
*Created Time: Mon 02 Feb 2015 02:51:14 PM CST
*Description:
*
*************************************************************/
import QtQuick 2.1
import Deepin.Widgets 1.0

Rectangle {
    id: root
    width: 200
    height: 40
    radius: 2
    color: bgNormalColor
    border.color: buttonBorderColor

    property alias tip: tipText.text
    property alias text: textInput.text

    signal textChange(string text)

    TextInput {
        id: textInput

        focus: true
        color: textNormalColor
        selectionColor: "#31536e"
        selectByMouse: true
        verticalAlignment: TextInput.AlignVCenter
        font.pixelSize: 13
        clip: true

        anchors.fill: parent
        anchors.leftMargin: 5

        onTextChanged: root.textChange(text)
    }

    Text {
        id: tipText
        anchors.fill: parent
        anchors.leftMargin: 5
        color: "#b9b6ba"
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 13
        clip: true

        opacity: textInput.text == "" ? 1 : 0

        Behavior on opacity {
            NumberAnimation {duration: 150}
        }
    }
}

