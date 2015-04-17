/*************************************************************
*File Name: SingleLineTip.qml
*Author: Match
*Email: Match.YangWanQing@gmail.com
*Created Time: 2015年04月15日 星期三 13时09分24秒
*Description:
*
*************************************************************/
import QtQuick 2.1
import Deepin.Widgets 1.0

DSingleLineTip {
    width: 100
    height: 20 + 6
    radius: 3
    textColor: "#ff8c03"
    backgroundColor: Qt.rgba(0,0,0,0.9)
    arrowWidth: 8
    arrowHeight: 6
    arrowLeftMargin: 15
    destroyInterval: 200
    borderColor: "#ced0d3"
    borderWidth: 0
    shadowWidth: 0
    fontPixelSize: 12
	x:100
    y:500
}

