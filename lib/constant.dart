// ignore_for_file: non_constant_identifier_names

// Action
int STAY = 0;
int MOVE = 1;
int BUILD = 2;
int DESTROY = 3;

// Direction
int NO_DIRECTION = 0;
int TOP_LEFT = 1;
int TOP = 2;
int TOP_RIGHT = 3;
int RIGHT = 4;
int BOTTOM_RIGHT = 5;
int BOTTOM = 6;
int BOTTOM_LEFT = 7;
int LEFT = 8;

//wall
int NO_WALL = 0;
int ALLY_WALL = 1;
int OPPONENT_WALL = 2;

// territory
int NO_TERRITORY = 0;
int ALLY_TERRITORY = 1;
int OPPONENT_TERRITORY = 2;
int BOTH_TERRITORY = 3;

// structure
int PLAIN = 0, NO_STRUCTURE = 0;
int POND = 1;
int CASTLE = 2;

//
List<int> DX = [0, -1, -1, -1, 0, 1, 1, 1, 0];
List<int> DY = [0, -1, 0, 1, 1, 1, 0, -1, -1];
