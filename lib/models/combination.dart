class Combination {
  final String element1;
  final String element2;
  final String result;

  const Combination({
    required this.element1,
    required this.element2,
    required this.result,
  });

  bool matches(String e1, String e2) {
    return (e1 == element1 && e2 == element2) || (e1 == element2 && e2 == element1);
  }
}
