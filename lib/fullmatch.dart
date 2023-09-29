import 'dart:collection';

import 'league.dart';
import 'match.dart';
import 'constant.dart';

class FullMatch {
  int id;
  int turns; // số lượt
  int turn; // lượt hiện tại
  int turnSeconds; // số giây một turn
  Bonus bonus;
  FullBoard fullBoard;
  String opponent;
  bool first;
  List<Log> logs;

  factory FullMatch.fromMatches(Matches matches) {
    var tmp = FullMatch(
      id: matches.id,
      turns: matches.turns,
      turn: -1,
      turnSeconds: matches.turnSeconds,
      bonus: matches.bonus,
      fullBoard: FullBoard.fromBoard((matches.board)),
      opponent: matches.opponent,
      first: matches.first,
      logs: [],
    );
    if (matches.first == false) {
      tmp.fullBoard.swapMasons();
    }
    return tmp;
  }

  void updateFromMatch(Match match) {
    id = match.id;
    turn = match.turn;
    fullBoard = match.board;
    logs = match.logs;
  }
  //--------------------------

  int currentMasonID = 1; // id hiện tại của mason đang chọn

  List<List<Cell>> strategyOfMason = [];

  Queue<int> ownTurns = Queue(); // các lượt mà mình chơi

  bool isOwnTurn() {
    return ownTurns.isNotEmpty && turn == ownTurns.first;
  }

  // Tạo một mảng 5 chiều [x0][y0][x][y][]
  // Chiều thứ 5 bao gồm các hướng có thể di chuyển từ (x0, y0) đến (x, y) trong thời gian ngắn nhất
  List<List<List<List<List<int>>>>> directionToMove = [];

  bool isAvailable(int i, int j) {
    if (0 <= i && i < fullBoard.height && 0 <= j && j < fullBoard.width) {
      return true;
    }
    return false;
  }

  bool isPossibleToMove(int i, int j) {
    if (0 <= i && i < fullBoard.height && 0 <= j && j < fullBoard.width) {
      if (fullBoard.structures[i][j] != POND) {
        return true;
      }
    }
    return false;
  }

  void changeCurrentMasonID(int id) {
    currentMasonID = id;
  }

  void addOrRemoveStrategy(int x, int y) {
    if (strategyOfMason[currentMasonID].contains(Cell(x: x, y: y))) {
      strategyOfMason[currentMasonID].remove(Cell(x: x, y: y));
    } else {
      strategyOfMason[currentMasonID].add(Cell(x: x, y: y));
      //for (var i in strategyOfMason[currentMasonID]) {
      //  print(i.x.toString() + " " + i.y.toString());
      //}
    }
    //print(isStrategy(x, y));
  }

  bool isStrategy(int x, int y) {
    return strategyOfMason[currentMasonID].contains(Cell(x: x, y: y));
  }

  bool isOtherStrategy(int x, int y) {
    for (int id = 1; id <= fullBoard.mason; id++) {
      if (id != currentMasonID &&
          strategyOfMason[id].contains(Cell(x: x, y: y))) {
        return true;
      }
    }
    return false;
  }

  List<Cell> positionOfOwnMasons() {
    List<Cell> tmp = [Cell(x: -1, y: -1)];
    for (int masonID = 1; masonID <= fullBoard.mason; masonID++) {
      for (int i = 0; i < fullBoard.height; i++) {
        for (int j = 0; j < fullBoard.width; j++) {
          if (fullBoard.masons[i][j] == masonID) {
            tmp.add(Cell(x: i, y: j));
            break;
          }
        }
        if (tmp.length == masonID + 1) {
          break;
        }
      }
    }
    return tmp;
  }

  void clearStrategy() {
    strategyOfMason[currentMasonID].clear();
  }

  int reflectionDirection(int dir) {
    return (dir + 3) % 8 + 1;
  }

  //--------------------------
  FullMatch({
    required this.id,
    required this.turns,
    required this.turn,
    required this.turnSeconds,
    required this.bonus,
    required this.fullBoard,
    required this.opponent,
    required this.first,
    required this.logs,
  }) {
    currentMasonID = 1;

    for (int i = first == true ? 0 : 1; i < turns; i += 2) {
      ownTurns.add(i);
    }

    for (int i = 0; i <= fullBoard.mason; i++) {
      strategyOfMason.add([]);
    }

    // generate direction
    int rows = fullBoard.height;
    int cols = fullBoard.width;
    directionToMove = List.generate(
      rows,
      (i) => List.generate(
        cols,
        (j) => List.generate(
          rows,
          (k) => List.generate(
            cols,
            (l) => List<int>.filled(0, 0, growable: true),
            growable: false,
          ),
          growable: false,
        ),
        growable: false,
      ),
      growable: false,
    );
    //BFS trên territories từng ô một
    for (int x = 0; x < rows; x++) {
      for (int y = 0; y < cols; y++) {
        List<List<bool>> visited = List.generate(
          rows,
          (i) => List.generate(cols, (j) => false),
          growable: false,
        );
        Queue<Cell> queue = Queue();
        queue.add(Cell(x: x, y: y));
        while (queue.isEmpty == false) {
          Cell tmp = queue.removeFirst();
          int currentRow = tmp.x;
          int currentCol = tmp.y;
          visited[currentRow][currentCol] = true;
          for (int direction = 0; direction < 9; direction++) {
            if (direction == NO_DIRECTION) {
              continue;
            }
            int dr = DX[direction];
            int dc = DY[direction];
            int nextRow = currentRow + dr;
            int nextCol = currentCol + dc;
            if (isPossibleToMove(nextRow, nextCol) == true &&
                visited[nextRow][nextCol] == false) {
              directionToMove[nextRow][nextCol][x][y]
                  .add(reflectionDirection(direction));
              visited[nextRow][nextCol] = true;
              queue.add(Cell(x: nextRow, y: nextCol));
            }
          }
        }
      }
    }
    //-----------------------
  }
  void updateMatchPerTurn(Match matchDetail) {
    turn = matchDetail.turn;
    fullBoard = matchDetail.board;
    logs = matchDetail.logs;
  }

