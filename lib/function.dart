import 'constant.dart';

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
