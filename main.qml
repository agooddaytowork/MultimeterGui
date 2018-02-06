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
    property int  readTimerInterval: 100
    property bool controlPanelEnable : true
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
                            currentIndex: 1
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

                                    serialPortInterface.input(sCPIprotocol.clearRegisterMultimeter())
                                    serialPortInterface.input(sCPIprotocol.clearModelMultimeter())
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
                    Column
                    {
                        RowLayout
                        {
                            Label
                            {
                                Layout.alignment: Qt.AlignCenter
                                text:"Current Path: "
                            }
                            TextField
                            {
                                Layout.alignment: Qt.AlignCenter
                                id: currectRecordPathTextField

                                Layout.preferredWidth: 300
                            }

                        }

                    }

                    onClosed: {
                        chartDataSource.setURLPath(currectRecordPathTextField.text)
                    }
                }
            }
            Label
            {
                text: "Samples:"
                color: "white"
            }

            ComboBox
            {
                id: timeDivCombobox
                model:  ListModel{
                    ListElement{ text:"10"}
                    ListElement{text: "100"}
                    ListElement{text: "1000"}
                    ListElement{text: "10k"}
                }
            }

            Label
            {
                text: "Max:"
                color: "white"
            }

            TextField
            {
                id: maxRangeYTaxField
                text: "5.0"
                inputMethodHints: Qt.ImhFormattedNumbersOnly


            }

            Label
            {
                text: "Delta:"
                color: "white"
            }
            TextField
            {
                id: deltaRangeYTaxField
                text: "5.0"
                inputMethodHints: Qt.ImhFormattedNumbersOnly

            }

            Button
            {
                id: autoScaleButton
                text: "Auto Scale"

                onClicked:
                {
                    axisY2.min = chartDataSource.getLowerRange(getTimeDiv()) *1.3
                    axisY2.max = chartDataSource.getUpperRange(getTimeDiv())*1.3
                    maxRangeYTaxField.text = axisY2.max
                    deltaRangeYTaxField.text = axisY2.max - axisY2.min
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

                        //                        if(Math.abs(chartView.toMsecsSinceEpoch(axisX1.min) - chartView.toMsecsSinceEpoch(axisX1.max)) <(24*60*60*1000))
                        //                        {
                        //                            axisX1.min = new Date(axisX1.min - 1000000*(1/pinch.scale))
                        //                            axisX1.max = new Date(axisX1.max + 1000000*(1/pinch.scale))
                        //                        }
                        //                        else
                        //                        {
                        //                            axisX1.min = new Date(axisX1.max - (24*60*60*1000))
                        //                        }
                        //                    }
                        //                    else
                        //                    {
                        //                        if(Math.abs(chartView.toMsecsSinceEpoch(axisX1.min) - chartView.toMsecsSinceEpoch(axisX1.max)) > (20*60*1000))
                        //                        {
                        //                            axisX1.min = new Date(axisX1.min + 1000000*pinch.scale)
                        //                            axisX1.max = new Date(axisX1.max - 1000000*pinch.scale)
                        //                        }
                        //                        else
                        //                        {
                        //                            axisX1.min = new Date(axisX1.max - (20*60*1000))
                        //                        }

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
            id: axisX1

            tickCount: 10
            min: 0
            max: getTimeDiv()

        }

        ValueAxis{
            id: axisY2
            min:  parseFloat(maxRangeYTaxField.text) - parseFloat(deltaRangeYTaxField.text)
            max: parseFloat(maxRangeYTaxField.text)
            tickCount: 11

        }

        LineSeries{
            id: dataSerie
            name: "Data"
            useOpenGL: true
            width: 4
            color: "red"
            style: Qt.DotLine
            axisX: axisX1
            axisY: axisY2


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
                title: ""
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                Layout.margins: 10
                Column
                {
                    spacing: 5

                    Row
                    {

                        Label
                        {
                            id: currentValueLabel
                            text: "0"
                            font.pixelSize: 22
                            font.bold: true
                            color: "blue"
                        }
                        Label{
                            id: unitLabel
                            font.pixelSize: 22
                            font.bold: true
                            color: "blue"
                        }
                    }


                    Label
                    {
                        text: "Sampling rate (Hz):"


                    }
                    SpinBox
                    {
                        id: samplingRateSpinBox
                        from: 1
                        to: 15
                        value: 10
                        onValueChanged:
                        {
                            readTimerInterval = 1000/value
                        }
                    }
                }
            }

            GroupBox
            {
                title: "Measurement Mode:"

                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                Layout.margins: 10
                enabled: controlPanelEnable
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
                title: "Current Mode:"
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                Layout.margins: 10
                enabled: controlPanelEnable
                RowLayout
                {
                    RadioButton{
                        id: acRadioButton
                        text: "AC"
                        checked: true
                    }
                    RadioButton
                    {
                        id: dcRadioButton
                        text: "DC"

                    }
                }
            }

            GroupBox
            {
                title: "Measurement Range"
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                Layout.margins: 10
                enabled: controlPanelEnable
                Column{
                    CheckBox
                    {
                        id: autoRangeCheckbox
                        text: "Auto"
                        checked: true

                        onCheckedChanged:
                        {
                            if(serialInterfaceAvailable)
                            {

                            }



                        }
                    }
                    Slider
                    {
                        id: manualRangeSlider
                        enabled: autoRangeCheckbox.checked? 0:1
                        to: parent.getMaximumRange()


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

                onClicked:
                {

                    if(text === "Run")
                    {
                        dataSerie.clear()
                        controlPanelEnable = false
                        if(autoRangeCheckbox.checked)
                        {

                            if(voltageRadioButton.checked)
                            {
                                if(dcRadioButton.checked)
                                {
                                    serialPortInterface.input(sCPIprotocol.setMultimeterVoltageDCMode())
                                    serialPortInterface.input(sCPIprotocol.setMultimeterAutoRangeON(2))
                                    unitLabel.text = "VDC"
                                }
                                else
                                {
                                    serialPortInterface.input(sCPIprotocol.setMultimeterVoltageACMode())
                                    serialPortInterface.input(sCPIprotocol.setMultimeterAutoRangeON(1))
                                    unitLabel.text = "VAC"
                                }
                            }
                            else
                            {
                                if(dcRadioButton.checked)
                                {
                                    serialPortInterface.input(sCPIprotocol.setMultimeterCurrentDCMode())
                                    serialPortInterface.input(sCPIprotocol.setMultimeterAutoRangeON(4))
                                    unitLabel.text = "Amp"
                                }
                                else
                                {
                                    serialPortInterface.input(sCPIprotocol.setMultimeterCurrentACMode())
                                    serialPortInterface.input(sCPIprotocol.setMultimeterAutoRangeON(3))
                                    unitLabel.text = "Amp"
                                }

                            }
                        }
                        else
                        {

                            if(voltageRadioButton.checked)
                            {
                                if(dcRadioButton.checked)
                                {
                                    serialPortInterface.input(sCPIprotocol.setMultimeterVoltageDCMode())
                                    serialPortInterface.input(sCPIprotocol.setMultimeterAutoRangeOFF(2))
                                    serialPortInterface.input(sCPIprotocol.setMultimeterRange(2, manualRangeSlider.value))
                                    unitLabel.text = "VDC"
                                }
                                else
                                {
                                    serialPortInterface.input(sCPIprotocol.setMultimeterVoltageACMode())
                                    serialPortInterface.input(sCPIprotocol.setMultimeterAutoRangeOFF(1))
                                    serialPortInterface.input(sCPIprotocol.setMultimeterRange(1, manualRangeSlider.value))
                                    unitLabel.text = "VAC"
                                }
                            }
                            else
                            {
                                if(dcRadioButton.checked)
                                {
                                    serialPortInterface.input(sCPIprotocol.setMultimeterCurrentDCMode())
                                    serialPortInterface.input(sCPIprotocol.setMultimeterAutoRangeOFF(4))
                                    serialPortInterface.input(sCPIprotocol.setMultimeterRange(4, manualRangeSlider.value))
                                    unitLabel.text = "Amp"
                                }
                                else
                                {
                                    serialPortInterface.input(sCPIprotocol.setMultimeterCurrentACMode())
                                    serialPortInterface.input(sCPIprotocol.setMultimeterAutoRangeOFF(3))
                                    serialPortInterface.input(sCPIprotocol.setMultimeterRange(3, manualRangeSlider.value))
                                    unitLabel.text = "Amp"
                                }

                            }
                        }
                        readTimer.start()
                        text = "Stop"
                    }
                    else
                    {
                        controlPanelEnable = true
                        text = "Run"
                        readTimer.stop()
                        if(recordCheckbox.checked)
                        {
                            chartDataSource.recordToCSV(getMultimeterSetup())
                        }

                        chartDataSource.resetDataSource()
                        serialPortInterface.input(sCPIprotocol.clearRegisterMultimeter())
                        serialPortInterface.input(sCPIprotocol.clearModelMultimeter())

                    }


                }
            }
            CheckBox
            {
                Layout.alignment: Qt.AlignCenter
                id: recordCheckbox
                text:"Record"
                enabled: serialInterfaceAvailable? 1:0
            }
            TextField
            {
                Layout.alignment: Qt.AlignCenter
                id: recordNameTextField
                text:"Record 1"
                enabled: recordCheckbox.checked? 1:0
            }
        }
    }

    SerialPortManager{
        id: serial
    }

    Timer
    {
        id: readTimer;
        interval: readTimerInterval
        repeat: true
        triggeredOnStart: false
        onTriggered: {
            serialPortInterface.input(sCPIprotocol.readMultimeter())
            chartDataSource.update(dataSerie)
            currentValueLabel.text = chartDataSource.lastValue()

            axisX1.min = axisX1.max - getTimeDiv()
            axisX1.max = chartDataSource.getCurrentDataIndex() + 1


        }

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
            serialPortInterface.input(sCPIprotocol.setMultimeterVoltageACMode())
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

    function getTimeDiv()
    {

        if(timeDivCombobox.currentText === "10")
        {
            return 10
        }
        else if(timeDivCombobox.currentText==="100")
        {
            return 100
        }
        else if(timeDivCombobox.currentText==="1000")
        {
            return 1000
        }
        else if(timeDivCombobox.currentText==="10k")
        {
            return 10000
        }
    }

    function getMultimeterSetup()
    {

        if(autoRangeCheckbox.checked)
        {

            if(voltageRadioButton.checked)
            {
                if(dcRadioButton.checked)
                {
                    return recordNameTextField.text+'\n'+"Setup -> Voltage:DC:AutoRangeON:SampleRate=" + samplingRateSpinBox.value + "Hz"
                }
                else
                {
                    return recordNameTextField.text+'\n'+"Setup -> Voltage:AC:AutoRangeON:SampleRate=" + samplingRateSpinBox.value + "Hz"
                }
            }
            else
            {
                if(dcRadioButton.checked)
                {
                    return recordNameTextField.text+'\n'+"Setup -> Current:DC:AutoRangeON:SampleRate=" + samplingRateSpinBox.value + "Hz"
                }
                else
                {
                    return recordNameTextField.text+'\n'+"Setup -> Current:AC:AutoRangeON:SampleRate=" + samplingRateSpinBox.value + "Hz"
                }
            }
        }
        else
        {

            if(voltageRadioButton.checked)
            {
                if(dcRadioButton.checked)
                {
                    return recordNameTextField.text+'\n'+"Setup -> Voltage:DC:AutoRangeOFF:ManualRange=" + manualRangeSlider.value+":SampleRate: " + samplingRateSpinBox.value + "Hz"
                }
                else
                {
                    return recordNameTextField.text+'\n'+"Setup -> Voltage:AC:AutoRangeOFF:ManualRange=" + manualRangeSlider.value+":SampleRate: " + samplingRateSpinBox.value + "Hz"
                }
            }
            else
            {
                if(dcRadioButton.checked)
                {
                    return recordNameTextField.text+'\n'+"Setup -> Current:DC:AutoRangeOFF:ManualRange=" + manualRangeSlider.value+":SampleRate: " + samplingRateSpinBox.value + "Hz"
                }
                else
                {
                    return recordNameTextField.text+'\n'+"Setup -> Current:AC:AutoRangeOFF:ManualRange=" + manualRangeSlider.value+":SampleRate: " + samplingRateSpinBox.value + "Hz"
                }

            }
        }

    }

}
