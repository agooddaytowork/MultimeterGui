#include "simpleserialinterface.h"

SimpleSerialInterface::SimpleSerialInterface(QObject *parent): mSerialPort(parent), mPortName("COM1"), mBaudrate(9600),QObject(parent)
{

    QObject::connect(&mSerialPort,SIGNAL(readyRead()),this,SLOT(receivedDataHandler()));
    QObject::connect(&mSerialPort,SIGNAL(error(QSerialPort::SerialPortError)),this,SLOT(serialPortErrorHandler(QSerialPort::SerialPortError)));

}

void SimpleSerialInterface::setPortName(const QByteArray &name)
{
    if(mPortName != name)
    {
        mPortName = name;
        if(mSerialPort.isOpen())
        {
            this->disconnect();
        }
    }
}

void SimpleSerialInterface::setBaudRate(const quint16 &baudrate)
{
    if(mBaudrate != baudrate)
    {
        mBaudrate = baudrate;
        if(mSerialPort.isOpen())
        {
            this->disconnect();
        }
    }
}

bool SimpleSerialInterface::connect()
{
    if(mSerialPort.isOpen())
    {
        this->disconnect();
    }

    mSerialPort.setPortName(mPortName);
    mSerialPort.setBaudRate(mBaudrate);
    if(!mSerialPort.open(QIODevice::ReadWrite))
    {
        emit errorsOcurred();
        return false;
    }
    else
    {
        emit connected();

    }
return true;
}

bool SimpleSerialInterface::disconnect()
{
    if(mSerialPort.disconnect())
    {
        emit disconnected();
        return true;
    }
    return false;
}

void SimpleSerialInterface::input(const QByteArray &input)
{
    qDebug() << input;
    mSerialPort.write(input);
}

void SimpleSerialInterface::receivedDataHandler()
{
    QByteArray data;
    data.clear();
    while(!mSerialPort.atEnd())
    {
        data += mSerialPort.readAll();
    }

    emit output(data);
}


void SimpleSerialInterface::serialPortErrorHandler(const QSerialPort::SerialPortError &error)
{

}
