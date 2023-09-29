import 'package:flutter/foundation.dart';
import 'package:miuxinhhhxnp34/league.dart';

import 'fullmatch.dart';
import 'match.dart';

class MatchProvider with ChangeNotifier, DiagnosticableTreeMixin {
  int currentMatchIndex = 0;
  int matchesN = 0;
  List<FullMatch> allMatches = [];

  void initAllMatches(League league) {
    int matchesN = league.matches.length;
    allMatches = List.generate(
        matchesN, (index) => FullMatch.fromMatches(league.matches[index]));
    currentMatchIndex = 0;
    notifyListeners();
  }

  void goToNextMatch() {
    currentMatchIndex++;
    if (currentMatchIndex == matchesN) {
      currentMatchIndex = 0;
    }
    notifyListeners();
  }

  void goToPrevMatch() {
    currentMatchIndex--;
    if (currentMatchIndex < 0) {
      currentMatchIndex = matchesN - 1;
    }
    notifyListeners();
  }

  void changeCurrentMasonID(int id) {
    if (id < 0) {
      id = 0;
    }
    allMatches[currentMatchIndex].changeCurrentMasonID(id);
    notifyListeners();
  }

  void addOrRemoveStrategy(int x, int y) {
    allMatches[currentMatchIndex].addOrRemoveStrategy(x, y);
    //print(x.toString() + " " + y.toString());
    notifyListeners();
  }

  bool isStrategy(int x, int y) {
    return allMatches[currentMatchIndex].isStrategy(x, y);
  }

  bool isOtherStrategy(int x, int y) {
    return allMatches[currentMatchIndex].isOtherStrategy(x, y);
  }

  void updateMatchPerTurn(Match matchDetail) {
    allMatches[currentMatchIndex].updateMatchPerTurn(matchDetail);
    notifyListeners();
  }
}
