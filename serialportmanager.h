#ifndef SERIALPORTMANAGER_H
#define SERIALPORTMANAGER_H


#include "shared/commonthings.h"
#include <QSerialPortInfo>
#include <QVariant>

class SerialPortManager: public QObject
{

    Q_OBJECT
public:
    explicit SerialPortManager(QObject *parent = nullptr);
    Q_INVOKABLE static QVariant availablePorts()
    {
        QList<QSerialPortInfo> portsAvailable = QSerialPortInfo::availablePorts();
        QStringList namesOfAvailablePorts;

        for(const QSerialPortInfo &port : portsAvailable)
        {
            namesOfAvailablePorts << port.portName();
        }

        return QVariant::fromValue(namesOfAvailablePorts);
    }

};

#endif // SERIALPORTMANAGER_H
