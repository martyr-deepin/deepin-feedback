/*************************************************************
*File Name: MainWindow.qml
*Author: Match
*Email: Match.YangWanQing@gmail.com
*Created Time: Thu 29 Jan 2015 05:33:54 PM CST
*Description:
*
*************************************************************/
import QtQuick 2.2
import QtGraphicalEffects 1.0
import QtQuick.Window 2.0
import Deepin.Widgets 1.0
import DataConverter 1.0
import DataSender 1.0
import "Widgets"

DWindow {
    id:mainWindow

    flags: Qt.FramelessWindowHint
    color: "#00000000"
    width: normalWidth
    height: normalHeight
    shadowWidth: 14
    x: screenSize.width / 2 - width / 2
    y: screenSize.height * 0.15

    property int shadowRadius: 10
    property int normalWidth: 460 + (shadowRadius + rootRec.radius) * 2
    property int normalHeight: 592 + (shadowRadius + rootRec.radius) * 2
    property int maxWidth: screenSize.width * 9 / 20
    property int maxHeight: screenSize.height * 5 / 6
    property string lastTarget: "" //lastTarget = currentTarget if combobox menu item not change
    property int animationDuration: 200
    property bool enableInput: appComboBox.text != "" && appComboBox.labels.indexOf(appComboBox.text) >= 0
    property bool haveDraft: {
        reportTypeButtonRow.reportType != DataConverter.DFeedback_Bug ||
                titleTextinput.text != "" ||
                (emailTextinput.text != "" && emailTextinput.emailChanged) ||
                helpCheck.checked == false ||
                adjunctPanel.haveAdjunct
    }
    property bool draftEdited: false

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
        if (lastTarget == "" || !haveDraft || !draftEdited)
            return

        mainObject.saveDraft(lastTarget,
                             reportTypeButtonRow.reportType,
                             titleTextinput.text,
                             emailTextinput.text,
                             helpCheck.checked,
                             adjunctPanel.contentText)
    }

    function contentEdited(){
        draftEdited = true
    }

    function clearDraft(){
        reportTypeButtonRow.reportType = DataConverter.DFeedback_Bug
        titleTextinput.text = ""
        emailTextinput.text = ""
        emailTextinput.emailChanged = false
        helpCheck.checked = true
        adjunctPanel.clearAllAdjunct()
    }

    function switchProject(project){
        autoSaveTimer.stop()
        saveDraft()

        //project exist, try to load draft
        if (mainObject.draftTargetExist(project)){
            clearDraft()
            //load new target data
            mainObject.updateUiDraftData(project)
            lastTarget = project
        }
        else{
            var emailsList = mainObject.getEmails()
            if (emailsList.length > 0){
                emailTextinput.text = emailsList[0]
            }

            clearDraft()
        }

        appComboBox.setText(project)
        lastTarget = project
        draftEdited = false
        autoSaveTimer.start()
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

    function getJsonData(){
        var jsonObj = {
            "method": "Deepin.Feedback.putFeedback",
            "version": "1.1",
            "params": {
                "project" : appComboBox.text.trim(),
                "description": adjunctPanel.getDescriptionDetails(),
                "summary" : titleTextinput.text.trim(),
                "attachments": adjunctPanel.getAttchementsList(),
                "email" : emailTextinput.text.trim(),
                "type" : reportTypeButtonRow.reportType == DataConverter.DFeedback_Bug ? "problem" : "suggestion"
            }
        }

        return marshalJSON(jsonObj)
    }

    Connections {
        target:feedbackContent
        onGenerateReportFinished: {
            //TODO add result file to draft system
            print ("===++++++++++++++++++",arg0,arg1)
        }
    }

    DataSender {
        id: dataSender
        onPostFinish: {
            mainObject.clearDraft(lastTarget)
            adjunctPanel.clearAllAdjunct()
            mainWindow.close()
            Qt.quit()
        }
    }

    Timer {
        id: autoSaveTimer
        running: true
        repeat: true
        interval: 2000
        onTriggered: saveDraft()
    }

    Rectangle {
        id: rootRec
        anchors.centerIn: parent

        width: mainWindow.width - (shadowRadius + rootRec.radius) * 2
        height: mainWindow.height - (shadowRadius + rootRec.radius) * 2
        radius: 4
        border.width: 1
        border.color: Qt.rgba(0, 0, 0, 0.2)

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

        DropArea {
            id: mainDropArea
            enabled: enableInput
            anchors.fill: parent
            width: parent.width
            height: parent.height
            onDropped: {
                adjunctPanel.hideAddAdjunctIcon()
                adjunctPanel.warning = false

                if (!adjunctPanel.canAddAdjunct)
                    return

                for (var key in drop.urls){
                    if (adjunctPanel.canAddAdjunct){
                        adjunctPanel.getAdjunct(drop.urls[key].slice(7,drop.urls[key].length))
                    }
                }
            }
            onEntered: {
                if (adjunctPanel.canAddAdjunct)
                    adjunctPanel.showAddAdjunctIcon(drag.urls.length)
                else{
                    adjunctPanel.warning = true
                    if (enableInput)
                        toolTip.showTip(dsTr("Total attachments have reached limit. "))
                }
            }
            onExited: {
                adjunctPanel.hideAddAdjunctIcon()
                adjunctPanel.warning = false
                toolTip.hideTip()
            }
        }

        Image {
            id: appIcon
            width: 16
            height: 16
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.top: parent.top
            anchors.topMargin: 8
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
            width: rootRec.width - 22 * 2
            anchors.top: rootRec.top
            anchors.topMargin: 38
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12
            property var reportType: DataConverter.DFeedback_Bug

            ReportTypeButton {
                id: bugReportButton
                width: (rootRec.width - 12 - 22 * 2) / 2
                actived: parent.reportType == DataConverter.DFeedback_Bug
                iconPath: "qrc:/views/Widgets/images/reporttype_bug.png"
                text: dsTr("I have a problem")
                onClicked: {
                    parent.reportType = DataConverter.DFeedback_Bug
                }
            }

            ReportTypeButton {
                id: proposalReportButton
                width: (rootRec.width - 12 - 22 * 2) / 2
                actived: parent.reportType == DataConverter.DFeedback_Proposal
                iconPath: "qrc:/views/Widgets/images/reporttype_proposal.png"
                text: dsTr("I have a good idea")
                onClicked: {
                    parent.reportType = DataConverter.DFeedback_Proposal
                    contentEdited()
                }
            }
        }

        AppComboBox {
            id:appComboBox
            parentWindow: mainWindow
            height: 30
            width: reportTypeButtonRow.width
            anchors.top: reportTypeButtonRow.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            onMenuSelect: {
                if (lastTarget != "" && haveDraft && draftEdited){
                    toolTip.showTipWithColor(dsTr("The draft of %1 has been saved.").arg(getProjectNameByID(lastTarget)),"#a4a4a4")
                }
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
                    toolTip.showTip(dsTr("Title words have reached limit."))
                }
            }

            onTextChange: contentEdited()

        }

        AdjunctPanel {
            id:adjunctPanel

            enabled: enableInput
            backgroundColor: enabled ? bgNormalColor : inputDisableBgColor
            width: reportTypeButtonRow.width
            height: (rootRec.height - 340)
            anchors.top: titleTextinput.bottom
            anchors.topMargin: 6
            anchors.horizontalCenter: parent.horizontalCenter
        }

        AppTextInput {
            id: emailTextinput
            property bool canFillEmail: true
            property bool emailChanged: false
            enabled: enableInput
            backgroundColor: enabled ? bgNormalColor : inputDisableBgColor
            width: reportTypeButtonRow.width
            height: 30
            anchors.top: adjunctPanel.bottom
            anchors.topMargin: 18
            anchors.horizontalCenter: parent.horizontalCenter
            tip: dsTr("Please fill in email to get the feedback progress.")
            onFocusChanged: {
                if (!focus && !isLegitEmail(emailTextinput.text)){
                    toolTip.showTip(dsTr("Email is invalid."))
                }
            }
            onKeyPressed: {
                if (event.key == Qt.Key_Backspace){
                    canFillEmail = false
                }
                else if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return || event.key == Qt.Key_Right){
                    canFillEmail = false
                    input.deselect()
                }
                else{
                    canFillEmail = true
                }
            }
            onTextChange: {
                emailChanged = true
                contentEdited()
                if (canFillEmail){
                    var matchEmail = mainObject.getMatchEmailPart(text)
                    var startIndex = text.length
                    input.text = text + matchEmail
                    input.select(startIndex, input.text.length)
                }
                if (input.selectionStart == 0){//change by combobox
                    input.deselect()
                    emailChanged = false
                }
            }
        }

        Item {
            id: helpTextItem
            anchors.top: emailTextinput.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            width: reportTypeButtonRow.width
            height: helpText.contentHeigh

            AppCheckBox {
                id: helpCheck
                enabled: enableInput
                width: 15
                anchors.left: parent.left
                anchors.top: parent.top
                checked: true
                onCheckedChanged: contentEdited()
            }

            Text {
                id: helpText
                anchors.left: helpCheck.right
                lineHeight: 1.6
                width: parent.width - helpCheck.width
                text: dsTr("I wish to join in User Feedback Help Plan to quickly improve the system without any personal information collected.")
                wrapMode: Text.Wrap
                color: enableInput ? textNormalColor : "#bebebe"
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
            spacing: 8

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
                    dataSender.postFeedbackData(getJsonData())
                    mainObject.saveEmail(emailTextinput.text)
                    print (getProjectIDByName(appComboBox.text.trim()), helpCheck.checked)
                    print (feedbackContent.GenerateReport(getProjectIDByName(appComboBox.text.trim()), helpCheck.checked))
                }
            }
        }

        Tooltip {
            id: toolTip
            anchors.left: adjunctPanel.left
            anchors.verticalCenter: controlButtonRow.verticalCenter
            autoHideInterval: 3600
            height: textItem.lineCount == 1 ? textItem.contentHeight : controlButtonRow.height
            maxWidth: parent.width - controlButtonRow.width - 50
        }
    }

    RectangularGlow {
        id: shadow
        z: -1
        anchors.fill: rootRec
        glowRadius: shadowRadius
        spread: 0.2
        color: Qt.rgba(0, 0, 0, 0.3)
        cornerRadius: rootRec.radius + shadowRadius
        visible: true
    }
}
