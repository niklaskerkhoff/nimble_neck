import 'dart:async';

import 'package:flutter/material.dart';
import 'package:open_earable_flutter/src/open_earable_flutter.dart';

class DiscoveredDevicesDialog extends StatefulWidget {
  final OpenEarable openEarable;

  const DiscoveredDevicesDialog({super.key, required this.openEarable});

  @override
  State<DiscoveredDevicesDialog> createState() =>
      _DiscoveredDevicesDialogState();
}

class _DiscoveredDevicesDialogState extends State<DiscoveredDevicesDialog> {
  final String _openEarableName = "OpenEarable";
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionStateStream;
  List _discoveredDevices = [];

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _connectionStateStream?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startScanning();
    _updateOnConnectionStateChange();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Discovered Devices'),
      content: SizedBox(
          height: 300,
          width: 300,
          child: ListView.builder(
            itemCount: _discoveredDevices.length,
            itemBuilder: (context, index) {
              final device = _discoveredDevices[index];
              return ListTile(
                title: Text(device.name),
                trailing: _buildTrailingWidget(device.id, context),
                onTap: () {
                  _connectToDevice(device);
                },
              );
            },
          )),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Done'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildTrailingWidget(String id, BuildContext context) {
    if (widget.openEarable.bleManager.connectedDevice?.id == id) {
      return Icon(
          size: 24, Icons.check, color: Theme.of(context).colorScheme.primary);
    } else if (widget.openEarable.bleManager.connectingDevice?.id == id) {
      return const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2));
    }
    return const SizedBox.shrink();
  }

  void _startScanning() async {
    setState(() {
      _discoveredDevices = [];
    });

    if (widget.openEarable.bleManager.connectedDevice != null) {
      _discoveredDevices.add(widget.openEarable.bleManager.connectedDevice);
    }
    setState(() {});
    await widget.openEarable.bleManager.startScan();
    _scanSubscription?.cancel();
    _scanSubscription =
        widget.openEarable.bleManager.scanStream.listen((incomingDevice) {
      if (incomingDevice.name.isNotEmpty &&
          incomingDevice.name.contains(_openEarableName) &&
          !_discoveredDevices.any((device) => device.id == incomingDevice.id)) {
        setState(() {
          _discoveredDevices.add(incomingDevice);
        });
      }
    });
  }

  void _updateOnConnectionStateChange() async {
    _connectionStateStream =
        widget.openEarable.bleManager.connectionStateStream.listen((connected) {
      setState(() {});
    });
  }

  void _connectToDevice(device) {
    _scanSubscription?.cancel();
    widget.openEarable.bleManager.connectToDevice(device);
  }
}
