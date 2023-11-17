import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fl_chart/fl_chart.dart';

class SalesData {
  String month;
  int totalSales;

  SalesData(this.month, this.totalSales);
}

class SalesHistogram extends StatefulWidget {
  @override
  _SalesHistogramState createState() => _SalesHistogramState();
}

class _SalesHistogramState extends State<SalesHistogram> {
  List<SalesData> salesData = [];

  @override
  void initState() {
    super.initState();
    loadSalesData();
  }

  Future<void> loadSalesData() async {
    final rawData = await rootBundle.loadString('data/datapenjualan.csv');
    final List<List<dynamic>> data =
        const CsvToListConverter(fieldDelimiter: ';').convert(rawData);

    setState(() {
      salesData.clear();
      for (int i = 1; i < data.length; i++) {
        String month = data[i][0].toString();
        int totalSales = int.tryParse(data[i][1].toString()) ?? 0;
        salesData.add(SalesData(month, totalSales));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Histogram'),
      ),
      body: Center(
        child: salesData.isEmpty
            ? CircularProgressIndicator()
            : Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total Penjualan per Bulan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 300,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 10,
                          titlesData: FlTitlesData(
                            leftTitles: SideTitles(showTitles: false),
                            rightTitles: SideTitles(showTitles: false),
                            bottomTitles: SideTitles(
                              showTitles: true,
                              margin: 10,
                              getTitles: (double value) {
                                int index = value.toInt();
                                if (index >= 0) {
                                  return salesData[index].month;
                                }
                                return '';
                              },
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: salesData
                              .asMap()
                              .entries
                              .map(
                                (entry) => BarChartGroupData(
                                  x: entry.key,
                                  barRods: [
                                    BarChartRodData(
                                      y: entry.value.totalSales.toDouble() /
                                          1000,
                                      width: 15,
                                      colors: [Colors.blue],
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SalesHistogram(),
  ));
}
