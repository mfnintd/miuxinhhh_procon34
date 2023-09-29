import 'dart:async';

import 'package:flutter/material.dart';
import 'package:miuxinhhhxnp34/constant.dart';
import 'package:miuxinhhhxnp34/match.dart';
import 'package:miuxinhhhxnp34/league.dart';
import 'package:provider/provider.dart';
import 'api.dart';
import 'matchprovider.dart';

bool gotta = false;

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MatchProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late League currentLeague;
  late Match currentMatch;
  @override
  void initState() {
    super.initState();
    // initLeague();
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (gotta) {
        updateCurrentMatch(); // Gọi phương thức cập nhật dữ liệu sau mỗi 5 giây
        if (Provider.of<MatchProvider>(context, listen: false)
            .allMatches[Provider.of<MatchProvider>(context, listen: false)
                .currentMatchIndex]
            .isOwnTurn()) {
          var actions = Provider.of<MatchProvider>(context, listen: false)
              .allMatches[Provider.of<MatchProvider>(context, listen: false)
                  .currentMatchIndex]
              .generateAction();
          postAction(
              Provider.of<MatchProvider>(context, listen: false)
                  .allMatches[Provider.of<MatchProvider>(context, listen: false)
                      .currentMatchIndex]
                  .id,
              Provider.of<MatchProvider>(context, listen: false)
                      .allMatches[
                          Provider.of<MatchProvider>(context, listen: false)
                              .currentMatchIndex]
                      .turn +
                  1,
              actions);
        }
      }
    });
  }

  void updateCurrentMatch() async {
    if (Provider.of<MatchProvider>(context, listen: false).allMatches.isEmpty) {
      return;
    }
    currentMatch = await getMatchByID(
        Provider.of<MatchProvider>(context, listen: false)
            .allMatches[Provider.of<MatchProvider>(context, listen: false)
                .currentMatchIndex]
            .id);
    if (currentMatch.id == -1) {
      return;
    }
    context.read<MatchProvider>().updateMatchPerTurn(currentMatch);
  }

  Future<void> initLeague() async {
    currentLeague = await getLeague();
    context.read<MatchProvider>().initAllMatches(currentLeague);
  }

  @override
  Widget build(BuildContext context) {
    var providerRead = context.read<MatchProvider>();
    // print(context.watch<MatchProvider>().matchesN);
    var providerWatch = context.watch<MatchProvider>();
    return MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            providerWatch.allMatches.isEmpty
                ? Text("Không có dữ liệu")
                : Container(
                    width: providerWatch
                            .allMatches[providerWatch.currentMatchIndex]
                            .fullBoard
                            .width *
                        30,
                    color: Colors.yellow,
                    child: GridView.count(
                      padding: const EdgeInsets.all(0),
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      crossAxisCount: providerWatch
                          .allMatches[providerWatch.currentMatchIndex]
                          .fullBoard
                          .width,
                      children: [
                        for (int i = 0;
                            i <
                                providerWatch
                                    .allMatches[providerWatch.currentMatchIndex]
                                    .fullBoard
                                    .height;
                            i++)
                          for (int j = 0;
                              j <
                                  providerWatch
                                      .allMatches[
                                          providerWatch.currentMatchIndex]
                                      .fullBoard
                                      .width;
                              j++)
                            InkWell(
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Image(
                                    image: AssetImage(
                                        'assets/${structures2Text(providerWatch.allMatches[providerWatch.currentMatchIndex].fullBoard.structures[i][j])}${walls2Text(providerWatch.allMatches[providerWatch.currentMatchIndex].fullBoard.walls[i][j])}${masons2Text(providerWatch.allMatches[providerWatch.currentMatchIndex].fullBoard.masons[i][j])}.png'),
                                  ),
                                  Container(
                                    height: 30,
                                    width: 30,
                                    color: providerWatch
                                                .allMatches[providerWatch
                                                    .currentMatchIndex]
                                                .fullBoard
                                                .masons[i][j] ==
                                            providerWatch
                                                .allMatches[providerWatch
                                                    .currentMatchIndex]
                                                .currentMasonID
                                        ? Color.fromARGB(88, 76, 175, 79)
                                        : Colors.transparent,
                                  ),
                                  Container(
                                    height: 30,
                                    width: 30,
                                    color: providerRead.isStrategy(i, j)
                                        ? Color.fromRGBO(255, 0, 0, 0.6)
                                        : Colors.transparent,
                                  ),
                                  Container(
                                    height: 30,
                                    width: 30,
                                    color: providerRead.isOtherStrategy(i, j)
                                        ? Color.fromRGBO(255, 0, 0, 0.2)
                                        : Colors.transparent,
                                  ),
                                  Text(
                                    masons2ID(providerWatch
                                        .allMatches[
                                            providerWatch.currentMatchIndex]
                                        .fullBoard
                                        .masons[i][j]),
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                      ],
                    ),
                  ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    initLeague();
                    gotta = true;
                  },
                  child: Text("Get"),
                ),
                providerWatch.allMatches.isEmpty
                    ? Text("Không có dữ liệu")
                    : Column(
                        children: [
                          Text(
                            'Turn ${providerWatch.allMatches[providerWatch.currentMatchIndex].turn}/${providerWatch.allMatches[providerWatch.currentMatchIndex].turns}',
                          ),
                          for (int i = 0;
                              i <=
                                  providerWatch
                                      .allMatches[
                                          providerWatch.currentMatchIndex]
                                      .fullBoard
                                      .mason;
                              i++)
                            ElevatedButton(
                                onPressed: () {
                                  providerRead.changeCurrentMasonID(i);
                                },
                                child: Text(i == 0 ? 'View' : 'Mason ${i}'))
                        ],
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String structures2Text(int structure) {
  if (structure == PLAIN) {
    return 'plain';
  } else {
    if (structure == POND) {
      return 'pond';
    } else {
      return 'castle';
    }
  }
}

String walls2Text(int wall) {
  if (wall == NO_WALL) {
    return 'no';
  } else {
    if (wall == ALLY_WALL) {
      return 'ally';
    } else {
      return 'opponent';
    }
  }
}

String masons2Text(int mason) {
  if (mason == 0) {
    return 'no';
  } else {
    if (mason > 0) {
      return 'ally';
    } else {
      return 'opponent';
    }
  }
}

String masons2ID(int mason) {
  if (mason <= 0)
    return '';
  else
    return mason.toString();
}
