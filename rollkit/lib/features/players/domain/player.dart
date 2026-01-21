import 'package:uuid/uuid.dart';

class Player {
  final String id;
  final String name;

  const Player({
    required this.id,
    required this.name,
  });

  factory Player.create({required String name}) {
    return Player(
      id: const Uuid().v4(),
      name: name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
