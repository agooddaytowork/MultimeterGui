#include "scpiprotocol.h"

SCPIprotocol::SCPIprotocol(QObject *parent): mMessage(""), mCommandSub1(""),mCommandSub2(""),mCommandSub3(""),mLastSubValue(""),QObject(parent)
{

}

const QHash<QString, QByteArray> SCPIprotocol::CommandFromFunctionName = QHash<QString, QByteArray>
({
     {"Read",":READ?"},
     {"SetVoltageDCMode", ":SENS:FUNC 'VOLT:DC'"},
     {"SetVoltageACMode", ":SENS:FUNC 'VOLT:AC'"},
     {"SetCurrentDCMode", ":SENS:FUNC 'CURR:DC'"},
     {"SetCurrentACMode", ":SENS:FUNC 'CURR:AC"},
     {"VoltageConfig", ":SENS:VOLT"},
     {"CurrentConfig", ":SENS:CURR"},
     {"DCMode",":DC"},
     {"ACMode",":AC"},
     {"UpperRange",":RANG"},
     {"AutoRangeON",":RANG:AUTO ON"},
     {"AutoRangeOFF",":RANG:AUTO OFF"},
     {"ClearRegisters", "*RST"},
     {"ClearModel","*CLS"}
 });

const QByteArray SCPIprotocol::GenMsg()
{
    mMessage.clear();

    mMessage = mCommandSub1 + mCommandSub2 + mCommandSub3+ mLastSubValue + '\r';

    mCommandSub1.clear();
    mCommandSub2.clear();
    mCommandSub3.clear();
    mLastSubValue.clear();
    return mMessage;
}

const QByteArray SCPIprotocol::GetMsg()
{
    return mMessage;
}

SCPIprotocol &SCPIprotocol::SetVoltageACMode()
{
    mCommandSub1 = CommandFromFunctionName.value(__func__);
    return *this;
}

SCPIprotocol &SCPIprotocol::SetVoltageDCMode()
{
    mCommandSub1 = CommandFromFunctionName.value(__func__);
    return *this;
}

SCPIprotocol &SCPIprotocol::SetCurrentACMode()
{
    mCommandSub1 = CommandFromFunctionName.value(__func__);
    return *this;
}

SCPIprotocol &SCPIprotocol::SetCurrentDCMode()
{
    mCommandSub1 = CommandFromFunctionName.value(__func__);
    return *this;
}

SCPIprotocol &SCPIprotocol::VoltageConfig()
{
    mCommandSub1 = CommandFromFunctionName.value(__func__);
    return *this;
}

SCPIprotocol &SCPIprotocol::CurrentConfig()
{
    mCommandSub1 = CommandFromFunctionName.value(__func__);
    return *this;
}

SCPIprotocol &SCPIprotocol::DCMode()
{
    mCommandSub2 = CommandFromFunctionName.value(__func__);
    return *this;
}


SCPIprotocol &SCPIprotocol::ACMode()
{
    mCommandSub2 = CommandFromFunctionName.value(__func__);
    return * this;
}

SCPIprotocol &SCPIprotocol::UpperRange(const QByteArray &value)
{
    //later add validation in GUI
    mCommandSub3 = CommandFromFunctionName.value(__func__);
    mLastSubValue = " " + value;

    return *this;
}

SCPIprotocol &SCPIprotocol::AutoRangeOFF()
{

    mCommandSub3 = CommandFromFunctionName.value(__func__);

    return *this;
}

SCPIprotocol &SCPIprotocol::AutoRangeON()
{

    mCommandSub3 = CommandFromFunctionName.value(__func__);

    return *this;
}

SCPIprotocol &SCPIprotocol::Read()
{
    mCommandSub1 = CommandFromFunctionName.value(__func__);
    return *this;
}

SCPIprotocol &SCPIprotocol::ClearModel()
{
    mCommandSub1 = CommandFromFunctionName.value(__func__);
    return *this;
}

SCPIprotocol &SCPIprotocol::ClearRegisters()
{
    mCommandSub1 = CommandFromFunctionName.value(__func__);
    return *this;
}

const QByteArray SCPIprotocol::clearModelMultimeter()
{
    SCPIprotocol tmp;

    return tmp.ClearModel().GenMsg();
}

const QByteArray SCPIprotocol::clearRegisterMultimeter()
{
    SCPIprotocol tmp;
    return tmp.ClearRegisters().GenMsg();
}

const QByteArray SCPIprotocol::setMultimeterVoltageDCMode()
{
    SCPIprotocol tmp;
    return tmp.SetVoltageDCMode().GenMsg();
}

const QByteArray SCPIprotocol::setMultimeterVoltageACMode()
{
    SCPIprotocol tmp;
    return tmp.SetVoltageACMode().GenMsg();
}

const QByteArray SCPIprotocol::setMultimeterCurrentACMode()
{
    SCPIprotocol tmp;
    return tmp.SetCurrentACMode().GenMsg();
}

const QByteArray SCPIprotocol::setMultimeterCurrentDCMode()
{
    SCPIprotocol tmp;
    return tmp.SetCurrentDCMode().GenMsg();
}


const QByteArray SCPIprotocol::setMultimeterRange(const quint16 &range,const float &value)
{
    SCPIprotocol tmp;
    switch (range) {
    case 1:
        return tmp.VoltageConfig().ACMode().UpperRange(QByteArray::number(value)).GenMsg();

        break;
    case 2:
        return tmp.VoltageConfig().DCMode().UpperRange(QByteArray::number(value)).GenMsg();
    break;

    case 3:
   return     tmp.CurrentConfig().ACMode().UpperRange(QByteArray::number(value)).GenMsg();

        break;
    case 4:
        return tmp.CurrentConfig().DCMode().UpperRange(QByteArray::number(value)).GenMsg();
    }

    return tmp.GenMsg();
}

const QByteArray SCPIprotocol::setMultimeterAutoRangeON(const quint16 &range)
{

    SCPIprotocol tmp;
    switch (range) {
    case 1:
        return tmp.VoltageConfig().ACMode().AutoRangeON().GenMsg();

        break;
    case 2:
        return tmp.VoltageConfig().DCMode().AutoRangeON().GenMsg();
    break;

    case 3:
   return     tmp.CurrentConfig().ACMode().AutoRangeON().GenMsg();

        break;
    case 4:
        return tmp.CurrentConfig().DCMode().AutoRangeON().GenMsg();
    }

    return tmp.GenMsg();
}

const QByteArray SCPIprotocol::setMultimeterAutoRangeOFF(const quint16  &range)
{
    SCPIprotocol tmp;
    switch (range) {
    case 1:
        return tmp.VoltageConfig().ACMode().AutoRangeOFF().GenMsg();

        break;
    case 2:
        return tmp.VoltageConfig().DCMode().AutoRangeOFF().GenMsg();
    break;

    case 3:
   return     tmp.CurrentConfig().ACMode().AutoRangeOFF().GenMsg();

        break;
    case 4:
        return tmp.CurrentConfig().DCMode().AutoRangeOFF().GenMsg();
    }

    return tmp.GenMsg();
}

const QByteArray SCPIprotocol::readMultimeter()
{
    SCPIprotocol tmp;

    return tmp.Read().GenMsg();
}

