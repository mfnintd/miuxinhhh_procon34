import 'package:miuxinhhhxnp34/constant.dart';
import 'package:miuxinhhhxnp34/league.dart';

class FullBoard {
  int width;
  int height;
  int mason;
  List<List<int>> structures;
  List<List<int>> masons;
  List<List<int>> walls;
  List<List<int>> territories;

  FullBoard({
    required this.width,
    required this.height,
    required this.mason,
    required this.structures,
    required this.masons,
    required this.walls,
    required this.territories,
  });

  factory FullBoard.fromJson(Map<String, dynamic> json) {
    return FullBoard(
      width: json['board']['width'],
      height: json['board']['height'],
      mason: json['board']['mason'],
      structures: List<List<int>>.from(
          json['board']['structures'].map((x) => List<int>.from(x))),
      masons: List<List<int>>.from(
          json['board']['masons'].map((x) => List<int>.from(x))),
      walls: List<List<int>>.from(
          json['board']['walls'].map((x) => List<int>.from(x))),
      territories: List<List<int>>.from(
          json['board']['territories'].map((x) => List<int>.from(x))),
    );
  }

  factory FullBoard.fromBoard(Board board) {
    return FullBoard(
        width: board.width,
        height: board.height,
        mason: board.mason,
        structures: board.structures,
        masons: board.masons,
        walls: List.generate(
          board.height,
          (i) => List.generate(board.width, (j) => NO_WALL),
          growable: false,
        ),
        territories: List.generate(
          board.height,
          (i) => List.generate(board.width, (j) => NO_TERRITORY),
          growable: false,
        ));
  }
  void swapMasons() {
    print(masons);
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        masons[i][j] = -masons[i][j];
      }
    }
    print(masons);
  }

  List<int> numberOfTeritoty() {
    int allyWall,
        allyTeritory,
        allyCastle,
        opponentWall,
        opponentTeritory,
        opponentCastle;
    allyWall = allyTeritory =
        opponentWall = opponentTeritory = allyCastle = opponentCastle = 0;
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (walls[i][j] == ALLY_WALL) {
          allyWall++;
        }
        if (walls[i][j] == OPPONENT_WALL) {
          opponentWall++;
        }
        if (territories[i][j] == ALLY_TERRITORY) {
          if (structures[i][j] == CASTLE) {
            allyCastle++;
          } else {
            allyTeritory++;
          }
        }
        if (territories[i][j] == OPPONENT_TERRITORY) {
          if (structures[i][j] == CASTLE) {
            opponentCastle++;
          } else {
            opponentTeritory++;
          }
        }
      }
    }
    return [
      allyWall,
      allyTeritory,
      allyCastle,
      opponentWall,
      opponentTeritory,
      opponentCastle
    ];
  }
}

class Action {
  int type;
  int dir;
  bool succeeded;

  Action({
    required this.type,
    required this.dir,
    required this.succeeded,
  });

  factory Action.fromJson(Map<String, dynamic> json) {
    return Action(
      type: json['type'],
      dir: json['dir'],
      succeeded: json['succeeded'],
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['dir'] = dir;
    return data;
  }
}

class Log {
  int turn;
  List<Action> actions;

  Log({
    required this.turn,
    required this.actions,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      turn: json['turn'],
      actions:
          List<Action>.from(json['actions'].map((x) => Action.fromJson(x))),
    );
  }
}

class Match {
  int id;
  int turn;
  FullBoard board;
  List<Log> logs;

  Match({
    required this.id,
    required this.turn,
    required this.board,
    required this.logs,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      turn: json['turn'],
      board: FullBoard.fromJson(json),
      logs: List<Log>.from(json['logs'].map((x) => Log.fromJson(x))),
    );
  }
}
