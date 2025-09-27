import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_app/logic/vm/devices_page_vm.dart';
import 'package:smart_home_core/extensions.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => DevicesPageViewModel(),
        child: Consumer<DevicesPageViewModel>(builder: (context, model, child) => buildBody(context, model)),
      ),
    );
  }

  Widget buildBody(BuildContext context, DevicesPageViewModel model) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: model.isDiscovering ? CircularProgressIndicator() : null,
              title: Text('Pretraživanje uređaja', style: context.textTheme.titleLarge),
            ),
            SizedBox(height: 20),
            ListView.builder(
              itemCount: 4,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(onTap: () {}, leading: Icon(Icons.devices), title: Text('Device $index'));
              },
            ),
            SizedBox(height: 20),
            if (!model.isDiscovering) FilledButton(onPressed: () => model.startScan(), child: Text('Pretraži uređaje')),
            if (model.isDiscovering) FilledButton(onPressed: () => model.stopScan(), child: Text('Zaustavi pretraživanje')),
          ],
        ),
      ),
    );
  }
}
