import 'package:nimble_neck/model/entity.dart';
import 'package:nimble_neck/model/record_value.dart';

import '../utils/number-utils.dart';

class Recording extends Entity {
  Recording({
    String? id,
    required this.datetime,
    required this.yaw,
    required this.roll,
    required this.pitch,
  }) : super(id);

  final DateTime datetime;
  final RecordValue yaw;
  final RecordValue roll;
  final RecordValue pitch;

  Recording copyWith(
      {DateTime? datetime,
      RecordValue? yaw,
      RecordValue? roll,
      RecordValue? pitch}) {
    return Recording(
      id: id,
      datetime: datetime ?? this.datetime,
      yaw: yaw ?? this.yaw,
      roll: roll ?? this.roll,
      pitch: pitch ?? this.pitch,
    );
  }

  String encode() {
    return "$id,${datetime.year}-${leadingZeroToDigit(datetime.month)}-${leadingZeroToDigit(datetime.day)} ${leadingZeroToDigit(datetime.hour)}:${leadingZeroToDigit(datetime.minute)},${roll.min},${roll.max},${pitch.min},${pitch.max},${yaw.min},${yaw.max}";
  }

  static Recording decode(String encoded) {
    final parts = encoded.split(',');
    return Recording(
      id: parts[0],
      datetime: DateTime.parse('${parts[1]}:00'),
      roll: RecordValue(min: int.parse(parts[2]), max: int.parse(parts[3])),
      pitch: RecordValue(min: int.parse(parts[4]), max: int.parse(parts[5])),
      yaw: RecordValue(min: int.parse(parts[6]), max: int.parse(parts[7])),
    );
  }
}
