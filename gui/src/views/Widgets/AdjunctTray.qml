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
import "./SingleLineTipCreator.js" as IconTip

Rectangle {
    id: adjunctTray
    color: "#e8e8e8"
    width: parent.width

    property alias adjunctModel: adjunctView.model

    signal adjunctAdded()
    signal adjunctRemoved()

    function isUploaded(filePath){
        return AdjunctUploader.isInUploadedList(filePath)
    }

    function isAllAdjunctUploaded(){
        for (var i = 0; i < adjunctView.model.count; i ++){
            if (!adjunctView.model.get(i).uploadFinish)
                return false
        }
        return true
    }

    function getBucketUrl(filePath){
        return AdjunctUploader.getBucketUrl(filePath)
    }

    function getAdjunctList(){
        var tmpList = []
        for (var i = 0; i < adjunctView.model.count; i ++){
            var tmpPath = adjunctView.model.get(i).filePath
            tmpList.push({
                          "name": AdjunctUploader.getFileNameByPath(tmpPath),
                             "url":adjunctView.model.get(i).bucketUrl,
                             "type": AdjunctUploader.getMimeType(tmpPath)
                         })
        }

        return tmpList
    }

    function addAdjunct(filePath){
        if (getIndexFromModel(filePath) == -1){
            var fileUploaded = isUploaded(filePath)
            adjunctView.model.append({
                                         "showIconOnly": false,
                                         "filePath": filePath,
                                         "bucketUrl": fileUploaded ? getBucketUrl(filePath) : "",
                                         "loadPercent": 0,
                                         "iconPath": "images/add-adjunct.png",
                                         "uploadFinish": fileUploaded,
                                         "gotError": false
                                     })
            adjunctTray.adjunctAdded()

            if (!fileUploaded)
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
                                         "iconPath": "images/add-adjunct.png",
                                         "uploadFinish": false,
                                         "gotError": false
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
            updateLoadPercent(filePath,progress / 100)
        }
        onUploadFinish: {
            var tmpIndex = getIndexFromModel(filePath)
            if (tmpIndex != -1){
                adjunctView.model.setProperty(tmpIndex,"uploadFinish",true)
                adjunctView.model.setProperty(tmpIndex,"bucketUrl",bucketUrl)
            }
        }
        onUploadFailed: {
            var tmpIndex = getIndexFromModel(filePath)
            if (tmpIndex != -1){
                adjunctView.model.setProperty(tmpIndex,"gotError",true)
                adjunctView.model.setProperty(tmpIndex,"bucketUrl","")
            }
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
            onRetryUpload: {
                var tmpIndex = getIndexFromModel(filePath)
                if (tmpIndex != -1){
                    adjunctView.model.setProperty(tmpIndex,"gotError",false)
                }

                AdjunctUploader.uploadAdjunct(filePath)
            }
            onErrorSignal: {
                IconTip.pageX = pageX
                IconTip.pageY = pageY
                IconTip.pageWidth = 200
                IconTip.toolTip = dsTr("Upload failed, please retry.")
                IconTip.showTip()
            }
            onExited: {
                IconTip.destroyTip()
            }
        }
    }
}

