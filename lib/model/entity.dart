import 'dart:math';

class Entity {
  final String id;

  Entity([String? id]) : id = id ?? _generateId();

  static String _generateId() {
    const length = 32;
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    final random = Random();

    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }
}
