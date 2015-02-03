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
    x: 650
    y: 50

    Rectangle {
        anchors.fill: parent

        MouseArea {
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width - (minimizeButton.width + maximizeButton.width + closeWindowButton.width)
            height: windowButtonRow.height

            property int startX
            property int startY
            property bool holdFlag
            onPressed: {
                startX = mouse.x;
                startY = mouse.y;
                holdFlag = true;
            }
            onReleased: holdFlag = false;
            onPositionChanged: {
                if (holdFlag) {
                    mainWindow.setX(mainWindow.x + mouse.x - startX)
                    mainWindow.setY(mainWindow.y + mouse.y - startY)
                }
            }
        }

        Row {
            id:windowButtonRow
            anchors.top:parent.top
            anchors.right: parent.right

            DImageButton {
                id:minimizeButton
                normal_image: "qrc:/views/Widgets/images/minimise_normal.png"
                hover_image: "qrc:/views/Widgets/images/minimise_hover.png"
                press_image: "qrc:/views/Widgets/images/minimise_press.png"
                onClicked: {
                    mainWindow.showMinimized()
                }
            }

            DImageButton {
                id:maximizeButton
                normal_image: "qrc:/views/Widgets/images/maximize_normal.png"
                hover_image: "qrc:/views/Widgets/images/maximize_hover.png"
                press_image: "qrc:/views/Widgets/images/maximize_press.png"
            }

            DImageButton {
                id:closeWindowButton
                normal_image: "qrc:/views/Widgets/images/close_normal.png"
                hover_image: "qrc:/views/Widgets/images/close_hover.png"
                press_image: "qrc:/views/Widgets/images/close_press.png"
                onClicked: {
                    mainWindow.close()
                    Qt.quit()
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
                actived: true
                text: qsTr("I got problem")
                onClicked: {
                    actived = !actived
                    proposalReportButton.actived = !proposalReportButton.actived
                }
            }

            ReportTypeButton {
                id: proposalReportButton
                actived: false
                text: qsTr("I got a good idea")
                onClicked: {
                    actived = !actived
                    bugReportButton.actived = !bugReportButton.actived
                }
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

        AdjunctPanel {
            id:adjunctPanel

            width: reportTypeButtonRow.width
            height: 222 + 6
            anchors.top: appComboBox.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
        }

        AppTextInput {
            id: emailTextinput
            width: reportTypeButtonRow.width
            height: 30
            anchors.top: adjunctPanel.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            tip: "Write down your email here."
        }

        Item {
            id: helpTextItem
            anchors.top: emailTextinput.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            width: reportTypeButtonRow.width

            AppCheckBox {
                id: helpCheck
                width: 15
                anchors.left: parent.left

            }

            Text {
                anchors.left: helpCheck.right
                width: parent.width - helpCheck.width
                text: qsTr("我愿意参加深度用户反馈帮助计划，以帮助深度系统快速改进，此过程中将不会收集任何个人信息。")
                wrapMode: Text.Wrap
                color: textNormalColor
                horizontalAlignment: Text.AlignLeft
                font.pixelSize: 13
                clip: true

            }
        }

        Row {
            anchors.right: reportTypeButtonRow.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16
            spacing: 12

            TextButton {
                id:closeButton
                text: qsTr("Close")
                onClicked: {
                    mainWindow.close()
                    Qt.quit()
                }
            }

            TextButton {
                id: sendButton
                text: qsTr("Send")
                onClicked: {

                }
            }
        }
    }
}
