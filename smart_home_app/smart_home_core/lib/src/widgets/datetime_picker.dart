import 'package:flutter/material.dart';

import '../helpers/formats.dart';

class DateTimePicker extends StatefulWidget {
  final DateTime? value;
  final DateTime firstDate;
  final DateTime lastDate;
  final Widget label;

  final void Function(DateTime value) onUpdate;

  final TimeOfDay? defaultTime;
  final double maxWidth;

  const DateTimePicker({
    super.key,
    this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onUpdate,
    this.defaultTime,
    required this.label,
    this.maxWidth = 300,
  });

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  final tecDateTime = TextEditingController();

  @override
  void initState() {
    super.initState();
    updateText();
  }

  @override
  void didUpdateWidget(covariant DateTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateText();
  }

  void updateText() {
    tecDateTime.text = Formats.formatDateTime(widget.value, false);
  }

  void update(DateTime value) {
    widget.onUpdate(value);
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime? result = await showDatePicker(
      context: context,
      currentDate: widget.value,
      locale: Locale('hr', 'HR'),
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );

    if (result != null) {
      int defaultHour = widget.defaultTime?.hour ?? 0;
      int defaultMinute = widget.defaultTime?.minute ?? 0;

      int hour = widget.value?.hour ?? defaultHour;
      int minute = widget.value?.minute ?? defaultMinute;

      update(DateTime(result.year, result.month, result.day, hour, minute));
    }
  }

  Future<void> selectTime(BuildContext context) async {
    TimeOfDay? result = await showTimePicker(
      context: context,
      initialTime: widget.value != null ? TimeOfDay.fromDateTime(widget.value!) : TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );

    if (result != null) {
      DateTime value = widget.value ?? DateTime.now();

      int year = value.year;
      int month = value.month;
      int day = value.day;

      update(DateTime(year, month, day, result.hour, result.minute));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: tecDateTime,
              readOnly: true,
              canRequestFocus: false,
              decoration: InputDecoration(label: widget.label, isDense: true, border: OutlineInputBorder()),
            ),
          ),
          SizedBox(width: 10),
          IconButton(onPressed: () => selectDate(context), icon: const Icon(Icons.calendar_month)),
          IconButton(onPressed: () => selectTime(context), icon: const Icon(Icons.timer)),
        ],
      ),
    );

    /* return Card(
      margin: EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Text(getDateTimeText(), style: Theme.of(context).textTheme.bodyLarge),

            Spacer(),
            IconButton(onPressed: () => selectDate(context), icon: const Icon(Icons.calendar_month)),
            IconButton(onPressed: () => selectTime(context), icon: const Icon(Icons.timer)),
          ],
        ),
      ),
    );*/
  }

  @override
  void dispose() {
    tecDateTime.dispose();
    super.dispose();
  }
}
