/*************************************************************
*File Name: AdjunctTray.qml
*Author: Match
*Email: Match.YangWanQing@gmail.com
*Created Time: Tue 03 Feb 2015 02:38:44 PM CST
*Description:
*
*************************************************************/
import QtQuick 2.3
import Deepin.Widgets 1.0

Rectangle {
    color: "#e8e8e8"
    height: 52
    width: parent.width

    property alias adjunctModel: adjunctView.model

    DFileChooseDialogAide {id:dfcdAide}

    function addAdjunct(filePath){
        if (getIndexFromModel(filePath) == -1){
            adjunctView.model.append({
                                         "filePath": filePath,
                                         "loadPercent": 0
                                     })
        }
    }

    function removeAdjunct(filePath){
        var tmpIndex = getIndexFromModel(filePath)
        if (tmpIndex != -1){
            adjunctView.model.remove(tmpIndex)
        }
    }

    function updateLoadPercent(filePath, percent){
        var tmpIndex = getIndexFromModel(filePath)
        if (tmpIndex != -1){
            adjunctView.model.setProperty(tmpIndex,"loadPercent",percent)
        }
    }

    function getIndexFromModel(filePath){
        for (var i = 0; i < adjunctView.model.count; i ++){
            if (adjunctView.model.get(i).filePath == filePath){
                return i
            }
        }
        return -1
    }

    function clearAllAdjunct(){
        adjunctView.model.clear()
    }

    GridView {
        id: adjunctView
        anchors.fill: parent
        width: parent.width
        height: parent.height
        cellWidth: width / 6
        cellHeight: 52

        model: ListModel {}
        delegate: AdjunctItem {
            clip: true
            width: adjunctView.cellWidth
            height: adjunctView.cellHeight
            onDeleteAdjunct: {
                removeAdjunct(filePath)
                mainObject.removeAdjunct(filePath)
            }
        }
    }
}

