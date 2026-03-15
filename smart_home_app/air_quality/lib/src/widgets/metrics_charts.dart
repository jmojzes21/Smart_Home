import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smart_home_core/extensions.dart';
import 'package:smart_home_core/formats.dart';

import '../models/aq_chart_data.dart';
import '../models/aq_history.dart';

class AirQualityCharts extends StatelessWidget {
  final AqChartData aqData;
  const AirQualityCharts({super.key, required this.aqData});

  @override
  Widget build(BuildContext context) {
    var textTheme = context.textTheme;
    var titleStyle = textTheme.titleLarge;

    double imgSize = 40;

    return LayoutBuilder(
      builder: (context, constraints) {
        double spacing = 20;

        int columns = constraints.biggest.width > 750 ? 2 : 1;
        double chartWidth = (constraints.biggest.width - (columns - 1) * spacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: 20,
          children: [
            _ChartContainer(
              chartWidth: chartWidth,
              icon: getImage('assets/air_quality/temperature.png', imgSize),
              title: Text('Temperatura', style: titleStyle),
              chart: TemperatureChart(aqData: aqData),
            ),
            _ChartContainer(
              chartWidth: chartWidth,
              icon: getImage('assets/air_quality/humidity.png', imgSize),
              title: Text('Vlaga', style: titleStyle),
              chart: HumidityChart(aqData: aqData),
            ),
            _ChartContainer(
              chartWidth: chartWidth,
              icon: getImage('assets/air_quality/cloud.png', imgSize),
              title: Text('Tlak', style: titleStyle),
              chart: PressureChart(aqData: aqData),
            ),
            _ChartContainer(
              chartWidth: chartWidth,
              icon: getImage('assets/air_quality/wind.png', imgSize),
              title: Text('PM2.5', style: titleStyle),
              chart: Pm25Chart(aqData: aqData),
            ),
          ],
        );
      },
    );
  }

  Widget getImage(String name, double size) {
    return Image.asset(name, width: size, height: size, filterQuality: FilterQuality.medium);
  }
}

class _ChartContainer extends StatelessWidget {
  final double chartWidth;
  final Widget title;
  final Widget chart;
  final Widget? icon;

  const _ChartContainer({required this.chartWidth, this.icon, required this.title, required this.chart});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: chartWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(mainAxisSize: MainAxisSize.min, spacing: 10, children: [if (icon != null) icon!, title]),
          SizedBox(height: 20),
          AspectRatio(aspectRatio: 1.7, child: chart),
        ],
      ),
    );
  }
}

class TemperatureChart extends _BaseMetricsChart {
  const TemperatureChart({required super.aqData}) : super(lineColor: const Color(0xFFFF485D));

  @override
  AqMetrics getMetrics(AqHistoryChartData aq) {
    return aq.temperature;
  }

  @override
  List<double> getYRange(AqChartData data) {
    return data.temperatureRange;
  }

  @override
  List<TextSpan> getTooltipItems(AqHistoryChartData aq) {
    return [
      TextSpan(
        text: '${aq.temperature.average.toStringAsFixed(1)} °C',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ];
  }
}

class HumidityChart extends _BaseMetricsChart {
  const HumidityChart({required super.aqData}) : super(lineColor: const Color(0xFF0A64EA));

  @override
  AqMetrics getMetrics(AqHistoryChartData aq) {
    return aq.humidity;
  }

  @override
  List<double> getYRange(AqChartData data) {
    return data.humidityRange;
  }

  @override
  List<TextSpan> getTooltipItems(AqHistoryChartData aq) {
    return [
      TextSpan(
        text: '${aq.humidity.average.round()} %',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ];
  }
}

class PressureChart extends _BaseMetricsChart {
  const PressureChart({required super.aqData}) : super(lineColor: const Color(0xFFFCCA05));

  @override
  AqMetrics getMetrics(AqHistoryChartData aq) {
    return aq.pressure;
  }

  @override
  List<double> getYRange(AqChartData data) {
    return data.pressureRange;
  }

  @override
  List<TextSpan> getTooltipItems(AqHistoryChartData aq) {
    return [
      TextSpan(
        text: '${aq.pressure.average.toStringAsFixed(1)} hPa',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ];
  }
}

class Pm25Chart extends _BaseMetricsChart {
  const Pm25Chart({required super.aqData}) : super(lineColor: const Color(0xFF0094FF));

