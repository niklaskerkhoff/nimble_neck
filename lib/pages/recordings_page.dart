import 'package:flutter/material.dart';
import 'package:nimble_neck/components/recording_item.dart';
import 'package:nimble_neck/pages/recording_editor_page.dart';
import 'package:open_earable_flutter/src/open_earable_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/recording.dart';

class RecordingsPage extends StatefulWidget {
  const RecordingsPage({super.key});

  @override
  State<RecordingsPage> createState() => _RecordingsPageState();
}

class _RecordingsPageState extends State<RecordingsPage> {
  final _prefKey = 'recordings';
  List<Recording> _recordings = [];
  var _openEarable = OpenEarable();

  @override
  void initState() {
    super.initState();
    _openEarable = OpenEarable();
    loadRecordings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordings'),
      ),
      body: ListView.builder(
        itemCount: _recordings.length,
        itemBuilder: (context, index) {
          final recording = _recordings[index];
          return RecordingItem(
              recording: recording, onDismissed: () => _delete(recording));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RecordingEditorPage(
                        openEarable: _openEarable,
                        saveRecording: _save,
                      )))
        },
        tooltip: 'Add Record',
        child: const Icon(Icons.add),
      ),
    );
  }

  _save(Recording recording) {
    _recordings.add(recording);
    storeRecordings();
    setState(() {});
  }

  _delete(Recording recording) {
    _recordings =
        _recordings.where((element) => element.id != recording.id).toList();
    storeRecordings();
    setState(() {});
  }

  Future<void> loadRecordings() async {
    super.initState();
    final prefs = await SharedPreferences.getInstance();
    final encodedRecordings = prefs.getStringList(_prefKey);
    if (encodedRecordings == null) {
      return;
    }
    setState(() {
      _recordings = encodedRecordings
          .map((encodedRecording) => Recording.decode(encodedRecording))
          .toList();
    });
  }

  Future<void> storeRecordings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _prefKey, _recordings.map((recording) => recording.encode()).toList());
  }
}
