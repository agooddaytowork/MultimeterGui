#include <QtWidgets/QApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "scpiprotocol.h"
#include "simpleserialinterface.h"
#include "serialportmanager.h"
#include <QThread>
int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    QQmlApplicationEngine engine;
#ifdef Q_OS_WIN
    QString extraImportPath(QStringLiteral("%1/../../../../%2"));
#else
    QString extraImportPath(QStringLiteral("%1/../../../%2"));
#endif

    QThread serialInterfaceThread;

    SimpleSerialInterface aSimpleInterface;

    //aSimpleInterface->moveToThread(&serialInterfaceThread);

    qmlRegisterType<SerialPortManager>("serialPortManager",1,0,"SerialPortManager");
//    SimpleSerialInterface aSimpleInterface;

//    aSimpleInterface.setPortName("COM4");
//    aSimpleInterface.setBaudRate(9600);
//    aSimpleInterface.connect();

    SCPIprotocol aSCPIprotocol;


//    aSimpleInterface.input(test.ClearRegisters().GenMsg());
//    aSimpleInterface.input(test.ClearModel().GenMsg());
//    aSimpleInterface.input(test.SetVoltageDCMode().GenMsg());
//    aSimpleInterface.input(test.VoltageConfig().DCMode().UpperRange("300").GenMsg());
//    aSimpleInterface.input(test.Read().GenMsg());

    QQmlContext *thisContext = engine.rootContext();
    thisContext->setContextProperty("serialPortInterface", &aSimpleInterface);
    thisContext->setContextProperty("sCPIprotocol", &aSCPIprotocol);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
