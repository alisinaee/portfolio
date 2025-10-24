import '../../domain/entities/menu_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../data_sources/menu_data_source.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuDataSource _dataSource;

  MenuRepositoryImpl(this._dataSource);

  @override
  List<MenuEntity> getMenuItems() {
    return _dataSource.getMenuItems().map((model) => model.toEntity()).toList();
  }
}
