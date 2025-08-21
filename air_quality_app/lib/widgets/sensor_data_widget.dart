import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:air_quality_app/models/sensor_data.dart';

class SensorDataWidget extends StatelessWidget {
  final SensorData sensorData;

  const SensorDataWidget(this.sensorData, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BME280', style: Theme.of(context).textTheme.titleLarge),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.temperatureHalf),
            title: Text('${sensorData.bme280Temperature.toStringAsFixed(2)} °C'),
          ),
          ListTile(leading: FaIcon(FontAwesomeIcons.droplet), title: Text('${sensorData.bme280Humidity.round()} %')),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.cloudArrowDown),
            title: Text('${sensorData.bme280Pressure.toStringAsFixed(2)} hPa'),
          ),
          SizedBox(height: 20),
          Text('SHTC3', style: Theme.of(context).textTheme.titleLarge),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.temperatureHalf),
            title: Text('${sensorData.shtc3Temperature.toStringAsFixed(2)} °C'),
          ),
          ListTile(leading: FaIcon(FontAwesomeIcons.droplet), title: Text('${sensorData.shtc3Humidity.round()} %')),
        ],
      ),
    );
  }
}
