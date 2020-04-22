import 'dart:collection';

class LruList<T> {
  final int maxLength;
  Queue<T> _list = new Queue();

  LruList({this.maxLength});

  bool contains(T element) {
    return _list.contains(element);
  }

  void add(T element) {
    if (_list.length >= maxLength - 1) {
      _list.removeFirst();
    }
    _list.addLast(element);
  }

  int length() {
    return _list.length;
  }
}
