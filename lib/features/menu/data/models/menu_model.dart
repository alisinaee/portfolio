import '../../domain/entities/menu_entity.dart';

class MenuModel extends MenuEntity {
  MenuModel({
    required super.id,
    required super.title,
    required super.text,
    required super.flexSize,
    required super.delaySec,
    required super.reverse,
    super.iconPath,
    super.isOnHover = false,
  });

  factory MenuModel.fromEntity(MenuEntity entity) {
    return MenuModel(
      id: entity.id,
      title: entity.title,
      text: entity.text,
      flexSize: entity.flexSize,
      delaySec: entity.delaySec,
      reverse: entity.reverse,
      iconPath: entity.iconPath,
      isOnHover: entity.isOnHover,
    );
  }

  MenuEntity toEntity() {
    return MenuEntity(
      id: id,
      title: title,
      text: text,
      flexSize: flexSize,
      delaySec: delaySec,
      reverse: reverse,
      iconPath: iconPath,
      isOnHover: isOnHover,
    );
  }
}
