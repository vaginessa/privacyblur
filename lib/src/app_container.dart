import 'package:flutter_translate/flutter_translate.dart';

import 'app.dart';
import 'di.dart';
import 'router.dart';

class AppContainer {
  LocalizationDelegate? _localizationDelegate;
  LocalizedApp? _app;

  late DependencyInjection _di;
  late ScreenNavigator _navigator;
  late AppRouter _router;

  static final AppContainer _singleton = AppContainer._internal();

  factory AppContainer() {
    return _singleton;
  }

  AppContainer._internal() {
    _di = DependencyInjection();
    _navigator = ScreenNavigator();
    _router = AppRouter.fromMainScreen(_navigator, _di);
  }

  Future<LocalizedApp> get app async {
    await _createLocalizedAppConfig();
    _createLocalizedApp();
    return _app!;
  }

  Future _createLocalizedAppConfig() async {
    if (_localizationDelegate != null) return;
    _localizationDelegate = await LocalizationDelegate.create(
        basePath: 'lib/resources/i18n/',
        fallbackLocale: 'en_US',
        supportedLocales: ['en_US', 'de']);
    return;
  }

  _createLocalizedApp() {
    if (_app != null) return;
    _app = LocalizedApp(_localizationDelegate!, PixelMonsterApp(_router));
  }
}
