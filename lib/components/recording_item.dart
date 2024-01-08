import 'package:flutter/material.dart';
import 'package:nimble_neck/components/recording_values.dart';
import 'package:nimble_neck/model/recording.dart';

import '../utils/number-utils.dart';

class RecordingItem extends StatelessWidget {
  final Recording recording;
  final VoidCallback onDismissed;

  const RecordingItem(
      {super.key, required this.recording, required this.onDismissed});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(recording.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDismissed();
      },
      background: Container(
          padding: const EdgeInsets.only(right: 20.0),
          color: Colors.red,
          child: const Align(
            alignment: Alignment.centerRight,
            child: Text('Delete',
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.white)),
          )),
      child: ListTile(
        title: buildTitle(),
        subtitle: RecordingValues(
          recording: recording,
        ),
      ),
    );
  }

  Widget buildTitle() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return Text(
        '${leadingZeroToDigit(recording.datetime.hour)}:${leadingZeroToDigit(recording.datetime.minute)}, ${recording.datetime.day} ${months[recording.datetime.month - 1]}');
  }
}
