#include "scpiprotocol.h"

SCPIprotocol::SCPIprotocol(): mMessage(""), mCommandSub1(""),mCommandSub2(""),mCommandSub3(""),mLastSubValue("")
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
    mLastSubValue = "ON";

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
