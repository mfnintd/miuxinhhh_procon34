class League {
  List<Matches> matches;

  League({
    required this.matches,
  });

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      matches: List<Matches>.from(
          json['matches'].map((match) => Matches.fromJson(match))),
    );
  }
}

class Matches {
  int id;
  int turns;
  int turnSeconds;
  Bonus bonus;
  Board board;
  String opponent;
  bool first;

  Matches({
    required this.id,
    required this.turns,
    required this.turnSeconds,
    required this.bonus,
    required this.board,
    required this.opponent,
    required this.first,
  });

  factory Matches.fromJson(Map<String, dynamic> json) {
    return Matches(
      id: json['id'],
      turns: json['turns'],
      turnSeconds: json['turnSeconds'],
      bonus: Bonus.fromJson(json['bonus']),
      board: Board.fromJson(json['board']),
      opponent: json['opponent'],
      first: json['first'],
    );
  }
}

class Bonus {
  int wall;
  int territory;
  int castle;

  Bonus({
    required this.wall,
    required this.territory,
    required this.castle,
  });

  factory Bonus.fromJson(Map<String, dynamic> json) {
    return Bonus(
      wall: json['wall'],
      territory: json['territory'],
      castle: json['castle'],
    );
  }
}

class Board {
  int width;
  int height;
  int mason;
  List<List<int>> structures;
  List<List<int>> masons;

  Board({
    required this.width,
    required this.height,
    required this.mason,
    required this.structures,
    required this.masons,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      width: json['width'],
      height: json['height'],
      mason: json['mason'],
      structures: List<List<int>>.from(
          json['structures'].map((row) => List<int>.from(row))),
      masons: List<List<int>>.from(
          json['masons'].map((row) => List<int>.from(row))),
    );
  }
}
