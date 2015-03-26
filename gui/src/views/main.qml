
import QtQuick 2.1
import QtQuick.Window 2.1
import Deepin.Locale 1.0
import Deepin.Widgets 1.0
import DBus.Com.Deepin.Daemon.Display 1.0
import DBus.Com.Deepin.Daemon.Search 1.0

QtObject {
    id: root

    property color textActivedColor: dconstants.hoverColor
    property color textNormalColor: "#5e5e5e"
    property color bgActivedColor: "#5498ec"
    property color bgNormalColor: dconstants.hoverColor
    property color buttonBorderColor: "#d7d7d7"
    property color buttonBorderActiveColor: "#7bbefb"
    property color buttonBorderWarningColor: "#FF8F00"
    property color warningTipsColor: "#ffa048"
    property color inputDisableBgColor: "#fbfbfb"

    property int maxAdjunctCount: 6

    property var supportAppList:[
        qsTr("deepin-movie"),
        qsTr("deepin-music-player"),
        qsTr("deepin-screenshot"),
        qsTr("deepin-boot-maker"),
        qsTr("deepin-bug-reporter"),
        qsTr("deepin-software-center"),
        qsTr("deepin-terminal"),
        qsTr("deepin-translator"),
        qsTr("other")
    ]

    property var displayId: Display {}
    property var screenSize: QtObject {
        property int x: displayId.primaryRect[0]
        property int y: displayId.primaryRect[1]
        property int width: displayId.primaryRect[2]
        property int height: displayId.primaryRect[3]
    }

    function getSupportAppList(){
        return supportAppList
    }

    function setReportContent(value){
        mainWindow.updateReportContentText(value)
    }

    function setAdjunctsPathList(list){
        mainWindow.updateAdjunctsPathList(list)
    }

    function setSimpleEntries(_feedbackType,_reportTitle,_email,_helpDeepin){
        mainWindow.updateSimpleEntries(_feedbackType,_reportTitle,_email,_helpDeepin)
    }

    function switchProject(target){
        mainWindow.switchProject(target)
    }

    function showMainWindow(){
        mainWindow.show()
    }

    function hideMainWindow(){
        mainWindow.hide()
    }

    function dsTr(s){
        return dsslocale.dsTr(s)
    }

    property var dconstants: DConstants{}

    property var mainWindow: MainWindow {}

    property var dbusSearch: Search {}

    property var dsslocale: DLocale {
        domain: "deepin-user-feedback"

        Component.onCompleted: print("==> [info] Language:", dsslocale.lang)
    }
}
