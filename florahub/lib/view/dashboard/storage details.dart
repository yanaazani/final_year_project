// ignore: unused_import
import 'package:fl_chart/fl_chart.dart' hide PieChart;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:pie_chart/pie_chart.dart';

class StorageDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Reports',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<SalesData> _lineChartData = [];
  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);
  final dataMap = <String, double>{
    "Water Volume Usage": 5,
  };

  final colorList = <Color>[
    Color.fromARGB(148, 167, 216, 238),
  ];

  double dailyVolume = 0.0;
  double dailyAmount = 0.0;
  double monthlyVolume = 0.0;
  double monthlyAmount = 0.0;
  double yearlyVolume = 0.0;
  double yearlyAmount = 0.0;

  String selectedReportType = 'Volume';
  String selectedReportTime = 'Daily';
  String selectedChartType = 'Pie';

  get yValueMapper => null; // Default to Pie chart

  @override
  void initState() {
    _lineChartData = getChartData();
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Water Data Dashboard'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /*Row(
              children: [
                // Dropdown menu for selecting report type
                _buildDropdownButton(selectedReportType, ['Volume', 'Cost'],
                    (value) {
                  setState(() {
                    selectedReportType = value!;
                  });
                }),
                SizedBox(width: 20),
                // Dropdown menu for selecting report time
                _buildDropdownButton(
                    selectedReportTime, ['Daily', 'Monthly', 'Yearly'],
                    (value) {
                  setState(() {
                    selectedReportTime = value!;
                  });
                }),
                SizedBox(width: 20)
              ],
            ),*/
                Card(
                  color: const Color.fromRGBO(232, 245, 233, 1),
                  surfaceTintColor: const Color.fromRGBO(232, 245, 233, 1),
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        //padding:
                        //  EdgeInsets.symmetric(horizontal: 100, vertical: 100),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          'Daily Analysis',
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black),
                                        )
                                      ],
                                    )),
                                /*Expanded(
                                flex: 2,
                                child: Image.asset('assets/images/kids.png'))*/
                              ],
                            ),
                            // Daily Volume Chart
                            SfCartesianChart(
                              //title: ChartTitle(text: 'Daily Analysis'),
                              margin: EdgeInsets.symmetric(vertical: 20),
                              borderWidth: 0,
                              plotAreaBorderWidth: 0,
                              primaryXAxis: CategoryAxis(
                                isVisible: true,
                              ), // x-axis
                              primaryYAxis: NumericAxis(
                                isVisible: true,
                                minimum: 0,
                                maximum: 2,
                                interval: 1,
                              ), // y-axis
                              series: <CartesianSeries>[
                                ColumnSeries<ChartColumnData, String>(
                                  dataSource: chartData,
                                  width: 0.8,
                                  color: Color.fromARGB(148, 167, 216, 238),
                                  xValueMapper: (ChartColumnData data, _) =>
                                      data.x,
                                  yValueMapper: (ChartColumnData data, _) =>
                                      data.y,
                                  dataLabelSettings: DataLabelSettings(
                                    isVisible: true, // Show data labels
                                    labelAlignment: ChartDataLabelAlignment
                                        .top, // Align labels at the top of columns
                                    labelPosition: ChartDataLabelPosition
                                        .outside, // Position labels outside the columns
                                    textStyle: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                /*Container(
                              width: 27,
                              height: 13,
                              decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Volume',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),*/
                                SizedBox(
                                  width: 20,
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // Display data based on selected report time
                _buildDataCard(
                    selectedReportTime, _getReportData(selectedReportTime)),
                SizedBox(height: 20),
                Card(
                  color: const Color.fromRGBO(232, 245, 233, 1),
                  surfaceTintColor: const Color.fromRGBO(232, 245, 233, 1),
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Monthly Analysis',
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    )),
                                /*Expanded(
                                flex: 2,
                                child: Image.asset('assets/images/kids.png'))*/
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 20,
                              ),
                              child: PieChart(
                                dataMap: dataMap,
                                chartType: ChartType.ring,
                                baseChartColor: Color.fromARGB(255, 97, 42, 42)!
                                    .withOpacity(0.15),
                                colorList: colorList,
                                chartValuesOptions: ChartValuesOptions(
                                  showChartValuesInPercentage: true,
                                ),
                                totalValue: 20,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  color: const Color.fromRGBO(232, 245, 233, 1),
                  surfaceTintColor: const Color.fromRGBO(232, 245, 233, 1),
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        //padding:
                        //  EdgeInsets.symmetric(horizontal: 100, vertical: 100),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          'Yearly Analysis',
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black),
                                        )
                                      ],
                                    )),
                                /*Expanded(
                                flex: 2,
                                child: Image.asset('assets/images/kids.png'))*/
                              ],
                            ),
                            // Daily Volume Chart
                            // Monthly Volume Chart
                            SfCartesianChart(
                              //title: ChartTitle(text: 'Yearly Analysis'),
                              legend: Legend(isVisible: true),
                              tooltipBehavior: _tooltipBehavior,
                              series: <CartesianSeries>[
                                LineSeries<SalesData, double>(
                                  // Use LineSeries explicitly
                                  name: 'Sales',
                                  dataSource: _lineChartData,
                                  xValueMapper: (SalesData sales, _) =>
                                      sales.year,
                                  yValueMapper: (SalesData sales, _) =>
                                      sales.sales,
                                  dataLabelSettings:
                                      DataLabelSettings(isVisible: true),
                                ),
                              ],
                              primaryXAxis: NumericAxis(
                                edgeLabelPlacement: EdgeLabelPlacement.shift,
                              ),
                              primaryYAxis: NumericAxis(
                                labelFormat: "{value}M",
                                numberFormat: NumberFormat.simpleCurrency(
                                    decimalDigits: 0),
                              ),
                            ),

                            Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                /*Container(
                              width: 27,
                              height: 13,
                              decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Volume',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),*/
                                SizedBox(
                                  width: 20,
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                _buildDataCard(
                    selectedReportTime, _getReportData(selectedReportTime)),
                SizedBox(height: 20),
              ],
            ),
          ),
        ));
  }

  Widget _buildDropdownButton(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    Color fillColor = Colors.transparent,
    Color borderColor = Colors.transparent,
  }) {
    return SizedBox(
      width: 100, // Adjust width as needed
      height: 50, // Adjust height as needed
      child: Container(
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: borderColor),
        ),
        child: DropdownButton<String>(
          value: value,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    // Add your bar chart implementation here
    return Text('Bar Chart');
  }

  Widget _buildPieChart() {
    // Add your pie chart implementation here
    return Text('Pie Chart');
  }

  double _getReportData(String reportTime) {
    switch (reportTime) {
      case 'Daily':
        return selectedReportType == 'Volume' ? dailyVolume : dailyAmount;
      case 'Monthly':
        return selectedReportType == 'Volume' ? monthlyVolume : monthlyAmount;
      case 'Yearly':
        return selectedReportType == 'Volume' ? yearlyVolume : yearlyAmount;
      default:
        return 0.0;
    }
  }

  Widget _buildDataCard(String title, double value) {
    return Card(
      elevation: 4.0,
      color: const Color.fromRGBO(232, 245, 233, 1), // Background color
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title ${selectedReportType == 'Volume' ? 'Volume' : 'Cost'}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Text color
              ),
            ),
            SizedBox(height: 8.0),
            value == 0.0
                ? Text(
                    'No data available',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  )
                : Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black26,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  List<SalesData> getChartData() {
    final List<SalesData> lineChartData = [
      SalesData(2017, 25),
      SalesData(2018, 20),
      SalesData(2019, 10),
      SalesData(2020, 15),
      SalesData(2021, 20),
    ];
    return lineChartData;
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final double year;
  final double sales;
}

// Bar Chart - Daily Volume Chart
class ChartColumnData {
  ChartColumnData(this.x, this.y);
  final String x;
  final double? y;
}

final List<ChartColumnData> chartData = <ChartColumnData>[
  ChartColumnData('Mo', 1.7),
  ChartColumnData('Tu', 1.3),
  ChartColumnData('We', 1),
  ChartColumnData('Th', 1.5),
  ChartColumnData('Fr', 0.5),
  ChartColumnData('Sa', 1.7),
  ChartColumnData('Su', 1.7),
];
