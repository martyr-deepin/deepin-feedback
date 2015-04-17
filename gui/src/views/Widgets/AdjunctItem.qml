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
    property bool upload_finish: uploadFinish
    property bool got_error: gotError
    /*from model*****************************************/

    signal deleteAdjunct(string filePath)
    signal retryUpload(string filePath)
    signal errorSignal(int pageX, int pageY)
    signal exited

    onUpload_finishChanged: {
        if (upload_finish){
            hoverRec.opacity = 0
            progressCir.opacity = 0
        }
    }

    onGot_errorChanged: {
        if (got_error){
            progressCir.percentageColor = "#ff8f00"
            progressCir.repaint()
            percentText.visible = false
            retryImg.visible = true
        }
        else{
            progressCir.percentageColor = "#00b3fb"
            progressCir.repaint()
            percentText.visible = true
            retryImg.visible = false
            load_percent = 0
        }
    }

    Item {
        enabled: !show_icon_only
        visible: !show_icon_only
        width: parent.width
        height: parent.height
        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                deleteButton.visible = true
                if (got_error){
                    var mapObj = adjunctItem.mapFromItem(rootRec)
                    adjunctItem.errorSignal(mainWindow.x - mapObj.x + 25,mainWindow.y - mapObj.y + 56)
                }
            }
            onExited: {
                deleteButton.visible = false
                adjunctItem.exited()
            }
        }

        DIcon {
            id:fileIcon
            anchors.centerIn: parent

            height: 48
            width: 48
            theme: "Deepin"
            icon: dfcdAide.getIconName(file_path)

            Rectangle {
                id: hoverRec
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

            onClicked: adjunctItem.deleteAdjunct(file_path)

            onEntered: visible = true
            onExited: visible = false
        }

        PercentCircle {
            id: progressCir
            anchors.centerIn: parent
            lineWidth: 2
            width: 30
            height: 30

            Text {
                id: percentText
                anchors.centerIn: parent
                font.pixelSize: 8
                color: "#ffffff"
                font.family: "UKIJ CJK"
            }

            Image {
                id: retryImg
                visible: false
                anchors.centerIn: parent
                source: "qrc:/views/Widgets/images/retry-angle.png"
                MouseArea{
                    anchors.fill: parent
                    onClicked: adjunctItem.retryUpload(file_path)
                }
            }

            Connections {
                target: adjunctItem
                onLoad_percentChanged: {
                    progressCir.updatePercentage(load_percent)
                    percentText.text = (load_percent * 100).toFixed(0) + "%"
                }
            }

            Component.onCompleted: {
                progressCir.updatePercentage(0)
                percentText.text = "0%"
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

