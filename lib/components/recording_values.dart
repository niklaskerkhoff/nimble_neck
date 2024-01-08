import 'package:flutter/material.dart';

import '../model/recording.dart';

class RecordingValues extends StatelessWidget {
  final Recording recording;

  const RecordingValues({super.key, required this.recording});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Roll:   (min: ${recording.roll.min.toInt()}°, max: ${recording.roll.max.toInt()}°)'),
        Text(
            'Pitch: (min: ${recording.pitch.min.toInt()}°, max: ${recording.pitch.max.toInt()}°)'),
        Text(
            'Yaw:   (min: ${recording.yaw.min.toInt()}°, max: ${recording.yaw.max.toInt()}°)'),
      ],
    );
  }
}
