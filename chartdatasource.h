#ifndef CHARTDATASOURCE_H
#define CHARTDATASOURCE_H

#include "shared/commonthings.h"
#include "QtCharts/QAbstractSeries"
#include "QtCharts/QLineSeries"
#include <QMap>

QT_CHARTS_USE_NAMESPACE
class ChartDataSource: public QObject
{

    Q_OBJECT

    QMap<int,double> m_data;
    int CurrentDataIndex;
    double byteArrayToDouble(const QByteArray &data);
    QString m_URL;
public:
    explicit ChartDataSource(QObject *parent = nullptr);

public slots:
     void receivedDataHandler(const QByteArray &data);
     void update(QAbstractSeries *series);
     void resetDataSource();
     double lastValue();
     int getCurrentDataIndex();
     void recordToCSV(const QString &setup);
     void setURLPath(const QString &urlPath);
     double getUpperRange(const int &timeDiv);
     double getLowerRange(const int &timeDiv);
};

#endif // CHARTDATASOURCE_H
