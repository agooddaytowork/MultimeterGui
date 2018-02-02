#ifndef SCPIPROTOCOL_H
#define SCPIPROTOCOL_H

#include "anLogger/src/anlogger.h"
#include "shared/commonthings.h"

class SCPIprotocol
{

    static const QHash<QString, QByteArray> CommandFromFunctionName;
    QByteArray mMessage;
    QByteArray mCommandSub1;
    QByteArray mCommandSub2;
    QByteArray mCommandSub3;
    QByteArray mLastSubValue;
    QHash<QString, QByteArray> mCommand;


public:
    explicit SCPIprotocol();
    SCPIprotocol &ClearRegisters();
    SCPIprotocol &ClearModel();
    SCPIprotocol &SetVoltageDCMode();
    SCPIprotocol &SetVoltageACMode();
    SCPIprotocol &SetCurrentDCMode();
    SCPIprotocol &SetCurrentACMode();
    SCPIprotocol &VoltageConfig();
    SCPIprotocol &CurrentConfig();
    SCPIprotocol &DCMode();
    SCPIprotocol &ACMode();

    SCPIprotocol &UpperRange(const QByteArray &value);
    SCPIprotocol &AutoRangeON();
    SCPIprotocol &AutoRangeOFF();

    SCPIprotocol &Read();
    const QByteArray GenMsg();
    const QByteArray GetMsg();

};

#endif // SCPIPROTOCOL_H