  bool isPossibleToBuild(int x, int y) {
    if (fullBoard.structures[x][y] == CASTLE ||
        fullBoard.walls[x][y] == OPPONENT_WALL ||
        fullBoard.masons[x][y] != 0) {
      return false;
    }
    return true;
  }

  List<Action> generateAction() {
    late List<Action> res = [];
    if (isOwnTurn()) {
      ownTurns.removeFirst();
    } else {
      return res;
    }
    List<Cell> masonPosition = positionOfOwnMasons();
    List<Cell> hasMasonMove = [];
    List<Cell> builded = [];
    for (int i = 1; i <= fullBoard.mason; i++) {
      hasMasonMove.add(masonPosition[i]);
    }
    for (int masonID = 1; masonID <= fullBoard.mason; masonID++) {
      if (strategyOfMason[masonID].isEmpty) {
        //
        //makeRandomBuild:
        for (int direction = 2; direction <= 8; direction++) {
          Cell currentNextMove = Cell(
              x: masonPosition[masonID].x + DX[direction],
              y: masonPosition[masonID].y + DY[direction]);
          if (isPossibleToBuild(currentNextMove.x, currentNextMove.y) &&
              builded.contains(currentNextMove) == false &&
              isAvailable(currentNextMove.x, currentNextMove.y)) {
            res.add(Action(type: BUILD, dir: direction, succeeded: false));
            builded.add(currentNextMove);
            break;
          }
        }
        if (res.length != masonID + 1) {
          res.add(Action(type: STAY, dir: STAY, succeeded: false));
        }
        continue;
        //
      }
      List<int> tmp = directionToMove[masonPosition[masonID].x]
              [masonPosition[masonID].y][strategyOfMason[masonID].first.x]
          [strategyOfMason[masonID].first.y];

      if (tmp.isEmpty) {
        //
        //makeRandomBuild:
        for (int direction = 2; direction <= 8; direction++) {
          Cell currentNextMove = Cell(
              x: masonPosition[masonID].x + DX[direction],
              y: masonPosition[masonID].y + DY[direction]);
          if (isPossibleToBuild(currentNextMove.x, currentNextMove.y) &&
              builded.contains(currentNextMove) == false &&
              isAvailable(currentNextMove.x, currentNextMove.y)) {
            res.add(Action(type: BUILD, dir: direction, succeeded: false));
            builded.add(currentNextMove);
            break;
          }
        }
        if (res.length != masonID + 1) {
          res.add(Action(type: STAY, dir: STAY, succeeded: false));
        }
        continue;
        //
      }
      bool hasMove = false;
      for (int nextDirection in directionToMove[masonPosition[masonID].x]
              [masonPosition[masonID].y][strategyOfMason[masonID].first.x]
          [strategyOfMason[masonID].first.y]) {
        if (hasMove == true) {
          break;
        }
        Cell currentNextMove = Cell(
          x: masonPosition[masonID].x + DX[nextDirection],
          y: masonPosition[masonID].y + DY[nextDirection],
        );
        if (fullBoard.masons[currentNextMove.x][currentNextMove.y] < 0) {
          continue;
        }
        if (fullBoard.walls[currentNextMove.x][currentNextMove.y] ==
            OPPONENT_WALL) {
          hasMove == true;
          res.add(Action(type: DESTROY, dir: nextDirection, succeeded: false));
          break;
        }
        if (strategyOfMason[masonID].first == currentNextMove) {
          hasMove == true;
          res.add(Action(type: BUILD, dir: nextDirection, succeeded: false));
          strategyOfMason[masonID].removeAt(0);
          break;
        }
        if (hasMasonMove.contains(currentNextMove)) {
          continue;
        }
        hasMove = true;
        res.add(Action(type: MOVE, dir: nextDirection, succeeded: false));
        hasMasonMove.add(currentNextMove);
      }
      if (hasMove == true) {
        continue;
      }

      if (res.length < masonID) {
        //
        //makeRandomBuild:
        for (int direction = 2; direction <= 8; direction++) {
          Cell currentNextMove = Cell(
              x: masonPosition[masonID].x + DX[direction],
              y: masonPosition[masonID].y + DY[direction]);
          if (isPossibleToBuild(currentNextMove.x, currentNextMove.y) &&
              builded.contains(currentNextMove) == false &&
              isAvailable(currentNextMove.x, currentNextMove.y)) {
            res.add(Action(type: BUILD, dir: direction, succeeded: false));
            builded.add(currentNextMove);
            break;
          }
        }
        if (res.length < masonID) {
          res.add(Action(type: STAY, dir: STAY, succeeded: false));
        }
        continue;
        //
      }

      ///Nếu gặp địch
    }

    ///
    ///Nếu gặp tường địch
    ///
    ///Nếu là strategy
    ///
    ///không thì move bình thường thôiiiiiiiiiiiiiiiiiiiiiii
    return res;
  }
}

class Cell {
  int x;
  int y;
  Cell({required this.x, required this.y});
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cell && other.x == x && other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
