
import QtQuick 2.1
import QtQuick.Window 2.1
import Deepin.Locale 1.0
import Deepin.Widgets 1.0
import DBus.Com.Deepin.Daemon.Display 1.0
import DBus.Com.Deepin.Daemon.Search 1.0
import DBus.Com.Deepin.Feedback 1.0

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

    property var projectList: projectListModel.getValueList()
    property var projectNameList:projectListModel.getNameList()
    property var projectListModel: ListModel {
        function getValueList(){
            var tmpValueList = new Array()
            for (var i = 0; i < count; i ++){
                tmpValueList.push(get(i).Value)
            }

            return tmpValueList
        }

        function getNameList(){
            var tmpNameList = new Array()
            for (var i = 0; i < count; i ++){
                tmpNameList.push(get(i).Name)
            }

            return tmpNameList
        }

        Component.onCompleted: {
            var tmpValue = unmarshalJSON(feedbackContent.GetCategories())
            for (var key in tmpValue){
                append(tmpValue[key])
            }
        }
    }

    property var displayId: Display {}
    property var screenSize: QtObject {
        property int x: displayId.primaryRect[0]
        property int y: displayId.primaryRect[1]
        property int width: displayId.primaryRect[2]
        property int height: displayId.primaryRect[3]
    }
    property var feedbackContent: Feedback {}
    property var dconstants: DConstants{}
    property var mainWindow: MainWindow {}
    property var dbusSearch: Search {}
    property var dsslocale: DLocale {
        domain: "deepin-user-feedback"

        Component.onCompleted: print("==> [info] Language:", dsslocale.lang)
    }

    function getSupportAppList(){
        return projectListModel.getValueList()
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

    function marshalJSON(value) {
        var valueJSON = JSON.stringify(value);
        return valueJSON
    }

    function unmarshalJSON(valueJSON) {
        var value = JSON.parse(valueJSON)
        return value
    }

}
