class Status {
  static const int waiting = 0;
  static const int voting = 1; // 正在投票中，此时可以暂时放弃投票
  static const int voted = 2;
}

class Pair<F, L> {
  Pair({required this.first, required this.last});
  F first;
  L last;
}

