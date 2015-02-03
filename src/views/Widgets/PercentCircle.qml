/*************************************************************
*File Name: PercentCircle.qml
*Author: Match
*Email: Match.YangWanQing@gmail.com
*Created Time: Tue 03 Feb 2015 04:08:10 PM CST
*Description:
*
*************************************************************/
import QtQuick 2.0

Canvas {
  id:mainCanvas

  property string baseColor: "#1d1e19"          //圆圈的底色
  property string percentageColor: "#00b3fb"    //使用率的颜色
  property int lineWidth: 2                     //圈的粗细
  property double startAngle: Math.PI / 2
  property double percentage: 0   //0~1
  property string mainTitle: ""

  width: 50
  height: 50

  onPaint:{
      var ctx = mainCanvas.getContext('2d');
      //...
      ctx.strokeStyle = baseColor
      ctx.lineWidth = lineWidth
      ctx.beginPath();
      ctx.arc(mainCanvas.width / 2, mainCanvas.height / 2, mainCanvas.width / 2 - lineWidth, 0, Math.PI * 2);//full circle
      ctx.stroke();
  }


  Canvas {
      id: percentCanvas
      width: parent.width
      height: parent.height

      anchors.fill: parent

      onPaint:{
          var ctx = percentCanvas.getContext('2d')
          ctx.clearRect(0,0,width,height)
          ctx.strokeStyle = percentageColor
          ctx.lineWidth = lineWidth
          ctx.beginPath();
          // 根据percentage的值画出不同长度的圆弧
          //注意圆的方向是顺时针，所以90度角在下方
          ctx.arc(width / 2, height / 2, width / 2 - lineWidth, startAngle, 2 * Math.PI * percentage + startAngle, false);
          ctx.stroke();
      }
  }

  Text {
      id: mainText
      anchors {verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter}
      text: mainTitle
      color: "#596679"
      font.pixelSize: 13
  }

  function updatePercentage(percent)
  {
      percentage = percent
      percentCanvas.requestPaint();
  }
}