  @override
  AqMetrics getMetrics(AqHistoryChartData aq) {
    return aq.pm25;
  }

  @override
  List<double> getYRange(AqChartData data) {
    return data.pm25Range;
  }

  @override
  List<TextSpan> getTooltipItems(AqHistoryChartData aq) {
    return [
      TextSpan(
        text: '${aq.pm25.average.round()} µg/m',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      TextSpan(
        text: '3',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFeatures: [FontFeature.superscripts()]),
      ),
    ];
  }
}

abstract class _BaseMetricsChart extends StatelessWidget {
  final AqChartData aqData;
  final Color lineColor;

  const _BaseMetricsChart({required this.aqData, required this.lineColor});

  AqMetrics getMetrics(AqHistoryChartData aq);
  List<double> getYRange(AqChartData data);
  List<TextSpan> getTooltipItems(AqHistoryChartData aq);

  @override
  Widget build(BuildContext context) {
    return _MetricsChart(
      aqData: aqData,
      averageSpots: aqData.data.map((e) => FlSpot(e.x, getMetrics(e).average)).toList(),
      minSpots: aqData.data.map((e) => FlSpot(e.x, getMetrics(e).min)).toList(),
      maxSpots: aqData.data.map((e) => FlSpot(e.x, getMetrics(e).max)).toList(),
      lineColor: lineColor,
      xRange: aqData.xRange,
      yRange: getYRange(aqData),
      createTooltipItem: (barSpot) {
        var aq = aqData.data[barSpot.spotIndex];

        String timeText;
        if (aqData.tooltipShowDate) {
          timeText = Formats.formatDateTime(aq.time, false);
        } else {
          timeText = Formats.formatTime(aq.time, true);
        }

        return LineTooltipItem('$timeText\n', TextStyle(color: Colors.white), children: getTooltipItems(aq));
      },
    );
  }
}

class _MetricsChart extends StatelessWidget {
  final AqChartData aqData;
  final List<FlSpot> averageSpots;
  final List<FlSpot> minSpots;
  final List<FlSpot> maxSpots;

  final Color lineColor;
  final List<double> xRange;
  final List<double> yRange;

  final LineTooltipItem Function(LineBarSpot barSpot)? createTooltipItem;

  const _MetricsChart({
    required this.aqData,
    required this.averageSpots,
    required this.minSpots,
    required this.maxSpots,
    required this.lineColor,
    required this.xRange,
    required this.yRange,
    this.createTooltipItem,
  });

  @override
  Widget build(BuildContext context) {
    var lineColor2 = lineColor.withValues(alpha: 0.2);
    var chartData = LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: averageSpots,
          isCurved: true,
          barWidth: 3,
          color: lineColor,
          dotData: FlDotData(show: true),
        ),
        LineChartBarData(
          show: false,
          spots: minSpots,
          isCurved: true,
          barWidth: 1,
          color: lineColor2,
          dotData: FlDotData(show: false),
        ),
        LineChartBarData(
          show: false,
          spots: maxSpots,
          isCurved: true,
          barWidth: 1,
          color: lineColor2,
          dotData: FlDotData(show: false),
        ),
      ],
      betweenBarsData: [BetweenBarsData(fromIndex: 1, toIndex: 2, color: lineColor2)],

      minY: yRange[0],
      maxY: yRange[1],

      lineTouchData: LineTouchData(
        enabled: true,

        touchSpotThreshold: 40,

        touchTooltipData: LineTouchTooltipData(
          maxContentWidth: 300,
          fitInsideHorizontally: true,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((LineBarSpot barSpot) => createTooltipItem?.call(barSpot)).toList();
          },
        ),

        getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((int spotIndex) {
            return TouchedSpotIndicatorData(
              FlLine(color: lineColor, strokeWidth: 2, dashArray: [10, 10]),
              FlDotData(
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 6, color: lineColor),
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
            reservedSize: 40,
            minIncluded: false,
            maxIncluded: false,

            getTitlesWidget: (value, meta) {
              var time = aqData.getDateTimeFromX(value);
              return SideTitleWidget(
                angle: 0.8,
                meta: meta,
                fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                child: Text(Formats.formatTime(time, false), style: TextStyle(fontWeight: FontWeight.w500)),
              );
            },
          ),
        ),

        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45,
            minIncluded: false,
            maxIncluded: false,
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
