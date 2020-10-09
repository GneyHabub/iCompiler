import 'dart:math';

String drawDepth(String node, int depth) {
  return '│ ' * (depth - 1) + '├ ' * min(depth, 1) + node + '\n';
}

String drawEmptyDepth(int depth) {
  return '│ ' * depth;
}
