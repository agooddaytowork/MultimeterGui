#include "chartdatasource.h"
#include <QFile>
#include <QTextStream>

QT_CHARTS_USE_NAMESPACE

ChartDataSource::ChartDataSource(QObject * parent): CurrentDataIndex(0), QObject(parent)
{
    m_data.clear();
}


double ChartDataSource::byteArrayToDouble(const QByteArray &data)
{
    QByteArray handleData = data;
    int dataSign;

    if(handleData.at(0) == '+')
    {
        dataSign = 1;
    }
    else
    {
        dataSign = -1;
    }
    //  remove sign
    handleData.remove(0,1);
    // remove \r
    handleData.remove(data.count()-1,1);

    QString tmp;
    tmp.append(handleData);

    return tmp.toDouble()*dataSign;


}

void ChartDataSource::receivedDataHandler(const QByteArray &data)
{

    qDebug() << byteArrayToDouble(data);
    m_data.insert(CurrentDataIndex, byteArrayToDouble(data));
    CurrentDataIndex++;
}

void ChartDataSource::update(QAbstractSeries *series)
{

        if(series)
        {
            QLineSeries *aSeries = static_cast<QLineSeries *>(series);
            aSeries->append(CurrentDataIndex-1, m_data.value(CurrentDataIndex-1));
        }

}

void ChartDataSource::resetDataSource()
{
    m_data.clear();
    CurrentDataIndex = 0;
}

double ChartDataSource::lastValue()
{
    return m_data.value(CurrentDataIndex-1);
}

int ChartDataSource::getCurrentDataIndex()
{
    return CurrentDataIndex;
}

void ChartDataSource::setURLPath(const QString &urlPath)
{
    m_URL = urlPath;
}

void ChartDataSource::recordToCSV()
{
    QFile data(m_URL);

    if(data.open(QFile::ReadWrite | QFile::Append))
    {
        QTextStream out(&data);

        for (int i = 0; i < m_data.count(); i++)
        {
         out << i << ","  << m_data.value(i) << '\n';
        }
    }
}
