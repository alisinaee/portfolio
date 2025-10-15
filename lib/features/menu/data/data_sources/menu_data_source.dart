import '../../domain/entities/menu_entity.dart';
import '../models/menu_model.dart';
import '../../../../core/constants/app_icons.dart';

class MenuDataSource {
  List<MenuModel> getMenuItems() {
    return [
      MenuModel(
        id: MenuItems.home,
        title: 'Home Home Home ',
        text: '  Flutter is awesome  Flutter is awesome  ',
        flexSize: 10,
        reverse: false,
        delaySec: 1,
        iconPath: AppIcons.home,
      ),
      MenuModel(
        id: MenuItems.project,
        title: ' Project Project Project ',
        text: '  Ali Sinaee  Ali Sinaee  Ali Sinaee  ',
        flexSize: 30,
        reverse: true,
        delaySec: 2,
        iconPath: AppIcons.transfer,
      ),
      MenuModel(
        id: MenuItems.realms,
        title: 'Realms Realms Realms  ',
        text: '  trapped in darkness  trapped in darkness  ',
        flexSize: 15,
        reverse: false,
        delaySec: 1,
        iconPath: AppIcons.history,
      ),
      MenuModel(
        id: MenuItems.about,
        title: 'About About About ',
        text: '  Instagram Telegram Linkedin  Instagram Telegram Linkedin  ',
        flexSize: 30,
        reverse: true,
        delaySec: 2,
        iconPath: AppIcons.settings,
      ),
      MenuModel(
        id: MenuItems.contact,
        title: 'Contact Contact Contact ',
        text: '  0098 916 23 63 723  0098 916 23 63 723  ',
        flexSize: 15,
        reverse: false,
        delaySec: 3,
        iconPath: AppIcons.profile,
      ),
    ];
  }
}
