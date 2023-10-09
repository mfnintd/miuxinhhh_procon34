import 'dart:async';

import 'package:flutter/material.dart';
import 'package:miuxinhhhxnp34/constant.dart';
import 'package:miuxinhhhxnp34/uimatch.dart';
import 'package:miuxinhhhxnp34/match.dart';
import 'package:miuxinhhhxnp34/league.dart';
import 'package:provider/provider.dart';
import 'api.dart';
import 'matchprovider.dart';

bool gotta = false;

final urlController = TextEditingController();
final tokenController = TextEditingController();
final idController = TextEditingController();
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
              //Provider.of<MatchProvider>(context, listen: false)
              //    .allMatches[Provider.of<MatchProvider>(context, listen: false)
              //        .currentMatchIndex]
              //    .id,
              int.parse(idController.text),
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
        // Provider.of<MatchProvider>(context, listen: false)
        //     .allMatches[Provider.of<MatchProvider>(context, listen: false)
        //         .currentMatchIndex]
        //     .id);
        int.parse(idController.text));
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
    urlController.text = API.url;
    tokenController.text = API.token;
    // print(context.watch<MatchProvider>().matchesN);
    var providerWatch = context.watch<MatchProvider>();
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              providerWatch.allMatches.isEmpty
                  ? Text("Không có dữ liệu")
                  : uiMatch(providerWatch: providerWatch, providerRead: providerRead),
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                width: 300,
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
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            providerRead.goToPrevMatch();
                            idController.text = providerWatch
                                .allMatches[providerWatch.currentMatchIndex].id
                                .toString();
                          },
                          icon: Icon(Icons.arrow_back),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Id Match: ',
                            ),
                            controller: idController,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            providerRead.goToNextMatch();
                            idController.text = providerWatch
                                .allMatches[providerWatch.currentMatchIndex].id
                                .toString();
                          },
                          icon: Icon(Icons.arrow_forward),
                        ),
                        IconButton(
                          onPressed: () {
                            providerRead
                                .goToMatchByID(int.parse(idController.text));
                            idController.text = providerWatch
                                .matchIdList[providerWatch.currentMatchIndex]
                                .toString();
                          },
                          icon: Icon(Icons.check),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            API.url = urlController.text;
                            API.token = tokenController.text;
                            await initLeague();
                            gotta = true;
                            idController.text = providerWatch
                                .allMatches[providerWatch.currentMatchIndex].id
                                .toString();
                          },
                          child: Text("Get"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            gotta = false;
                          },
                          child: Text("Stop"),
                        ),
                      ],
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
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                      onPressed: () {
                                        providerRead.changeCurrentMasonID(i);
                                      },
                                      child:
                                          Text(i == 0 ? 'View' : 'Mason ${i}')),
                                )
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
              providerWatch.allMatches.isEmpty
                  ? Text("Không có dữ liệu")
                  : Container(
                      width: 300,
                      margin: EdgeInsets.all(50),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Ally\n" + providerWatch.allyPoint().toString(),
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 32,
                                ),
                              ),
                              Text(
                                providerWatch
                                        .allMatches[
                                            providerWatch.currentMatchIndex]
                                        .opponent
                                        .toString() +
                                    "\n" +
                                    providerWatch.opponentPoint().toString(),
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 32,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}


