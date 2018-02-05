#ifndef SCPIPROTOCOL_H
#define SCPIPROTOCOL_H

#include "anLogger/src/anlogger.h"
#include "shared/commonthings.h"

class SCPIprotocol: public QObject
{
    Q_OBJECT

    static const QHash<QString, QByteArray> CommandFromFunctionName;
    QByteArray mMessage;
    QByteArray mCommandSub1;
    QByteArray mCommandSub2;
    QByteArray mCommandSub3;
    QByteArray mLastSubValue;
    QHash<QString, QByteArray> mCommand;


public:

    enum multimeterRange{
        VoltageDCRange,
        VoltageACRange,
        CurrentDCRange,
        CurrentACRange
    };
    Q_ENUMS(multimeterRange)

    explicit SCPIprotocol(QObject *parent = nullptr);
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

     Q_INVOKABLE const QByteArray clearRegisterMultimeter();
     Q_INVOKABLE const QByteArray clearModelMultimeter();
     Q_INVOKABLE const QByteArray setMultimeterVoltageDCMode();
     Q_INVOKABLE const QByteArray setMultimeterVoltageACMode();
     Q_INVOKABLE const QByteArray setMultimeterCurrentDCMode();
     Q_INVOKABLE const QByteArray setMultimeterCurrentACMode();
     Q_INVOKABLE const QByteArray setMultimeterRange(const quint16  &range, const float &value);
     Q_INVOKABLE const QByteArray setMultimeterAutoRangeON(const quint16  &range);
     Q_INVOKABLE const QByteArray setMultimeterAutoRangeOFF(const quint16  &range);

     Q_INVOKABLE const QByteArray readMultimeter();
};

#endif // SCPIPROTOCOL_H
