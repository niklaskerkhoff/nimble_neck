import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:nimble_neck/components/discovered_devices_dialog.dart';
import 'package:nimble_neck/components/recording_values.dart';
import 'package:nimble_neck/model/record_value.dart';
import 'package:open_earable_flutter/src/open_earable_flutter.dart';

import '../model/recording.dart';

class RecordingEditorPage extends StatefulWidget {
  final Recording? recording;
  final void Function(Recording) saveRecording;
  final OpenEarable openEarable;

  const RecordingEditorPage(
      {super.key,
      this.recording,
      required this.saveRecording,
      required this.openEarable});

  @override
  State<RecordingEditorPage> createState() => _RecordingEditorPageState();
}

class _RecordingEditorPageState extends State<RecordingEditorPage> {
  var controller = Flutter3DController();

  StreamSubscription? _sensorSubscription;

  var _isRecording = false;

  double _rollDegree = 0;
  double _pitchDegree = 0;
  double _yawDegree = 0;

  double _startRollDegree = 0;
  double _startPitchDegree = 0;
  double _startYawDegree = 0;

  double _minRollDegree = 0;
  double _minPitchDegree = 0;
  double _minYawDegree = 0;

  double _maxRollDegree = 0;
  double _maxPitchDegree = 0;
  double _maxYawDegree = 0;

  final List<String> logs = [];

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _setSensorListener();

    Future.delayed(Duration.zero, () => _openDiscoveredDevicesDialog());
  }

  @override
  Widget build(BuildContext context) {
    final recording = widget.recording;
    bool isConnected = widget.openEarable.bleManager.connected;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('${recording == null ? 'New' : 'Update'} Recording'),
        actions: [
          Visibility(
              visible: _isRecording,
              child: IconButton(
                color: Theme.of(context).colorScheme.error,
                onPressed: _reset,
                icon: const Icon(Icons.stop_circle),
              )),
          IconButton(
              onPressed: () {
                _openDiscoveredDevicesDialog();
              },
              icon: Icon(isConnected
                  ? Icons.bluetooth_connected_sharp
                  : Icons.bluetooth))
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Visibility(
                  visible: isConnected,
                  child: Column(
                    children: [
                      Text(
                          _isRecording
                              ? 'Move your head in every direction!\nThen click Save!'
                              : 'Stand up straight, looking forward!\nThen click Start!',
                          textAlign: TextAlign.center),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 32, 0, 32),
                        child: Transform(
                          alignment: Alignment.center,
                          transform:
                              Matrix4.rotationZ(math.pi * _rollDegree / 180),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width,
                            child: Flutter3DViewer(
                              controller: controller,
                              src: 'assets/head.glb',
                              //src: 'assets/sheen_chair.glb',
                            ),
                          ),
                        ),
                      ),
                      RecordingValues(recording: _createRecording()),
                    ],
                  ))
            ],
          )),
      floatingActionButton: _isRecording
          ? FloatingActionButton.extended(
              onPressed: _save,
              label: const Text('Save'),
              icon: const Icon(Icons.save))
          : FloatingActionButton.extended(
              onPressed: _startRecording,
              label: const Text('Start'),
              icon: const Icon(Icons.play_circle)),
    );
  }

  _openDiscoveredDevicesDialog() async {
    await showDialog(
        context: context,
        builder: (context) =>
            DiscoveredDevicesDialog(openEarable: widget.openEarable));
    _setSensorListener();
  }

  void _setSensorListener() {
    if (widget.openEarable.bleManager.connected) {
      final config =
          OpenEarableSensorConfig(sensorId: 0, samplingRate: 30, latency: 0);
      widget.openEarable.sensorManager.writeSensorConfig(config);

      double yawDegreeCorrection = 0;
      double prevYawDegree = _yawDegree;

      _sensorSubscription?.cancel();
      _sensorSubscription = widget.openEarable.sensorManager
          .subscribeToSensorData(0)
          .listen((data) {
        final roll = data['EULER']['ROLL'];
        final pitch = data['EULER']['PITCH'];
        final yaw = data['EULER']['YAW'];

        _rollDegree = _radToDegree(roll) - _startRollDegree;
        _pitchDegree = _radToDegree(pitch) - _startPitchDegree;
        final sensorYawDegree =
            _radToDegree(yaw) - _startYawDegree - yawDegreeCorrection;

        if ((sensorYawDegree - prevYawDegree).abs() > 0.1) {
          _yawDegree = sensorYawDegree;
        }

        prevYawDegree = sensorYawDegree;

        setState(() {});
        _setCamera();

        if (_isRecording) {
          _minRollDegree = math.min(_rollDegree, _minRollDegree);
          _minPitchDegree = math.min(_pitchDegree, _minPitchDegree);
          _minYawDegree = math.min(_yawDegree, _minYawDegree);

          _maxRollDegree = math.max(_rollDegree, _maxRollDegree);
          _maxPitchDegree = math.max(_pitchDegree, _maxPitchDegree);
          _maxYawDegree = math.max(_yawDegree, _maxYawDegree);
        }
      });
    }
  }

  void _startRecording() {
    _isRecording = true;
    _startRollDegree = _rollDegree;
    _startPitchDegree = _pitchDegree;
    _startYawDegree = _yawDegree;
  }

  void _reset() {
    _isRecording = false;
    _startRollDegree = 0;
    _startPitchDegree = 0;
    _startYawDegree = 0;

    _minRollDegree = 0;
    _minPitchDegree = 0;
    _minYawDegree = 0;

    _maxRollDegree = 0;
    _maxPitchDegree = 0;
    _maxYawDegree = 0;
  }

  double _radToDegree(double value) => value * 180 / math.pi;

  _save() {
    final recording = _createRecording();
    widget.saveRecording(recording);
    Navigator.of(context).pop();
  }

  _setCamera() {
    controller.setCameraOrbit(-_yawDegree, -_pitchDegree + 90, 500);
  }

  Recording _createRecording() => Recording(
      datetime: DateTime.now(),
      roll:
          RecordValue(min: _minRollDegree.toInt(), max: _maxRollDegree.toInt()),
      pitch: RecordValue(
          min: _minPitchDegree.toInt(), max: _maxPitchDegree.toInt()),
      yaw: RecordValue(min: _minYawDegree.toInt(), max: _maxYawDegree.toInt()));
}
