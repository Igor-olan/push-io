class PlayerModel {
  final String id;
  final double x;
  final double y;
  final bool alive;

  PlayerModel({
    required this.id,
    required this.x,
    required this.y,
    required this.alive,
  });

  factory PlayerModel.fromJson(String id, Map json) {
    return PlayerModel(
      id: id,
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      alive: json['alive'],
    );
  }
}