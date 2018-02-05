import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtCharts 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Window 2.2
import serialPortManager 1.0

ApplicationWindow {
    visible: true
    width: 1800
    height: 1080
    title: qsTr("Multimeter")
    id: mainWindow

    property bool serialInterfaceAvailable: false

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
            anchors.top: parent.top
            anchors.left: parent.left
            spacing: 10
            anchors.margins: 5


            Button
            {
                text: "Serial Interface"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: serialPortDialog.open()

                Dialog{
                    id: serialPortDialog
                    x: (mainWindow.width - width) /2
                    y:(mainWindow.height - height) /2
                    parent: ApplicationWindow.overlay
                    modal: true
                    Column
                    {
                        spacing: 20
                        anchors.fill: parent
                        Label{
                            text: "Name:"
                        }
                        ComboBox{
                            id: serialPortComboBox
                            model: serial.availablePorts()

                        }
                        Label{
                            text: "BaudRate"
                        }

                        ComboBox{
                            id: serialPortBaudRate
                            model:  ListModel{
                                ListElement{ text:"9600"}
                                ListElement{text: "19200"}
                            }
                        }
                        Button{
                            id: serialConnectButton
                            text: "Connect"
                            onClicked: {
                                serialPortInterface.setPortName(serialPortComboBox.currentText)
                                serialPortInterface.setBaudRate(parseInt(serialPortBaudRate.currentText))
                                if(serialPortInterface.connect())
                                {
                                    console.log ("Connected to Serial Interface")
                                    serialConnectButton.enabled = false
                                    serialDisconnectButton.enabled = true
                                    serialInterfaceAvailable = true
                                }
                            }
                        }
                        Button
                        {
                            id: serialDisconnectButton
                            text: "Disconnect"
                            enabled: false
                            onClicked:
                            {
                                if(serialPortInterface.disconnect())
                                {
                                    serialConnectButton.enabled = true
                                    serialDisconnectButton.enabled = false
                                    console.log("Disconnected to Serial Interface")
                                    serialInterfaceAvailable = false
                                }
                            }

                        }
                    }
                }
            }

            Button
            {
                text: "Record Setting"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: recordSettingDialog.open()

                Dialog{
                    id: recordSettingDialog
                    x: (mainWindow.width - width) /2
                    y:(mainWindow.height - height) /2
                    parent: ApplicationWindow.overlay
                    modal: true
                }
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

        DateTimeAxis{
            id: axisX1
            tickCount: 6
            min: new Date(new Date() - 100000)
            max: new Date()
            format: "MMM\dd hh:mm"
        }

        LineSeries{
            id: dataSerie
            name: "Data"
            axisX: axisX1
            axisY: axisY2
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

    Rectangle
    {
        id: controlPanelRec
        anchors.right: parent.right
        anchors.top: parent.top
        //        color: "black"
        width: parent.width * 0.2
        height: parent.height *0.8


        ColumnLayout
        {
            id: controlPanelColumnLayout
            spacing: 20
            anchors.fill: parent


            GroupBox
            {
                title: "Group 0"
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                Layout.margins: 10
                Column
                {
                    spacing: 5

                    Label
                    {
                        text: "0V"
                    }

                    Label
                    {
                        text: "Sampling rate (Hz):"
                    }
                    SpinBox
                    {
                        id: samplingRateSpinBox
                        from: 1
                        to: 10
                    }
                }
            }

            GroupBox
            {
                title: "Group 1"

                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                Layout.margins: 10
                Row
                {

                    RadioButton{
                        id: voltageRadioButton
                        text: "Voltage"
                        checked: true
                    }
                    RadioButton
                    {
                        id: currentRadioButton
                        text: "Current"

                    }
                }
            }


            GroupBox
            {
                title: "Group 2"
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                Layout.margins: 10
                RowLayout
                {
                    RadioButton{
                        id: acRadioButton
                        text: "AC"
                        checked: true
                        onCheckedChanged:
                        {
                            if(checked)
                            {
                                if(voltageRadioButton.checked)
                                {
                                    setMultimeterVoltageACMode()
                                }
                                else
                                {
                                    setMultimeterCurrentACMode()
                                }
                            }
                        }
                    }
                    RadioButton
                    {
                        id: dcRadioButton
                        text: "DC"
                        onCheckedChanged:
                        {
                            if(checked)
                            {
                                if(voltageRadioButton.checked)
                                {
                                    setMultimeterVoltageDCMode()
                                }
                                else
                                {
                                    setMultimeterCurrentDCMode()
                                }
                            }
                        }
                    }
                }
            }

            GroupBox
            {
                title: "Group 3"
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                Layout.margins: 10
                Column{
                    CheckBox
                    {
                        id: autoRangeCheckbox
                        text: "Auto"

                        onCheckedChanged:
                        {
                            if(serialInterfaceAvailable)
                            {
                                if(checked)
                                {

                                    if(voltageRadioButton.checked)
                                    {
                                        if(dcRadioButton.checked)
                                        {
                                            serialPortInterface.input(sCPIprotocol.setMultimeterAutoRangeON(2))
                                        }
                                        else
                                        {
                                            serialPortInterface.input(sCPIprotocol.setMultimeterAutoRangeON(1))
                                        }
                                    }
                                    else
                                    {
                                        if(dcRadioButton.checked)
                                        {
                                            serialPortInterface.input(sCPIprotocol.setMultimeterAutoRangeON(4))
                                        }
                                        else
                                        {
                                            serialPortInterface.input(sCPIprotocol.setMultimeterAutoRangeON(3))
                                        }

                                    }
                                }
                                else
                                {

                                    if(voltageRadioButton.checked)
                                    {
                                        if(dcRadioButton.checked)
                                        {
                                            serialPortInterface.input(sCPIprotocol.setMultimeterAutoRangeOFF(2))
                                        }
                                        else
                                        {
                                            serialPortInterface.input(sCPIprotocol.setMultimeterAutoRangeOFF(1))
                                        }
                                    }
                                    else
                                    {
                                        if(dcRadioButton.checked)
                                        {
                                            serialPortInterface.input(sCPIprotocol.setMultimeterAutoRangeOFF(4))
                                        }
                                        else
                                        {
                                            serialPortInterface.input(sCPIprotocol.setMultimeterAutoRangeOFF(3))
                                        }

                                    }
                                }
                            }



                        }
                    }
                    Slider
                    {
                        id: manualRangeSlider
                        enabled: autoRangeCheckbox.checked? 0:1
                        to: parent.getMaximumRange()
                        onPressedChanged:
                        {
                            if(voltageRadioButton.checked)
                            {
                                if(dcRadioButton.checked)
                                {
                                    setMulimeterRange(2, value)
                                }
                                else
                                {
                                    setMulimeterRange(1, value)
                                }
                            }
                            else
                            {
                                if(dcRadioButton.checked)
                                {
                                    setMulimeterRange(4, value)
                                }
                                else
                                {
                                    setMulimeterRange(3, value)
                                }
                            }
                        }



                    }
                    Label
                    {

                        text: manualRangeSlider.value
                    }

                    function getMaximumRange()
                    {
                        if(voltageRadioButton.checked)
                        {
                            if (acRadioButton.checked)
                            {
                                return 1010
                            }
                            else
                            {
                                return 757.5
                            }
                        }
                        else
                        {
                            return 3.1
                        }
                    }
                }
            }
            Button{
                Layout.alignment: Qt.AlignCenter
                id: runButton
                text: "Run"
                enabled: serialInterfaceAvailable? 1:0
            }
            Button
            {
                Layout.alignment: Qt.AlignCenter
                id: recordBUtton
                text:"Record"
                enabled: serialInterfaceAvailable? 1:0
            }
        }
    }

    SerialPortManager{
        id: serial
    }

    function setMultimeterVoltageDCMode()
    {
        if (serialInterfaceAvailable)
        {
            serialPortInterface.input(sCPIprotocol.setMultimeterVoltageDCMode())
        }
    }

    function setMultimeterVoltageACMode()
    {
        if(serialInterfaceAvailable)
        {
            serialPortInterface.input(sCPIprotocol.setMultimeterVoltageDCMode())
        }
    }

    function setMultimeterCurrentACMode()
    {
        if(serialInterfaceAvailable)
        {
            serialPortInterface.input(sCPIprotocol.setMultimeterCurrentACMode())
        }
    }

    function setMultimeterCurrentDCMode()
    {
        if(serialInterfaceAvailable)
        {
            serialPortInterface.input(sCPIprotocol.setMultimeterCurrentDCMode())
        }
    }

    function setMulimeterRange(rangetype, value)
    {

        if(serialInterfaceAvailable)
        {

            serialPortInterface.input(sCPIprotocol.setMultimeterRange(rangetype,value))

        }
    }

    function setMultimeterAutoRangeOn(rangetype)
    {
        if(serialInterfaceAvailable)
        {
            sCPIprotocol.setMultimeterAutoRangeON(rangetype)
        }
    }
    function setMultimeterAutoRangeOFF(rangetype)
    {
        if(serialInterfaceAvailable)
        {
            sCPIprotocol.setMultimeterAutoRangeOFF(rangetype)
        }
    }

}
