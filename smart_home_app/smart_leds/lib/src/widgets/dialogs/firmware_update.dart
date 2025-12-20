import 'package:file_selector/file_selector.dart' as fs;
import 'package:flutter/material.dart';
import '../../helpers/firmware_loader.dart';
import '../../logic/device/device.dart';
import '../../models/exceptions.dart';
import '../../models/misc/firmware.dart';
import '../../theme.dart';
import 'simple_dialogs.dart';

class FirmwareUpdateDialog extends StatefulWidget {
  const FirmwareUpdateDialog({super.key});
  @override
  State<FirmwareUpdateDialog> createState() => _FirmwareUpdateDialogState();

  static Future<void> show(BuildContext context) async {
    var result = await showDialog(context: context, barrierDismissible: false, builder: (context) => const FirmwareUpdateDialog());
    return result;
  }
}

class _FirmwareUpdateDialogState extends State<FirmwareUpdateDialog> {
  late Device device;

  String firmwareFile = '';
  Firmware? firmware;

  bool isPreparing = true;

  @override
  void initState() {
    super.initState();
    device = Device.currentDevice;
  }

  void openFile() async {
    var result = await fs.openFile(
      acceptedTypeGroups: [
        const fs.XTypeGroup(label: 'Datoteka programa', extensions: ['bin']),
      ],
    );

    if (result == null) return;

    String firmwarePath = result.path;
    FirmwareLoader firmwareLoader = FirmwareLoader();

    try {
      Firmware firmware = await firmwareLoader.loadFirmware(firmwarePath);

      if (!mounted) return;

      setState(() {
        firmwareFile = result.name;
        this.firmware = firmware;
      });
    } on AppException catch (e) {
      if (!mounted) return;

      setState(() {
        firmwareFile = '';
        firmware = null;
      });

      SimpleDialogs.showMessage(context: context, title: 'Greška', message: e.message);
    }
  }

  void startUpdate() async {
    setState(() {
      isPreparing = false;
    });

    try {
      await device.updateFirmware(firmware!);

      if (!mounted) return;
      Navigator.of(context).pop();

      SimpleDialogs.showMessage(context: context, title: 'Uspješno ažuriranje programa', message: 'Ugradbeni program na uređaju je uspješno ažuriran.', barrierDismissible: false);
    } on FirmwareUpdateException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();

      SimpleDialogs.showMessage(context: context, title: 'Greška kod ažuriranja programa', message: e.message, barrierDismissible: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    List<Widget>? actions;

    if (isPreparing) {
      if (firmware == null) {
        content = const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('Odaberite datoteku ugradbenog programa.', style: MyTheme.bodyMedium)],
        );
      } else {
        content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Datoteka', style: MyTheme.bodyMediumBold),
            Text(firmwareFile, style: MyTheme.bodyMedium),
            const SizedBox(height: 10),
            const Text('Veličina programa', style: MyTheme.bodyMediumBold),
            Text(calculateFirmwareSize(firmware!), style: MyTheme.bodyMedium),
            const SizedBox(height: 10),
            const Text('Verzija starog programa', style: MyTheme.bodyMediumBold),
            Text(device.firmwareVersion, style: MyTheme.bodyMedium),
            const SizedBox(height: 10),
            const Text('Verzija novog programa', style: MyTheme.bodyMediumBold),
            Text(firmware!.version, style: MyTheme.bodyMedium),
          ],
        );
      }

      actions = [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Odustani')),
        TextButton(onPressed: () => openFile(), child: const Text('Odaberi datoteku')),
        FilledButton(onPressed: firmware != null ? () => startUpdate() : null, child: const Text('Ažuriraj')),
      ];
    } else {
      content = const SizedBox(
        width: 400,
        height: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox.square(dimension: 80, child: CircularProgressIndicator()),
            SizedBox(height: 40),
            Text('Ažuriranje ugradbenog programa je u tijeku', style: MyTheme.bodyLarge),
          ],
        ),
      );
    }

    return AlertDialog(
      title: const Text('Ažuriranje programa'),
      actions: actions,
      content: ConstrainedBox(constraints: const BoxConstraints(minWidth: 600, minHeight: 300), child: content),
    );
  }

  String calculateFirmwareSize(Firmware firmware) {
    return "${(firmware.bytes.length / (1024 * 1024)).toStringAsFixed(2)} MB";
  }
}
