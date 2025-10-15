import '../entities/menu_entity.dart';

abstract class MenuRepository {
  List<MenuEntity> getMenuItems();
}
