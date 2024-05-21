import 'package:fl_chart/fl_chart.dart' hide PieChart;
import 'package:florahub/controller/RequestController.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WaterDataVolume extends StatefulWidget {
  const WaterDataVolume({super.key});

  @override
  State<WaterDataVolume> createState() => _WaterDataVolumeState();
}

class _WaterDataVolumeState extends State<WaterDataVolume>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ChartColumnData> chartData = [];
  Map<String, double> _pieChartData = {};
  List<SalesData> _lineChartData = [];
  List<ChartColumnData> _dailyChartData = [];
  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);
  final dataMap = <String, double>{
    "Water Volume Usage": 5,
  };

  final colorList = <Color>[
    Color.fromARGB(148, 167, 216, 238),
  ];

  // Daily total volume
  Future<void> getTotalVolumeDaily() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "water/totalVolumeDaily", server: "http://$server:8080");
    await req.get();
    try {
      if (req.status() == 200) {
        List<dynamic> result = req.result();

        // Clear the existing chartData
        chartData.clear();

        // Get the current date
        DateTime now = DateTime.now();

        // Iterate through the fetched data and filter by the latest week
        for (var item in result) {
          if (item is List && item.length == 2) {
            if (item[0] is String) {
              DateTime dataDate = DateTime.parse(item[0]);
              if (dataDate.isAfter(now.subtract(Duration(days: 7)))) {
                // Add data to chartData if it's within the last week
                chartData.add(ChartColumnData(
                  item[0].toString(), // Key as String
                  double.parse(item[1].toStringAsFixed(4)),
                ));
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // Monthly total volume
  Future<void> getTotalVolumeMonthly() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "water/totalVolumeMonthly", server: "http://$server:8080");
    await req.get();
    try {
      if (req.status() == 200) {
        List<dynamic> result = req.result();
        Map<String, double> monthlyData = {};
        print("Result structure:");
        print(result.runtimeType); // Print the type of the result
        if (result.isNotEmpty) {
          print(result[0].runtimeType); // Print the type of the first item
          print(result[0]); // Print the first item itself
          print(result[0][0]
              .runtimeType); // Print the type of the first element in the first item
        }
        // Process the result here based on its structure
        // For example:
        for (var item in result) {
          int year = item[0];
          int month = item[1];
          double totalVolume = item[2];
          // Create a key for the monthly data
          String monthYearKey = '$year-$month';
          // Store the total volume for the month
          monthlyData[monthYearKey] = totalVolume;
        }

        // Get the latest month's data
        DateTime now = DateTime.now();
        int latestYear = now.year;
        int latestMonth = now.month;
        String latestMonthKey = '$latestYear-$latestMonth';
        double latestMonthVolume = monthlyData[latestMonthKey] ?? 0;

        // Update _pieChartData with the latest month's data only
        setState(() {
          _pieChartData = {latestMonthKey: latestMonthVolume};
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // Yearly total volume
  Future<void> getTotalVolumeYearly() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "water/totalVolumeYearly", server: "http://$server:8080");
    await req.get();
    try {
      if (req.status() == 200) {
        List<dynamic> result = req.result();
        List<SalesData> yearlyData = [];
        for (var item in result) {
          int year = item[0];
          double volume = double.parse(item[1].toStringAsFixed(2));
          yearlyData.add(SalesData(year.toDouble(), volume));
        }
        setState(() {
          _lineChartData = yearlyData;
        });
      } else {
        print("Request failed with status: ${req.status()}");
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // Monthly total cost
  Future<void> getTotalCostMonthly() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "water/totalCostMonthly", server: "http://$server:8080");
    await req.get();
    try {
      if (req.status() == 200) {
        List<dynamic> result = req.result();
        Map<String, double> monthlyCostData = {};
        List<ChartColumnData> monthlyChartData = [];

        if (result.isNotEmpty) {
          // Set the start year and month
          int startYear = 2024;
          int startMonth = 1; // January

          // Loop through the result to find data for the specified period
          for (var item in result) {
            if (item is List<dynamic> && item.length == 3) {
              int? year = item[0] as int?;
              int? month = item[1] as int?;
              double? totalMonthlyCost = item[2] as double?;

              if (year != null && month != null && totalMonthlyCost != null) {
                // Check if the data is within the specified period
                if (year > startYear ||
                    (year == startYear && month >= startMonth)) {
                  String monthYearKey =
                      '$year-${month.toString().padLeft(2, '0')}';

                  // Store the total monthly cost for the specified period
                  monthlyCostData[monthYearKey] = totalMonthlyCost;
                  monthlyChartData
                      .add(ChartColumnData(monthYearKey, totalMonthlyCost));
                }
              } else {
                print('Incomplete data for an item: $item');
              }
            } else {
              print('Invalid item format: $item');
            }
          }

          setState(() {
            _dailyChartData = monthlyChartData;
            print(monthlyChartData);
          });
        } else {
          print('Empty result received');
        }

        // Print the retrieved monthly cost data
        print('Monthly Cost Data: $monthlyCostData');
      } else {
        print('Failed to fetch data. Status code: ${req.status()}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // Yearly total cost
  Future<void> getTotalCostYearly() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "water/totalCostYearly", server: "http://$server:8080");
    await req.get();
    try {
      if (req.status() == 200) {
        req.result();
        print(req.result());
        //setState(() {});
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    _pieChartData = {};
    getTotalVolumeDaily();
    getTotalVolumeMonthly();
    getTotalVolumeYearly();
    getTotalCostMonthly();
    //getTotalCostYearly();
    _lineChartData = getChartData();
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Water Volume'),
            Tab(text: 'Water Cost'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Contents of Tab 1
          _volume(),
          // Contents of Tab 2
          _cost(),
        ],
      ),
    );
  }

  List<SalesData> getChartData() {
    return _lineChartData;
  }

  Widget _volume() {
    final dataMap = _pieChartData.isNotEmpty
        ? Map<String, double>.from(_pieChartData)
        : {"Water Volume Usage": 0.0};

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: const Color.fromRGBO(232, 245, 233, 1),
              surfaceTintColor: const Color.fromRGBO(232, 245, 233, 1),
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
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
                          margin: EdgeInsets.symmetric(vertical: 20),
                          borderWidth: 0,
                          plotAreaBorderWidth: 0,
                          primaryXAxis: CategoryAxis(
                            isVisible: true,
                          ), // x-axis
                          primaryYAxis: NumericAxis(
                            labelFormat: '{value} m³',
                            isVisible: true,
                            minimum: 0,
                            maximum: 50,
                            interval: 1,
                          ), // y-axis
                          series: <CartesianSeries>[
                            ColumnSeries<ChartColumnData, String>(
                              dataSource: chartData,
                              width: 0.8,
                              color: Color.fromARGB(148, 167, 216, 238),
                              xValueMapper: (ChartColumnData data, _) => data.x,
                              yValueMapper: (ChartColumnData data, _) => data.y,
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
                              width: 40,
                            ),
                          ],
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
                              baseChartColor: Color.fromARGB(255, 160, 63, 63)!
                                  .withOpacity(0.15),
                              colorList: colorList,
                              chartValuesOptions: ChartValuesOptions(
                                showChartValuesInPercentage: false,
                              ),
                              totalValue: 100),
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
                        SfCartesianChart(
                          //title: ChartTitle(text: 'Yearly Analysis'),
                          margin: EdgeInsets.symmetric(vertical: 20),
                          borderWidth: 0,
                          plotAreaBorderWidth: 0,
                          legend: Legend(isVisible: true),
                          tooltipBehavior: _tooltipBehavior,
                          series: <CartesianSeries>[
                            LineSeries<SalesData, double>(
                              // Use LineSeries explicitly
                              name: 'Water Volume Usage',
                              dataSource: _lineChartData,
                              xValueMapper: (SalesData sales, _) => sales.year,
                              yValueMapper: (SalesData sales, _) => sales.sales,
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                textStyle: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                          primaryXAxis: NumericAxis(
                            isVisible: true,
                            minimum: 2020, // Set minimum value to 2020
                            maximum:
                                2024, // Set maximum value to 2024 or any other appropriate maximum value
                            interval:
                                1, // Set the interval to 1 to display each year
                            labelFormat: '{value}',
                          ),
                          primaryYAxis: NumericAxis(
                            labelFormat: '{value} m³',
                            isVisible: true,
                            minimum: 0,
                            maximum: 100,
                            interval: 20,
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
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _cost() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                                      'Montly Analysis',
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
                            maximum: 100,
                            interval: 20,
                            labelFormat: 'RM{value}',
                          ), // y-axis
                          series: <CartesianSeries>[
                            ColumnSeries<ChartColumnData, String>(
                              dataSource: _dailyChartData,
                              width: 0.8,
                              color: Color.fromARGB(148, 167, 216, 238),
                              xValueMapper: (ChartColumnData data, _) => data.x,
                              yValueMapper: (ChartColumnData data, _) =>
                                  data.y!,
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
                                  sales.year.toDouble(),
                              yValueMapper: (SalesData sales, _) => sales.sales,
                              dataLabelSettings:
                                  DataLabelSettings(isVisible: true),
                            ),
                          ],
                          primaryXAxis: NumericAxis(
                            edgeLabelPlacement: EdgeLabelPlacement.shift,
                          ),
                          primaryYAxis: NumericAxis(
                            labelFormat: "{value}M",
                            numberFormat:
                                NumberFormat.simpleCurrency(decimalDigits: 0),
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
            SizedBox(height: 20),
          ],
        ),
      ),
    );
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
