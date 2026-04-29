import 'emoji_element.dart';

class PlacedElement {
  final String id; // Unique id for the instance on the canvas
  final EmojiElement element;
  double x;
  double y;

  PlacedElement({
    required this.id,
    required this.element,
    required this.x,
    required this.y,
  });

  PlacedElement copyWith({
    String? id,
    EmojiElement? element,
    double? x,
    double? y,
  }) {
    return PlacedElement(
      id: id ?? this.id,
      element: element ?? this.element,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}
