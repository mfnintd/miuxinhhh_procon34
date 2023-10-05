import 'dart:async';

import 'package:flutter/material.dart';
import 'package:miuxinhhhxnp34/constant.dart';
import 'package:miuxinhhhxnp34/fullmatch.dart';
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
    Timer.periodic(Duration(milliseconds: 1000), (timer) {
      if (gotta) {
        updateCurrentMatch(); // Gọi phương thức cập nhật dữ liệu sau mỗi 5 giây
        if (Provider.of<MatchProvider>(context, listen: false)
            .allMatches[Provider.of<MatchProvider>(context, listen: false)
                .currentMatchIndex]
            .isOwnTurn()) {
          //print("turn cua minh day");
          var actions = Provider.of<MatchProvider>(context, listen: false)
              .allMatches[Provider.of<MatchProvider>(context, listen: false)
                  .currentMatchIndex]
              .generateAction();
          API.postAction(
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
    currentMatch = await API.getMatchByID(
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
    currentLeague = await API.getLeague();
    context.read<MatchProvider>().initAllMatches(currentLeague);
  }

  @override
  Widget build(BuildContext context) {
    var providerRead = context.read<MatchProvider>();
    final urlController = TextEditingController();
    final tokenController = TextEditingController();
    urlController.text = API.url;
    tokenController.text = API.token;
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
                                  Stack(children: [
                                    Container(
                                      height: 30,
                                      width: 30,
                                      color: providerWatch.isStrategy(i, j)
                                          ? Color.fromRGBO(255, 0, 0, 0.6)
                                          : Colors.transparent,
                                    ),
                                    if (providerWatch.isStrategy(i, j))
                                      Text(
                                        providerWatch
                                            .allMatches[
                                                providerWatch.currentMatchIndex]
                                            .strategyOfMason[providerWatch
                                                .allMatches[providerWatch
                                                    .currentMatchIndex]
                                                .currentMasonID]
                                            .indexOf(Cell(x: i, y: j))
                                            .toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          backgroundColor: Colors.amber[100],
                                        ),
                                      ),
                                  ]),
                                  Container(
                                    height: 30,
                                    width: 30,
                                    color: providerWatch.isOtherStrategy(i, j)
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
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      backgroundColor: Colors.white,
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
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              width: 200,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Url: ',
                    ),
                    controller: urlController,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Token: ',
                    ),
                    controller: tokenController,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      initLeague();
                      gotta = true;
                      API.url = urlController.text;
                      API.token = tokenController.text;
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
                  ElevatedButton(
                    onPressed: () {
                      providerRead.allMatches[providerWatch.currentMatchIndex]
                          .clearStrategy();
                    },
                    child: Text('Clear'),
                  ),
                ],
              ),
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
