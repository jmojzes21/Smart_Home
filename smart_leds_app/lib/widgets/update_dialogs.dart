import 'package:file_selector/file_selector.dart' as fs;
import 'package:flutter/material.dart';
import 'package:smart_leds_app/helpers/firmware_loader.dart';
import 'package:smart_leds_app/models/device.dart';
import 'package:smart_leds_app/models/exceptions.dart';
import 'package:smart_leds_app/models/firmware.dart';
import 'package:smart_leds_app/widgets/message_dialogs.dart';

const _dialogSize = Size(600, 200);

class PrepareUpdateWidget extends StatefulWidget {
  const PrepareUpdateWidget({super.key});
  @override
  State<PrepareUpdateWidget> createState() => _PrepareUpdateWidgetState();
}

class _PrepareUpdateWidgetState extends State<PrepareUpdateWidget> {
  String firmwareFile = '';
  Firmware? firmware;

  void openFile() async {
    var result = await fs.openFile(acceptedTypeGroups: [
      fs.XTypeGroup(
        label: 'Datoteka programa',
        extensions: const ['bin'],
      )
    ]);

    if (result == null) return;

    String path = result.path;
    FirmwareLoader firmwareLoader = FirmwareLoader();

    try {
      Firmware firmware = await firmwareLoader.loadFirmware(path);
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
      showMessageDialog(context, 'Greška', e.message);
    }
  }

  void startUpdate() async {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => FirmwareUpdatingWidget(
        firmware: firmware!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var body = <Widget>[];

    if (firmware == null) {
      body = [
        Text('Odaberite datoteku programa'),
      ];
    } else {
      var theme = Theme.of(context).textTheme;
      var titleStyle = theme.titleMedium;
      var bodyStyle = theme.bodyMedium;
      const spacing = 5.0;

      body = [
        Text('Datoteka', style: titleStyle),
        Text(firmwareFile, style: bodyStyle),
        SizedBox(height: spacing),
        Text('Veličina programa', style: titleStyle),
        Text(
          '${(firmware!.bytes.length / 1024 / 1024).toStringAsFixed(1)} MB',
          style: bodyStyle,
        ),
        SizedBox(height: spacing),
        Text('Verzija novog programa', style: titleStyle),
        Text(firmware!.version, style: bodyStyle),
        SizedBox(height: spacing),
      ];
    }

    return AlertDialog(
      title: Text('Ažuriraj program'),
      content: SizedBox.fromSize(
        size: _dialogSize,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: body,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => openFile(),
          child: Text('Odaberi datoteku'),
        ),
        TextButton(
          onPressed: firmware != null ? () => startUpdate() : null,
          child: Text('Ažuriraj'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Odustani'),
        ),
      ],
    );
  }
}

class FirmwareUpdatingWidget extends StatefulWidget {
  final Firmware firmware;

  const FirmwareUpdatingWidget({
    super.key,
    required this.firmware,
  });

  @override
  State<FirmwareUpdatingWidget> createState() => _FirmwareUpdatingWidgetState();
}

class _FirmwareUpdatingWidgetState extends State<FirmwareUpdatingWidget> {
  @override
  void initState() {
    super.initState();
    startUpdate(widget.firmware);
  }

  void startUpdate(Firmware firmware) async {
    try {
      await Device.currentDevice.updateFirmware(firmware);

      if (!mounted) return;
      Navigator.of(context).pop();
      showMessageDialog(context, 'Ažuriranje programa',
          'Program na uređaju je uspješno ažuriran.');
    } on FirmwareUpdateException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      showMessageDialog(context, 'Ažuriranje programa nije uspjelo', e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ažuriranje programa'),
      content: SizedBox.fromSize(
        size: _dialogSize,
        child: Center(
          child: SizedBox.square(
            dimension: 80,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
