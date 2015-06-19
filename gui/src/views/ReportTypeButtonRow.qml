/*************************************************************
*File Name: ReportTypeButtonRow.qml
*Author: Match
*Email: Match.YangWanQing@gmail.com
*Created Time: 2015年06月19日 星期五 09时56分27秒
*Description:
*
*************************************************************/
import QtQuick 2.1
import DataConverter 1.0
import "Widgets"

Row {
    id: reportTypeButtonRow
    width: parent.width
    spacing: 12
    property var reportType: DataConverter.DFeedback_Bug

    ReportTypeButton {
        id: bugReportButton
        width: (parent.width - 12) / 2
        actived: parent.reportType == DataConverter.DFeedback_Bug
        iconPath: "qrc:/views/Widgets/images/reporttype_bug.png"
        text: dsTr("I have a problem")
        onClicked: {
            parent.reportType = DataConverter.DFeedback_Bug
        }
    }

    ReportTypeButton {
        id: proposalReportButton
        width: (parent.width - 12) / 2
        actived: parent.reportType == DataConverter.DFeedback_Proposal
        iconPath: "qrc:/views/Widgets/images/reporttype_proposal.png"
        text: dsTr("I have a good idea")
        onClicked: {
            parent.reportType = DataConverter.DFeedback_Proposal
            contentEdited()
        }
    }
}

