#ifndef SIMPLESERIALINTERFACE_H
#define SIMPLESERIALINTERFACE_H

#include <QSerialPort>
#include <QSerialPortInfo>
#include "shared/commonthings.h"


class SimpleSerialInterface: public QObject
{
    Q_OBJECT

QSerialPort mSerialPort;

    QByteArray mPortName;
    quint16 mBaudrate;

signals:
    void connected();
    void disconnected();
    void errorsOcurred();
    void output(const QByteArray &data);

public:
    explicit SimpleSerialInterface(QObject * parent = nullptr);
    void setPortName(const QByteArray &name);
    void setBaudRate(const quint16 &baudrate);

public slots:
    void connect();
    void disconnect();
    void input(const QByteArray &input);

private slots:
    void receivedDataHandler();
    void serialPortErrorHandler( const QSerialPort::SerialPortError &error);

};

#endif // SIMPLESERIALINTERFACE_H
