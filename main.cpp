#include <QtWidgets/QApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "scpiprotocol.h"
#include "simpleserialinterface.h"
#include "serialportmanager.h"
#include "chartdatasource.h"
#include <QIcon>
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


    SimpleSerialInterface aSimpleInterface;
    qmlRegisterType<SerialPortManager>("serialPortManager",1,0,"SerialPortManager");

    SCPIprotocol aSCPIprotocol;
    ChartDataSource aChartDataSource;

    QObject::connect(&aSimpleInterface,SIGNAL(output(QByteArray)),&aChartDataSource,SLOT(receivedDataHandler(QByteArray)));

    QQmlContext *thisContext = engine.rootContext();
    thisContext->setContextProperty("serialPortInterface", &aSimpleInterface);
    thisContext->setContextProperty("sCPIprotocol", &aSCPIprotocol);
    thisContext->setContextProperty("chartDataSource",&aChartDataSource);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
