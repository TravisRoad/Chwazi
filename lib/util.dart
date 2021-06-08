enum Status {
  waiting,
  voting, // 正在投票中，此时可以暂时放弃投票
  voted,
}

class Pair<F, L> {
  Pair({required this.first, required this.last});
  F first;
  L last;
}

enum Mode {
  group,
  select,
}
