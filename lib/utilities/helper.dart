class Helper{
   static Map<T, List<S>> groupBy<S, T>(Iterable<S> values, T key(S element)) {
    var map = <T, List<S>>{};
    for (var element in values) {
      var list = map.putIfAbsent(key(element), () => []);
      list.add(element);
    }
    return map;
  }
}