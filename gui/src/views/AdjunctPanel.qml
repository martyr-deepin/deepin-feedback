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
import QtQuick.Dialogs 1.1
import DataConverter 1.0
import "Widgets"

Item {
    id: adjunctPanel

    property alias backgroundColor: adjunctRec.color
    property alias contentText: contentTextEdit.text
    property bool canAddAdjunct: adjunctTray.adjunctModel.count < maxAdjunctCount && enableInput
    property bool showAddAdjunct: false
    property int addingCount: 0
    property bool warning: false

    function clearAllAdjunct(){
        adjunctTray.clearAllAdjunct()
    }

    function getAdjunct(filePath){
        var targetPath = mainObject.addAdjunct(filePath, getProjectIDByName(appComboBox.text.trim()))
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

    function showAddAdjunctIcon(count){
        showAddAdjunct = true
        adjunctTray.showAddIcon(count)
        addingCount = count
    }

    function hideAddAdjunctIcon(){
        showAddAdjunct = false
        adjunctTray.hideAddIcon(addingCount)
        addingCount = 0
    }

    FileDialog {
        id: adjunctPickDialog
        title: dsTr("Please select attachment")
        onAccepted: {
            getAdjunct(adjunctPickDialog.fileUrl.toString().replace("file:///","/"))
            close()
        }
        nameFilters: [ "All files (*)" ,"Image files (*.jpg *.png *.gif)"]
    }

//    DFileChooseDialog {
//        id: adjunctPickDialog
//        currentFolder: mainObject.getHomeDir()
//        onSelectAction: {
//            print ("========",fileUrl.toString())
//            getAdjunct(fileUrl.toString())

//            adjunctPickDialog.hideWindow()
//        }
//    }

    Row {
        id: buttonRow
        anchors.left: parent.left
        anchors.top: parent.top
        width: childrenRect.width
        height: 22

        spacing: 3

        DImageButton {
            id:screenShotButton
            width: 22
            height: 22
            normal_image: "qrc:/views/Widgets/images/screenshot_%1.png".arg(canAddAdjunct ? "normal" : "disable")
            hover_image: "qrc:/views/Widgets/images/screenshot_%1.png".arg(canAddAdjunct ? "press" : "disable")
            press_image: "qrc:/views/Widgets/images/screenshot_%1.png".arg(canAddAdjunct ? "press" : "disable")
            onClicked: {
                if (mainObject.canAddAdjunct(appComboBox.text) && appComboBox.text != "" && projectNameList.indexOf(appComboBox.text) != -1){
                    mainWindow.hide()
                    mainObject.getScreenShot(appComboBox.text.trim())
                }
            }
        }

        DImageButton {
            id:adjunctButton
            width: 22
            height: 22
            normal_image: "qrc:/views/Widgets/images/adjunct_%1.png".arg(canAddAdjunct ? "normal" : "disable")
            hover_image: "qrc:/views/Widgets/images/adjunct_%1.png".arg(canAddAdjunct ? "press" : "disable")
            press_image: "qrc:/views/Widgets/images/adjunct_%1.png".arg(canAddAdjunct ? "press" : "disable")
            onClicked: {
                if (mainObject.canAddAdjunct(appComboBox.text) && appComboBox.text != "" && projectNameList.indexOf(appComboBox.text) != -1){
                    adjunctPickDialog.open()
                }
            }
        }
    }

    Rectangle {
        id: adjunctRec

        radius: 2
        color: bgNormalColor
        border.color: warning ? buttonBorderWarningColor : buttonBorderColor
        width: parent.width
        height: parent.height - buttonRow.height
        anchors.top: buttonRow.bottom
        anchors.topMargin: 6

        ListView {
            id: textEditView
            width: parent.width
            height: parent.height - adjunctTray.height
            anchors.top: parent.top
            model: itemModel
            clip: true

            DScrollBar {
                flickable: textEditView
            }
        }

        VisualItemModel
        {
            id: itemModel

            Item {
                width: adjunctRec.width
                height: contentTextEdit.contentHeight > textEditView.height ? contentTextEdit.contentHeight : textEditView.height

                TextEdit {
                    id: contentTextEdit
                    color: textNormalColor
                    selectionColor: "#31536e"
                    selectByMouse: true
                    font.pixelSize: 12
                    width: adjunctRec.width
                    height: contentHeight > textEditView.height ? contentHeight : textEditView.height
                    wrapMode: TextEdit.Wrap
                }

                Text {
                    id: problemTips

                    color: "#bebebe"
                    font.pixelSize: 12
                    width: adjunctRec.width
                    height: textEditView.height
                    wrapMode: TextEdit.Wrap
                    opacity: contentTextEdit.text == "" && reportTypeButtonRow.reportType == DataConverter.DFeedback_Bug ? 1 : 0
                    text: {
                        var content ="\n    " + dsTr("Please describe your problem in detail") + "\n\n    " +
                                dsTr("Please upload related screenshots or files")
                        return content
                    }

                    Behavior on opacity {
                        NumberAnimation {duration: 150}
                    }

                    Component.onCompleted: {

                    }
                }

                Text {
                    id: ideaTips

                    color: "#bebebe"
                    font.pixelSize: 12
                    width: adjunctRec.width
                    height: textEditView.height
                    wrapMode: TextEdit.Wrap
                    opacity: contentTextEdit.text == "" && reportTypeButtonRow.reportType != DataConverter.DFeedback_Bug ? 1 : 0
                    text: {
                        var content = "\n    " + dsTr("Please describe your idea in detail ") + "\n\n    " +
                                dsTr("Please upload related attachments")
                        return content
                    }

                    Behavior on opacity {
                        NumberAnimation {duration: 150}
                    }
                }
            }
        }


        AdjunctTray {
            id: adjunctTray
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 1
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 2
            height: (adjunctModel.count !=0 || showAddAdjunct) ? 52 : 0
            Behavior on height {
                NumberAnimation {duration: 150}
            }
        }
    }

    Connections {
        target: mainObject
        onGetScreenshotFinish: {
            getAdjunct(fileName)
            mainWindow.show()
        }
    }
}

