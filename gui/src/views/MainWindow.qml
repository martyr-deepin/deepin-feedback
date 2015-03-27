/*************************************************************
*File Name: MainWindow.qml
*Author: Match
*Email: Match.YangWanQing@gmail.com
*Created Time: Thu 29 Jan 2015 05:33:54 PM CST
*Description:
*
*************************************************************/
import QtQuick 2.2
import QtQuick.Window 2.0
import Deepin.Widgets 1.0
import DataConverter 1.0
import "Widgets"

DWindow {
    id:mainWindow

    flags: Qt.FramelessWindowHint

    width: normalWidth
    height: normalHeight
    x: 650
    y: 50

    property int normalWidth: 460
    property int normalHeight: 592
    property int maxWidth: screenSize.width * 9 / 20
    property int maxHeight: screenSize.height * 5 / 6
    property string lastTarget: "" //lastTarget = currentTarget if combobox menu item not change
    property int animationDuration: 200
    property bool enableInput: appComboBox.text != "" && appComboBox.labels.indexOf(appComboBox.text) >= 0

    function updateReportContentText(value){
        adjunctPanel.setContentText(value)
    }

    function updateAdjunctsPathList(list){
        for (var i = 0; i < list.length; i ++){
            adjunctPanel.addAdjunct(list[i])
        }
    }

    function updateSimpleEntries(feedbackType, reportTitle, email, helpDeepin){
        reportTypeButtonRow.reportType = feedbackType

        titleTextinput.text = reportTitle

        emailTextinput.text = email

        helpCheck.checked = helpDeepin
    }

    function saveDraft(){
        if (lastTarget == "")
            return

        mainObject.saveDraft(lastTarget,
                             reportTypeButtonRow.reportType,
                             titleTextinput.text,
                             emailTextinput.text,
                             helpCheck.checked,
                             adjunctPanel.contentText)
    }

    function switchProject(project){
        //project exist, try to load draft
        if (mainObject.draftTargetExist(project)){
            saveDraft()
            //clear adjunct
            adjunctPanel.clearAllAdjunct()
            //load new target data
            mainObject.updateUiDraftData(project)
            lastTarget = project
        }
        //target not exist, create default draft
        else{
            mainObject.saveDraft(project, DataConverter.DFeedback_Proposal, "", "", true, "")
        }

        appComboBox.setText(project)
        lastTarget = project
    }

    function isLegitEmail(email){
        var reMail =/^(?:[a-zA-Z0-9]+[_\-\+\.]?)*[a-zA-Z0-9]+@(?:([a-zA-Z0-9]+[_\-]?)*[a-zA-Z0-9]+\.)+([a-zA-Z]{2,})+$/;
        var tmpRegExp = new RegExp(reMail);

        if(tmpRegExp.test(email)){
            return true
        }
        else{
            return false
        }
    }

    Connections {
        target: mainObject
        onSubmitCompleted: {
            if (succeeded){
                mainObject.clearDraft(lastTarget)
                adjunctPanel.clearAllAdjunct()
                Qt.quit()
            }
            else{
                saveDraft()
            }
        }
    }

    Connections {
        target:feedbackContent
        onGenerateReportFinished: {
            //TODO add result file to draft system
            print ("===++++++++++++++++++",arg0,arg1)
        }
    }

    Timer {
        id: autoSaveDraftTimer
        running: true
        repeat: true
        interval: 60000
        onTriggered: {
            saveDraft()
        }
    }

    Rectangle {
        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
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
            state: "zoomin"

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
                normal_image: "qrc:/views/Widgets/images/%1_normal.png".arg(windowButtonRow.state)
                hover_image: "qrc:/views/Widgets/images/%1_hover.png".arg(windowButtonRow.state)
                press_image: "qrc:/views/Widgets/images/%1_press.png".arg(windowButtonRow.state)
                onClicked: {
                    windowButtonRow.state = windowButtonRow.state == "zoomin" ? "zoomout" : "zoomin"
                }
            }

            DImageButton {
                id:closeWindowButton
                normal_image: "qrc:/views/Widgets/images/close_normal.png"
                hover_image: "qrc:/views/Widgets/images/close_hover.png"
                press_image: "qrc:/views/Widgets/images/close_press.png"
                onClicked: {
                    saveDraft()
                    mainWindow.close()
                    Qt.quit()
                }
            }

            states: [
                State {
                    name: "zoomout"
                    PropertyChanges {target: mainWindow; width: maxWidth; height: maxHeight}
                },
                State {
                    name: "zoomin"
                    PropertyChanges {target: mainWindow; width: normalWidth; height: normalHeight}
                }
            ]

            transitions:[
                Transition {
                    from: "zoomout"
                    to: "zoomin"
                     SequentialAnimation {
                        NumberAnimation {target: mainWindow;property: "width";duration: animationDuration;easing.type: Easing.OutCubic}
                        NumberAnimation {target: mainWindow;property: "height";duration: animationDuration;easing.type: Easing.OutCubic}
                    }
                },
                Transition {
                    from: "zoomin"
                    to: "zoomout"
                     SequentialAnimation {
                        NumberAnimation {target: mainWindow;property: "width";duration: animationDuration;easing.type: Easing.OutCubic}
                        NumberAnimation {target: mainWindow;property: "height";duration: animationDuration;easing.type: Easing.OutCubic}
                    }
                }
            ]
        }

        Row {
            id: reportTypeButtonRow
            width: mainWindow.width - 22 * 2
            anchors.top: windowButtonRow.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12
            property var reportType: DataConverter.DFeedback_Bug

            ReportTypeButton {
                id: bugReportButton
                width: (mainWindow.width - 12 - 22 * 2) / 2
                actived: parent.reportType == DataConverter.DFeedback_Bug
                iconPath: "qrc:/views/Widgets/images/reporttype_bug.png"
                text: dsTr("I have a problem")
                onClicked: {
                    parent.reportType = DataConverter.DFeedback_Bug
                }
            }

            ReportTypeButton {
                id: proposalReportButton
                width: (mainWindow.width - 12 - 22 * 2) / 2
                actived: parent.reportType == DataConverter.DFeedback_Proposal
                iconPath: "qrc:/views/Widgets/images/reporttype_proposal.png"
                text: dsTr("I have a good idea")
                onClicked: {
                    parent.reportType = DataConverter.DFeedback_Proposal
                }
            }
        }

        AppComboBox {
            id:appComboBox
            parentWindow: mainWindow
            height: 30
            width: reportTypeButtonRow.width
            anchors.top: reportTypeButtonRow.bottom
            anchors.topMargin: 26
            anchors.horizontalCenter: parent.horizontalCenter
            onMenuSelect: {
                switchProject(projectList[index])
            }
        }

        AppTextInput {
            id: titleTextinput
            enabled: enableInput
            backgroundColor: enabled ? bgNormalColor : inputDisableBgColor
            width: reportTypeButtonRow.width
            height: 30
            maxStrLength: 100
            anchors.top: appComboBox.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            tip:reportTypeButtonRow.reportType == DataConverter.DFeedback_Bug ? dsTr("Please input the problem title")
                                                                              : dsTr("Please describe your idea simply")

            onInWarningStateChanged: {
                if (inWarningState){
                    //TODO
                    //Show warning tips
                    print ("==>[Warning] Title too long...")
                }
            }
        }


        AdjunctPanel {
            id:adjunctPanel

            enabled: enableInput
            backgroundColor: enabled ? bgNormalColor : inputDisableBgColor
            width: reportTypeButtonRow.width
            height: (mainWindow.height - windowButtonRow.height
                     - reportTypeButtonRow.height - 10
                     - titleTextinput.height - 26
                     - appComboBox.height - 16
                     - 16
                     - emailTextinput.height - 16
                     - helpTextItem.height - 16
                     - 16
                     - controlButtonRow.height - 16)
            anchors.top: titleTextinput.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
        }

        AppTextInput {
            id: emailTextinput
            enabled: enableInput
            backgroundColor: enabled ? bgNormalColor : inputDisableBgColor
            width: reportTypeButtonRow.width
            height: 30
            anchors.top: adjunctPanel.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            tip: dsTr("Please fill in email to get the feedback progress.")
        }

        Item {
            id: helpTextItem
            anchors.top: emailTextinput.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            width: reportTypeButtonRow.width
            height: childrenRect.height

            AppCheckBox {
                id: helpCheck
                enabled: enableInput
                width: 15
                anchors.left: parent.left
                checked: true

            }

            Text {
                anchors.left: helpCheck.right
                width: parent.width - helpCheck.width
                text: dsTr("I wish to join in User Feedback Help Plan to quickly improve the system without any personal information collected.")
                wrapMode: Text.Wrap
                color: textNormalColor
                horizontalAlignment: Text.AlignLeft
                font.pixelSize: 12
                clip: true
            }
        }

        Row {
            id: controlButtonRow
            anchors.right: reportTypeButtonRow.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16
            spacing: 12

            TextButton {
                id:closeButton
                text: dsTr("Close")
                onClicked: {
                    saveDraft()
                    mainWindow.close()
                    Qt.quit()
                }
            }

            TextButton {
                id: sendButton
                text: dsTr("Send")
                textItem.color: enabled ? textNormalColor : "#bebebe"
                enabled: {
                    if (titleTextinput.text != "" && appComboBox.text != "" && isLegitEmail(emailTextinput.text))
                        return true
                    else
                        return false
                }
                onClicked: {
                    print ("Reporting...")
                    print (projectList[projectNameList.indexOf(appComboBox.text.trim())], helpCheck.checked)
                    print (feedbackContent.GenerateReport(projectList[projectNameList.indexOf(appComboBox.text.trim())], helpCheck.checked))
                }
            }
        }
    }
}
