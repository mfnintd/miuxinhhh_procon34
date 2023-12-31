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

  bool isGoodToRandomMove(int i, int j) {
    if (!isPossibleToMove(i, j)) {
      return false;
    }
    int cnt = 0;
    for (int dir = 2; dir <= 8; dir += 2) {
      if (!isPossibleToBuild(i + DX[dir], j + DY[dir])) {
        return false;
      }
      if (fullBoard.walls[i][j] == ALLY_WALL) cnt++;
    }
    if (cnt == 4) {
      return false;
    }
    return true;
  }

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
    //if (matches.first == false) {
    //  tmp.fullBoard.swapMasons();
    //  // print("swap rồi nè");
    //}
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

  List<int> ownTurns = []; // các lượt mà mình chơi

  bool isOwnTurn() {
    return ownTurns.isNotEmpty && ownTurns.contains(turn);
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
    if (fullBoard.structures[x][y] == CASTLE) {
      return;
    }
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
        //if (!isPossibleToMove(x, y)) {
        //  break;
        //}
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
          for (int direction in [2, 4, 6, 8, 1, 3, 5, 7]) {
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

  int manhattanDistance(Cell a, Cell b) {
    return (a.x - b.x).abs() + (a.y - b.y).abs();
  }

  bool isPossibleToBuild(int x, int y) {
    if (!isAvailable(x, y)) {
      return false;
    }
    if (fullBoard.structures[x][y] == CASTLE || fullBoard.masons[x][y] != 0) {
      return false;
    }
    return true;
  }

  List<Action> generateAction() {
    late List<Action> res = [];
    if (isOwnTurn()) {
      ownTurns.remove(turn);
    } else {
      return res;
    }
    //fix
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
        for (int direction = 2; direction <= 8; direction += 2) {
          Cell currentNextMove = Cell(
              x: masonPosition[masonID].x + DX[direction],
              y: masonPosition[masonID].y + DY[direction]);
          if (!isAvailable(currentNextMove.x, currentNextMove.y)) {
            continue;
          }
          if (isPossibleToBuild(currentNextMove.x, currentNextMove.y) &&
              builded.contains(currentNextMove) == false &&
              isAvailable(currentNextMove.x, currentNextMove.y) &&
              fullBoard.walls[currentNextMove.x][currentNextMove.y] !=
                  ALLY_WALL) {
            if (fullBoard.walls[currentNextMove.x][currentNextMove.y] ==
                OPPONENT_WALL) {
              if (res.length < masonID) {
                res.add(
                    Action(type: DESTROY, dir: direction, succeeded: false));
              }
            } else {
              if (res.length < masonID) {
                res.add(Action(type: BUILD, dir: direction, succeeded: false));
                builded.add(currentNextMove);
              }
            }
            // random build
            //print("random build" + masonID.toString());
            break;
          }
        }
        if (res.length < masonID) {
          for (int dir in [1, 3, 5, 7, 2, 4, 6, 8]) {
            if (isGoodToRandomMove(masonPosition[masonID].x + DX[dir],
                    masonPosition[masonID].y + DY[dir]) &&
                fullBoard.masons[masonPosition[masonID].x + DX[dir]]
                        [masonPosition[masonID].y + DY[dir]] >=
                    0) {
              if (res.length < masonID) {
                res.add(Action(type: MOVE, dir: dir, succeeded: false));
                continue;
              }
            }
          }
        }
        if (res.length < masonID) {
          //stay when no move
          //print("stay when no move1" + masonID.toString());
          res.add(Action(type: STAY, dir: STAY, succeeded: false));
        }
        continue;
        //
      }
      // NOTE
      //có strategy
      Cell needToMove = Cell(x: -1000, y: -1000);

      for (int direction = 2; direction <= 8; direction += 2) {
        Cell tmpStrategy = Cell(
            x: strategyOfMason[masonID].first.x + DX[direction],
            y: strategyOfMason[masonID].first.y + DY[direction]);
        if (!isPossibleToMove(tmpStrategy.x, tmpStrategy.y)) continue;
        if (strategyOfMason[masonID].length == 1) {
          if (manhattanDistance(needToMove, masonPosition[masonID]) >
              manhattanDistance(tmpStrategy, masonPosition[masonID])) {
            needToMove = tmpStrategy;
          }
        } else {
          if (manhattanDistance(needToMove, strategyOfMason[masonID][1]) >
              manhattanDistance(tmpStrategy, strategyOfMason[masonID][1])) {
            needToMove = tmpStrategy;
          }
        }
      }

      bool hasMove = false;

      if (manhattanDistance(
              masonPosition[masonID], strategyOfMason[masonID].first) ==
          1) {
        // khi đã vừa lòng
        // print("beside strategy" + masonID.toString());
        /*
        print(masonPosition[masonID].x.toString() +
            " " +
            masonPosition[masonID].y.toString() +
            " " +
            strategyOfMason[masonID].first.x.toString() +
            " " +
            strategyOfMason[masonID].first.y.toString());
        */
        /// Đoạn này code thêm trường hợp mà nó gặp tường nữa
        if (fullBoard.walls[strategyOfMason[masonID].first.x]
                [strategyOfMason[masonID].first.y] ==
            OPPONENT_WALL) {
          if (res.length < masonID) {
            res.add(Action(
                type: DESTROY,
                dir: directionToMove[masonPosition[masonID].x]
                                [masonPosition[masonID].y]
                            [strategyOfMason[masonID].first.x]
                        [strategyOfMason[masonID].first.y]
                    .first,
                succeeded: false));
          }
        } else {
          if (res.length < masonID) {
            res.add(Action(
                type: BUILD,
                dir: directionToMove[masonPosition[masonID].x]
                                [masonPosition[masonID].y]
                            [strategyOfMason[masonID].first.x]
                        [strategyOfMason[masonID].first.y]
                    .first,

                ///Không có đường đi xuống nước
                succeeded: false));
            strategyOfMason[masonID].removeAt(0);
          }
        }
        continue;
      }
      // need to move còn bug?
      for (int nextDirection in directionToMove[masonPosition[masonID].x]
          [masonPosition[masonID].y][needToMove.x][needToMove.y]) {
        //print("mason " + masonID.toString());
        //print(nextDirection);
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
          if (nextDirection.isOdd) {
            if (directionToMove[masonPosition[masonID].x]
                        [masonPosition[masonID].y][needToMove.x][needToMove.y]
                    .contains(nextDirection + 1) ||
                directionToMove[masonPosition[masonID].x]
                        [masonPosition[masonID].y][needToMove.x][needToMove.y]
                    .contains((nextDirection + 6) % 8 + 1)) {
              continue;
            } else {
              // không có nước tối ưu vì đã bị chặn chéo
              for (var otherDirection in [
                nextDirection + 1,
                (nextDirection + 6) % 8 + 1
              ]) {
                Cell otherNextMove = Cell(
                  x: masonPosition[masonID].x + DX[otherDirection],
                  y: masonPosition[masonID].y + DY[otherDirection],
                );
                if (fullBoard.masons[otherNextMove.x][otherNextMove.y] < 0) {
                  continue;
                }
                if (fullBoard.walls[otherNextMove.x][otherNextMove.y] ==
                    OPPONENT_WALL) {
                  if (res.length < masonID) {
                    hasMove = true;
                    res.add(
                      Action(
                          type: DESTROY, dir: otherDirection, succeeded: false),
                    );
                  }
                } else {
                  if (res.length < masonID) {
                    hasMove = true;
                    res.add(
                      Action(type: MOVE, dir: otherDirection, succeeded: false),
                    );
                  }
                }
              }
            }
          } else {
            if (res.length < masonID) {
              hasMove = true;
              res.add(
                  Action(type: DESTROY, dir: nextDirection, succeeded: false));
            }
          }
          // print("destroy when has wall" + masonID.toString());
          break;
        }

        if (hasMasonMove.contains(currentNextMove)) {
          continue;
        }
        hasMove = true;
        if (res.length < masonID) {
          res.add(Action(type: MOVE, dir: nextDirection, succeeded: false));
          /* print("normal move" +
            masonID.toString() +
            " " +
            needToMove.x.toString() +
            " " +
            needToMove.y.toString());
            */
          hasMasonMove.add(currentNextMove);
        }
      }

      if (hasMove == true) {
        continue;
      }
      List<int> tmp = directionToMove[masonPosition[masonID].x]
          [masonPosition[masonID].y][needToMove.x][needToMove.y];

      if (tmp.isEmpty) {
        //
        //makeRandomBuild:
        //
        //makeRandomBuild:
        for (int direction = 2; direction <= 8; direction += 2) {
          Cell currentNextMove = Cell(
              x: masonPosition[masonID].x + DX[direction],
              y: masonPosition[masonID].y + DY[direction]);
          if (!isAvailable(currentNextMove.x, currentNextMove.y)) {
            continue;
          }
          if (isPossibleToBuild(currentNextMove.x, currentNextMove.y) &&
              builded.contains(currentNextMove) == false &&
              isAvailable(currentNextMove.x, currentNextMove.y) &&
              fullBoard.walls[currentNextMove.x][currentNextMove.y] !=
                  ALLY_WALL) {
            if (fullBoard.walls[currentNextMove.x][currentNextMove.y] ==
                OPPONENT_WALL) {
              if (res.length < masonID) {
                res.add(
                    Action(type: DESTROY, dir: direction, succeeded: false));
              }
            } else {
              if (res.length < masonID) {
                res.add(Action(type: BUILD, dir: direction, succeeded: false));
                builded.add(currentNextMove);
              }
            }
            // random build
            //print("random build" + masonID.toString());
            break;
          }
        }
        if (res.length < masonID) {
          for (int dir in [1, 3, 5, 7, 2, 4, 6, 8]) {
            if (isGoodToRandomMove(masonPosition[masonID].x + DX[dir],
                    masonPosition[masonID].y + DY[dir]) &&
                fullBoard.masons[masonPosition[masonID].x + DX[dir]]
                        [masonPosition[masonID].y + DY[dir]] >=
                    0) {
              if (res.length < masonID) {
                res.add(Action(type: MOVE, dir: dir, succeeded: false));
                continue;
              }
            }
          }
        }
        if (res.length < masonID) {
          //stay when no move
          //print("stay when no move1" + masonID.toString());
          res.add(Action(type: STAY, dir: STAY, succeeded: false));
        }
        continue;
        //
        //
      }

      if (hasMove == true) {
        continue;
      }

      if (res.length < masonID) {
        //
        //makeRandomBuild:
        //
        //makeRandomBuild:
        for (int direction = 2; direction <= 8; direction += 2) {
          Cell currentNextMove = Cell(
              x: masonPosition[masonID].x + DX[direction],
              y: masonPosition[masonID].y + DY[direction]);
          if (!isAvailable(currentNextMove.x, currentNextMove.y)) {
            continue;
          }
          if (isPossibleToBuild(currentNextMove.x, currentNextMove.y) &&
              builded.contains(currentNextMove) == false &&
              isAvailable(currentNextMove.x, currentNextMove.y) &&
              fullBoard.walls[currentNextMove.x][currentNextMove.y] !=
                  ALLY_WALL) {
            if (fullBoard.walls[currentNextMove.x][currentNextMove.y] ==
                OPPONENT_WALL) {
              if (res.length < masonID) {
                res.add(
                    Action(type: DESTROY, dir: direction, succeeded: false));
              }
            } else {
              if (res.length < masonID) {
                res.add(Action(type: BUILD, dir: direction, succeeded: false));
                builded.add(currentNextMove);
              }
            }
            // random build
            //print("random build" + masonID.toString());
            break;
          }
        }
        if (res.length < masonID) {
          for (int dir in [1, 3, 5, 7, 2, 4, 6, 8]) {
            if (isGoodToRandomMove(masonPosition[masonID].x + DX[dir],
                    masonPosition[masonID].y + DY[dir]) &&
                fullBoard.masons[masonPosition[masonID].x + DX[dir]]
                        [masonPosition[masonID].y + DY[dir]] >=
                    0) {
              if (res.length < masonID) {
                res.add(Action(type: MOVE, dir: dir, succeeded: false));
                continue;
              }
            }
          }
        }
        if (res.length < masonID) {
          //stay when no move
          //print("stay when no move1" + masonID.toString());
          res.add(Action(type: STAY, dir: STAY, succeeded: false));
        }
        continue;
        //
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
