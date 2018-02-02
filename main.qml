import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtCharts 2.1
import QtQuick.Dialogs 1.1
import QtQuick.Controls.Material 2.1
import QtQuick.Window 2.2



ApplicationWindow {
    visible: true
    width: 1800
    height: 1080
    title: qsTr("Multimeter")
    id: mainWindow
    header: ToolBar
    {
        id: theToolbar
        width: parent.width
        height: 50
        Rectangle
        {
            anchors.fill: parent
            color: "black"
        }

        RowLayout
        {
            anchors.fill: parent
            spacing: 10
            anchors.leftMargin: 20
            Button
            {
                text: "Serial Interface"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    ChartView
    {
        id: chartView
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width * 0.8
        height: parent.height
        theme: ChartView.ChartThemeDark
        animationOptions:  ChartView.SeriesAnimations
        antialiasing: true
        property  int initialX
        property int  initialY
        property double currentScale

        function toMsecsSinceEpoch(date) {
            var msecs = date.getTime();
            return msecs;
        }
        PinchArea{
            width: parent.width
            height: parent.height

            onPinchStarted: {
                chartView.currentScale = pinch.scale
                chartView.initialX = pinch.center.x
                valueIndicatorLine.visible = true
            }

            onPinchUpdated: {

                chartView.scrollLeft(pinch.center.x - pinch.previousCenter.x)
                chartView.scrollUp(pinch.center.y - pinch.previousCenter.y)

                if(Math.abs(pinch.center.x - chartView.initialX) >= 100)
                {

                    chartView.initialX = pinch.center.x
                }

                if(Math.abs(pinch.scale - chartView.currentScale) >= 0.3)
                {

                    chartView.currentScale = pinch.scale
                    if (pinch.scale < 1)
                    {

                        if(Math.abs(chartView.toMsecsSinceEpoch(axisX1.min) - chartView.toMsecsSinceEpoch(axisX1.max)) <(24*60*60*1000))
                        {
                            axisX1.min = new Date(axisX1.min - 1000000*(1/pinch.scale))
                            axisX1.max = new Date(axisX1.max + 1000000*(1/pinch.scale))
                        }
                        else
                        {
                            axisX1.min = new Date(axisX1.max - (24*60*60*1000))
                        }
                    }
                    else
                    {
                        if(Math.abs(chartView.toMsecsSinceEpoch(axisX1.min) - chartView.toMsecsSinceEpoch(axisX1.max)) > (20*60*1000))
                        {
                            axisX1.min = new Date(axisX1.min + 1000000*pinch.scale)
                            axisX1.max = new Date(axisX1.max - 1000000*pinch.scale)
                        }
                        else
                        {
                            axisX1.min = new Date(axisX1.max - (20*60*1000))
                        }

                    }

                }
                // //console.log("pinch scale: " + pinch.scale)
            }

            onPinchFinished:
            {

                // have to have something here to limit the min and max zoom on xAxis
                valueIndicatorLine.visible = false
            }
        }


        Rectangle
        {
            id: valueIndicatorLine
            width: 3
            height: 580
            color: "red"
            visible: false
            x:parent.width/2
            y:80
            z:3

        }

        ValueAxis{
            id: axisY2
            min: 0
            max: 8000
            tickCount: 6
            labelFormat: "%d"

        }

        LogValueAxis{
            id: axisY1
            base: 10
            max: 1e-7
            min: 1e-12
            labelFormat: "%.2e"

        }

        DateTimeAxis{
            id: axisX1
            tickCount: 6
            min: new Date(new Date() - 100000)
            max: new Date()
            format: "MMM\dd hh:mm"
        }

        LineSeries{
            id: pressureSerie
            name: "Data"
            axisX: axisX1
            axisY: axisY1
            useOpenGL: true
            width: 4
            color: "red"
            style: Qt.DotLine

        }

        // Timer to load graph the first time, only run one time
        Timer
        {
            id:loadGraphFirstTime
            interval:0
            repeat: false
            running:true
            onTriggered:
            {

            }
        }

    }

}
