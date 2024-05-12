import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

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
  String selectedChips = 'Dec';
  List<String> chips = [
    'Nov',
    'Dec',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Water Data Dashboard'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
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
                SizedBox(width: 20),
                // Dropdown menu for selecting chart type
                _buildDropdownButton(
                  selectedChartType,
                  ['Bar', 'Pie'],
                  (value) {
                    setState(() {
                      selectedChartType = value!;
                    });
                  },
                ),
              ],
            ),
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
                                    SizedBox(height: 20,),
                                    Text(
                                      'Stacked column chart',
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
                        SfCartesianChart(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          borderWidth: 0,
                          plotAreaBorderWidth: 0,
                          primaryXAxis: CategoryAxis(
                            isVisible: false,
                          ),
                          primaryYAxis: NumericAxis(
                            isVisible: false,
                            minimum: 0,
                            maximum: 2,
                            interval: 0.5,
                          ),
                          series: <CartesianSeries>[
                            ColumnSeries<ChartColumnData, String>(
                              dataSource: chartData,
                              width: 0.8,
                              color: Colors.yellow,
                              xValueMapper: (ChartColumnData data, _) => data.x,
                              yValueMapper: (ChartColumnData data, _) => data.y,
                            ),
                            ColumnSeries<ChartColumnData, String>(
                              dataSource: chartData,
                              width: 0.8,
                              color: Colors.purple,
                              xValueMapper: (ChartColumnData data, _) => data.x,
                              yValueMapper: (ChartColumnData data, _) =>
                                  data.y1,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                            ),
                            Container(
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
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Container(
                              width: 27,
                              height: 13,
                              decoration: BoxDecoration(
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Bill Cost (RM)',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Chart based on selected type
                  selectedChartType == 'Bar'
                      ? _buildBarChart()
                      : _buildPieChart(),
                  SizedBox(height: 20),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Display data based on selected report time
            _buildDataCard(
                selectedReportTime, _getReportData(selectedReportTime)),
          ],
        ),
      ),
    );
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
}

class ChartColumnData {
  ChartColumnData(this.x, this.y, this.y1);
  final String x;
  final double? y;
  final double? y1;
}

final List<ChartColumnData> chartData = <ChartColumnData>[
  ChartColumnData('Mo', 1.7, 1.7),
  ChartColumnData('Tu', 1.3, 1.3),
  ChartColumnData('We', 1, 1),
  ChartColumnData('Th', 1.5, 1.5),
  ChartColumnData('Fr', 0.5, 0.5),
];
