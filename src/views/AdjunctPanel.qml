/*************************************************************
*File Name: AdjunctPanel.qml
*Author: Match
*Email: Match.YangWanQing@gmail.com
*Created Time: Mon 02 Feb 2015 05:06:16 PM CST
*Description:
*
*************************************************************/
import QtQuick 2.1
import Deepin.Widgets 1.0
import "Widgets"

Item {
    id: adjunctPanel

    property alias contentText: contentTextEdit.text

    function clearAllAdjunct(){
        adjunctTray.clearAllAdjunct()
    }

    function getAdjunct(filePath){
        var targetPath = mainObject.addAdjunct(filePath, appComboBox.text.trim())
        if (targetPath == ""){
            print ("==>[Info] Adjunct already exist or got adjunct error")
            return
        }

        adjunctTray.addAdjunct(targetPath)
    }

    function addAdjunct(filePath){
        adjunctTray.addAdjunct(filePath)
    }

    function setContentText(value){
        contentTextEdit.text = value
    }

    function updateLoadPercent(filePath, percent){
        adjunctTray.updateLoadPercent(filePath, percent)
    }

    DFileChooseDialog {
        id: adjunctPickDialog
        currentFolder: mainObject.getHomeDir()
        onSelectAction: {
            getAdjunct(fileUrl.toString())

            adjunctPickDialog.hideWindow()
        }
    }

    Row {
        id: buttonRow
        anchors.left: parent.left
        anchors.top: parent.top
        width: childrenRect.width
        height: 22
        enabled: adjunctTray.adjunctModel.count < maxAdjunctCount

        spacing: 3

        DImageButton {
            id:screenShotButton
            width: 22
            height: 22
            normal_image: "qrc:/views/Widgets/images/screenshot_normal.png"
            hover_image: "qrc:/views/Widgets/images/screenshot_normal.png"
            press_image: "qrc:/views/Widgets/images/screenshot_press.png"
            onClicked: {
                if (appComboBox.text != "" && supportAppList.indexOf(appComboBox.text) != -1)
                    mainObject.getScreenShot(appComboBox.text.trim())
            }
        }

        DImageButton {
            id:adjunctButton
            width: 22
            height: 22
            normal_image: "qrc:/views/Widgets/images/adjunct_normal.png"
            hover_image: "qrc:/views/Widgets/images/adjunct_normal.png"
            press_image: "qrc:/views/Widgets/images/adjunct_press.png"
            onClicked: {
                if (appComboBox.text != "" && supportAppList.indexOf(appComboBox.text) != -1){
                    adjunctPickDialog.showWindow()
                }
            }
        }
    }

    Rectangle {
        id: adjunctRec

        radius: 2
        color: bgNormalColor
        border.color: buttonBorderColor
        width: parent.width
        height: parent.height - buttonRow.height
        anchors.top: buttonRow.bottom
        anchors.topMargin: 6

        TextEdit {
            id: contentTextEdit
            color: textNormalColor
            selectionColor: "#31536e"
            selectByMouse: true
            font.pixelSize: 13
            width: parent.width
            height: parent.height - adjunctTray.height
            anchors.top: parent.top
        }

        AdjunctTray {
            id: adjunctTray
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 1
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 2
            height: 52
        }
    }

    Connections {
        target: mainObject
        onGetScreenshotFinish: {
            getAdjunct(fileName)
        }
    }
}

