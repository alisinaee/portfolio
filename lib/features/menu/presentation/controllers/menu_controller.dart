import 'package:flutter/foundation.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/repositories/menu_repository.dart';

class AppMenuController extends ChangeNotifier {
  final MenuRepository _menuRepository;

  AppMenuController(this._menuRepository) {
    _loadMenuItems();
  }

  MenuState _menuState = MenuState.close;
  MenuItems _selectedMenuItem = MenuItems.home;
  List<MenuEntity> _menuItems = [];

  // Getters
  MenuState get menuState => _menuState;
  MenuItems get selectedMenuItem => _selectedMenuItem;
  List<MenuEntity> get menuItems => _menuItems;

  void _loadMenuItems() {
    _menuItems = _menuRepository.getMenuItems();
    notifyListeners();
  }

  bool isItemSelected(MenuItems id) {
    return _selectedMenuItem == id;
  }

  void onMenuButtonTap() {
    if (_menuState == MenuState.open) {
      _menuState = MenuState.close;
    } else {
      _menuState = MenuState.open;
    }
    notifyListeners();
  }

  Future<void> onSelectItem(MenuItems id) async {
    _selectedMenuItem = id;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 2));
    _menuState = MenuState.close;
    notifyListeners();
  }

  double getTune(MenuItems id) {
    final selectedIndex = _menuItems.indexWhere((element) => element.id == _selectedMenuItem);
    final currentIndex = _menuItems.indexWhere((element) => element.id == id);
    return 1 - ((currentIndex - selectedIndex).abs() / _menuItems.length);
  }
  
  void updateMenuItemHover(MenuItems id, bool isHover) {
    final index = _menuItems.indexWhere((element) => element.id == id);
    if (index != -1) {
      _menuItems[index].isOnHover = isHover;
      notifyListeners();
    }
  }
}
