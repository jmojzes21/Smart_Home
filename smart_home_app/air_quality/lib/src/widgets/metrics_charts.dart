import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/aq_history_data.dart';

class TemperatureChart extends StatelessWidget {
  final AqHistoryData aqData;

  const TemperatureChart({super.key, required this.aqData});

  @override
  Widget build(BuildContext context) {
    return MetricsChart(
      spots: aqData.data.map((e) => FlSpot(e.time.toDouble(), e.temperature)).toList(),
      lineColor: Color(0xFFFF485D),
      minY: aqData.temperatureRange[0],
      maxY: aqData.temperatureRange[1],
    );
  }
}

class HumidityChart extends StatelessWidget {
  final AqHistoryData aqData;

  const HumidityChart({super.key, required this.aqData});

  @override
  Widget build(BuildContext context) {
    return MetricsChart(
      spots: aqData.data.map((e) => FlSpot(e.time.toDouble(), e.humidity)).toList(),
      lineColor: Color(0xFF0A64EA),
      minY: aqData.humidityRange[0],
      maxY: aqData.humidityRange[1],
    );
  }
}

class PressureChart extends StatelessWidget {
  final AqHistoryData aqData;

  const PressureChart({super.key, required this.aqData});

  @override
  Widget build(BuildContext context) {
    return MetricsChart(
      spots: aqData.data.map((e) => FlSpot(e.time.toDouble(), e.pressure)).toList(),
      lineColor: Color(0xFFFCCA05),
      minY: aqData.pressureRange[0],
      maxY: aqData.pressureRange[1],
    );
  }
}

class Pm25Chart extends StatelessWidget {
  final AqHistoryData aqData;

  const Pm25Chart({super.key, required this.aqData});

  @override
  Widget build(BuildContext context) {
    return MetricsChart(
      spots: aqData.data.map((e) => FlSpot(e.time.toDouble(), e.pm25.toDouble())).toList(),
      lineColor: Color(0xFF0094FF),
      minY: aqData.pm25Range[0],
      maxY: aqData.pm25Range[1],
    );
  }
}

class MetricsChart extends StatelessWidget {
  final List<FlSpot> spots;
  final Color lineColor;

  final double? minY;
  final double? maxY;

  const MetricsChart({super.key, required this.spots, required this.lineColor, this.minY, this.maxY});

  @override
  Widget build(BuildContext context) {
    var chartData = LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 2,
          color: lineColor,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: true, color: lineColor.withValues(alpha: 0.1)),
        ),
      ],
      minY: minY,
      maxY: maxY,
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((LineBarSpot barSpot) {
              return LineTooltipItem(barSpot.y.toStringAsFixed(1), TextStyle(color: Colors.white));
            }).toList();
          },
        ),

        getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((int spotIndex) {
            return TouchedSpotIndicatorData(
              FlLine(color: Colors.blue, strokeWidth: 2, dashArray: [8, 2]),
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(radius: 6, color: lineColor);
                },
              ),
            );
          }).toList();
        },
      ),

      gridData: FlGridData(show: true),

      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,

            // minIncluded: false,
            // maxIncluded: false,
            getTitlesWidget: (value, meta) {
              // var time = aqData.getDateTime(value.toInt());
              // return SideTitleWidget(meta: meta, child: Text(Formats.formatTime(time, false)));
              return SideTitleWidget(meta: meta, child: Text(''));
            },
          ),
        ),

        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(meta: meta, child: Text(value.toStringAsFixed(0)));
            },
          ),
        ),

        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
    );

    return LineChart(chartData);
  }
}
