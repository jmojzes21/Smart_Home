import 'package:flutter/material.dart';
import 'package:shtc3_sensor_app/logic/device_controller.dart';
import 'package:shtc3_sensor_app/logic/device_discovery.dart';
import 'package:shtc3_sensor_app/logic/exceptions.dart';
import 'package:shtc3_sensor_app/pages/device_page.dart';

class DeviceDiscoveryPage extends StatefulWidget {
  const DeviceDiscoveryPage({super.key});

  @override
  State<DeviceDiscoveryPage> createState() => _DeviceDiscoveryPageState();
}

class _DeviceDiscoveryPageState extends State<DeviceDiscoveryPage> {
  late DeviceDiscovery deviceDiscovery;

  var bondedDevices = <DeviceController>[];
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    deviceDiscovery = DeviceDiscovery.getDeviceDiscovery();
    getBondedDevices();
  }

  void getBondedDevices() async {
    setState(() {
      isLoading = true;
    });

    var bondedDevices = await deviceDiscovery.getBondedDevices();
    setState(() {
      this.bondedDevices = bondedDevices;
      isLoading = false;
    });
  }

  Future<void> connectDevice(DeviceController deviceController) async {
    setState(() {
      isLoading = true;
    });

    try {
      await deviceController.connect();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => DevicePage(deviceController)));
    } on AppException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(title: Text('Povezivanje uređaja nije uspjelo'), content: Text(e.message));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var body = isLoading ? buildLoading() : buildBody(context);

    return Scaffold(
      appBar: AppBar(title: Text('Traženje uređaja')),
      floatingActionButton: FloatingActionButton(onPressed: () => getBondedDevices(), child: Icon(Icons.refresh)),
      body: body,
    );
  }

  Widget buildBody(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upareni uređaji', style: textTheme.titleMedium),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: bondedDevices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () => connectDevice(bondedDevices[index]),
                  leading: Icon(Icons.devices),
                  title: Text(bondedDevices[index].name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoading() {
    return Center(child: CircularProgressIndicator());
  }
}
