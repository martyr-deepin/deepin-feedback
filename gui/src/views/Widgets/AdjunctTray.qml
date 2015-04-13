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
import AdjunctUploader 1.0

Rectangle {
    id: adjunctTray
    color: "#e8e8e8"
    width: parent.width

    property alias adjunctModel: adjunctView.model

    signal adjunctAdded()
    signal adjunctRemoved()

    DFileChooseDialogAide {id:dfcdAide}

    function addAdjunct(filePath){
        if (getIndexFromModel(filePath) == -1){
            adjunctView.model.append({
                                         "showIconOnly": false,
                                         "filePath": filePath,
                                         "loadPercent": 0,
                                         "iconPath": "images/add-adjunct.png"
                                     })
            adjunctTray.adjunctAdded()

            AdjunctUploader.uploadAdjunct(filePath)
        }
    }

    function removeAdjunct(filePath){
        var tmpIndex = getIndexFromModel(filePath)
        if (tmpIndex != -1){
            adjunctView.model.remove(tmpIndex)
            adjunctTray.adjunctRemoved()

            AdjunctUploader.cancelUpload(filePath)
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

    function showAddIcon(count){
        for (var i = 0; i < count; i ++){
            adjunctView.model.append({
                                         "showIconOnly": true,
                                         "filePath": "/" + i,
                                         "loadPercent": 0,
                                         "iconPath": "images/add-adjunct.png"
                                     })
        }
    }

    function hideAddIcon(count){
        for (var i = count; i > 0; i --)
            adjunctView.model.remove(adjunctView.model.count - 1)
    }

    Connections {
        target: AdjunctUploader
        onUploadProgress: {
            print (filePath,progress)
            updateLoadPercent(filePath,progress / 100)
        }
        onUploadFinish: {

        }
        onUploadFailed: {

        }
    }

    GridView {
        id: adjunctView
        anchors.fill: parent
        width: parent.width
        height: parent.height
        cellWidth: parent.width / 6
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

