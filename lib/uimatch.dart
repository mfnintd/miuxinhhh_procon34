import 'package:flutter/material.dart';
import 'package:miuxinhhhxnp34/constant.dart';
import 'function.dart';
import 'matchprovider.dart';
import 'fullmatch.dart';

class UiMatch extends StatelessWidget {
  const UiMatch({
    super.key,
    required this.providerWatch,
    required this.providerRead,
  });

  final MatchProvider providerWatch;
  final MatchProvider providerRead;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: providerWatch
              .allMatches[providerWatch.currentMatchIndex].fullBoard.width *
          30,
      //color: Colors.yellow,
      child: GridView.count(
        padding: const EdgeInsets.all(0),
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        crossAxisCount: providerWatch
            .allMatches[providerWatch.currentMatchIndex].fullBoard.width,
        children: [
          for (int i = 0;
              i <
                  providerWatch.allMatches[providerWatch.currentMatchIndex]
                      .fullBoard.height;
              i++) ...[
            for (int j = 0;
                j <
                    providerWatch.allMatches[providerWatch.currentMatchIndex]
                        .fullBoard.width;
                j++)
              InkWell(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image(
                      image: AssetImage(
                        'assets/${structures2Text(providerWatch.allMatches[providerWatch.currentMatchIndex].fullBoard.structures[i][j])}${walls2Text(providerWatch.allMatches[providerWatch.currentMatchIndex].fullBoard.walls[i][j])}${masons2Text(providerWatch.allMatches[providerWatch.currentMatchIndex].fullBoard.masons[i][j])}.png',
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 30,
                      color: providerWatch
                                  .allMatches[providerWatch.currentMatchIndex]
                                  .fullBoard
                                  .masons[i][j] ==
                              providerWatch
                                  .allMatches[providerWatch.currentMatchIndex]
                                  .currentMasonID
                          ? const Color.fromARGB(88, 76, 175, 79)
                          : Colors.transparent,
                    ),
                    Stack(
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          color: providerWatch.isStrategy(i, j)
                              ? const Color.fromRGBO(255, 0, 0, 0.6)
                              : Colors.transparent,
                        ),
                        if (providerWatch.isStrategy(i, j))
                          Text(
                            providerWatch
                                .allMatches[providerWatch.currentMatchIndex]
                                .strategyOfMason[providerWatch
                                    .allMatches[providerWatch.currentMatchIndex]
                                    .currentMasonID]
                                .indexOf(Cell(x: i, y: j))
                                .toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              backgroundColor: Colors.amber[100],
                            ),
                          ),
                      ],
                    ),
                    Container(
                      height: 30,
                      width: 30,
                      color: providerWatch.isOtherStrategy(i, j)
                          ? const Color.fromRGBO(255, 0, 0, 0.2)
                          : Colors.transparent,
                    ),
                    Text(
                      masons2ID(providerWatch
                          .allMatches[providerWatch.currentMatchIndex]
                          .fullBoard
                          .masons[i][j]),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 30,
                      color: !providerWatch.viewTeritory
                          ? Colors.transparent
                          : providerWatch
                                      .allMatches[
                                          providerWatch.currentMatchIndex]
                                      .fullBoard
                                      .territories[i][j] ==
                                  ALLY_TERRITORY
                              ? Colors.green
                              : providerWatch
                                          .allMatches[
                                              providerWatch.currentMatchIndex]
                                          .fullBoard
                                          .territories[i][j] ==
                                      OPPONENT_TERRITORY
                                  ? Colors.red
                                  : providerWatch
                                              .allMatches[providerWatch
                                                  .currentMatchIndex]
                                              .fullBoard
                                              .territories[i][j] ==
                                          BOTH_TERRITORY
                                      ? Colors.brown
                                      : Colors.transparent,
                    ),
                  ],
                ),
                onTap: () {
                  providerRead.addOrRemoveStrategy(i, j);
                },
                onLongPress: () {
                  providerRead.changeCurrentMasonID(providerWatch
                      .allMatches[providerWatch.currentMatchIndex]
                      .fullBoard
                      .masons[i][j]);
                },
              )
          ]
        ],
      ),
    );
  }
}
