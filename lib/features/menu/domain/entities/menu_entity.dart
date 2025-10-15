enum MenuState { open, close }

enum MenuItems { home, project, realms, about, contact }

class MenuEntity {
  final MenuItems id;
  final String title;
  final String text;
  final int delaySec;
  final bool reverse;
  final double flexSize;
  final String? iconPath;
  bool isOnHover;

  MenuEntity({
    required this.id,
    required this.title,
    required this.text,
    required this.flexSize,
    required this.delaySec,
    required this.reverse,
    this.iconPath,
    this.isOnHover = false,
  });

  MenuEntity copyWith({
    MenuItems? id,
    String? title,
    String? text,
    int? delaySec,
    bool? reverse,
    double? flexSize,
    String? iconPath,
    bool? isOnHover,
  }) {
    return MenuEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      delaySec: delaySec ?? this.delaySec,
      reverse: reverse ?? this.reverse,
      flexSize: flexSize ?? this.flexSize,
      iconPath: iconPath ?? this.iconPath,
      isOnHover: isOnHover ?? this.isOnHover,
    );
  }
}
