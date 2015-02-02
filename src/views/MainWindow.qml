/*************************************************************
*File Name: MainWindow.qml
*Author: Match
*Email: Match.YangWanQing@gmail.com
*Created Time: Thu 29 Jan 2015 05:33:54 PM CST
*Description:
*
*************************************************************/
import QtQuick 2.1
import QtQuick.Window 2.0
import Deepin.Widgets 1.0
import "Widgets"

Window {
    id:mainWindow

    flags: Qt.FramelessWindowHint

    width: 460
    height: 592
    x: 800
    y: 300

    Rectangle {
        anchors.fill: parent

        Row {
            id:windowButtonRow
            anchors.top:parent.top
            anchors.right: parent.right

            Rectangle {
                id:minimizeButton
                width: 30
                height: 20
                color:"#54d0db"
                border.color: "black"
            }

            Rectangle {
                id:maximizeButton
                width: 30
                height: 20
                color:"#54d0db"
                border.color: "black"
            }

            Rectangle {
                id:closeButton
                width: 30
                height: 20
                color:"#54d0db"
                border.color: "black"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        mainWindow.close()
                        Qt.quit()
                    }
                }
            }
        }

        Row {
            id: reportTypeButtonRow
            width: mainItemWidth
            anchors.top: windowButtonRow.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12

            ReportTypeButton {
                id: bugReportButton
            }

            ReportTypeButton {
                id: proposalReportButton
            }
        }

        AppTextInput {
            id: titleTextinput
            width: reportTypeButtonRow.width
            height: 30
            anchors.top: reportTypeButtonRow.bottom
            anchors.topMargin: 26
            anchors.horizontalCenter: parent.horizontalCenter
            tip: "Write an title"
        }

        AppComboBox {
            id:appComboBox
            parentWindow: mainWindow
            height: 30
            width: reportTypeButtonRow.width
            anchors.top: titleTextinput.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
