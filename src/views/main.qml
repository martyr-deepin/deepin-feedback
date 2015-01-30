
import QtQuick 2.1
import QtQuick.Window 2.1
import Deepin.Locale 1.0
import Deepin.Widgets 1.0

QtObject {
    id: root

    property var feedbackType: 0
    property string reportTitle: ""
    property string email: ""
    property bool helpDeepin: true
    property string reportContent: ""
    property var adjunctsPathList: []

    function initReportContent(value){
        reportContent = value
    }

    function initAdjunctsPathList(list){
        adjunctsPathList = list
    }

    function initSimpleEntries(_feedbackType,_reportTitle,_email,_helpDeepin){
        feedbackType = _feedbackType
        reportTitle = _reportTitle
        email = _email
        helpDeepin = _helpDeepin
    }

    function showMainWindow(){
        mainWindow.show()
    }

    function hideMainWindow(){
        mainWindow.hide()
    }

    property var dconstants: DConstants{}

    property var mainWindow: MainWindow {}
}
