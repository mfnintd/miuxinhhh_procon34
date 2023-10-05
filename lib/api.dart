import 'dart:async';
import 'dart:convert';
import 'league.dart';
import 'package:http/http.dart' as http;
import 'match.dart';

class API {
  static String url = 'http://localhost:3000/matches';
  static String token = 'token1';

  static Future<void> postAction(int id, int turn, List<Action> actions) async {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['turn'] = turn;
    data['actions'] = actions.map((v) => v.toJson()).toList();
    var postResponse = await http.post(Uri.parse('$url/$id?token=$token'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(data));
    print(jsonEncode(data).toString());
    //print(postResponse.body);
  }

  static Future<League> getLeague() async {
    final response = await http.get(Uri.parse('$url?token=$token'));
    if (response.statusCode == 200) {
      //print(response.body);
      return League.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load League');
    }
  }

  static Future<Match> getMatchByID(int id) async {
    final response = await http.get(Uri.parse('$url/$id?token=$token'));
    if (response.statusCode == 200) {
      return Match.fromJson(jsonDecode(response.body));
    } else {
      if (response.statusCode == 403) {
        // trận đấu chưa bắt đầu
      }
      //throw Exception("The match hasn't started yet");
    }
    return Match(
      id: -1,
      turn: -1,
      board: FullBoard(width: 1, height: 1, mason: 0, structures: [
        [0]
      ], masons: [
        [0]
      ], walls: [
        [0]
      ], territories: [
        [0]
      ]),
      logs: [],
    );
  }
}
