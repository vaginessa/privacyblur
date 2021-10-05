import 'package:flutter_translate/flutter_translate.dart';

import 'src/app.dart';
import 'src/di.dart';
import 'src/router.dart';

class AppContainer {
  late LocalizationDelegate? _localizationDelegate;
  late DependencyInjection _di;
  late ScreenNavigator _navigator;
  late AppRouter _router;
  late LocalizedApp _app;

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
    await _createLocalizedApp();
    return _app;
  }

  Future _createLocalizedAppConfig() async {
    if(_localizationDelegate is LocalizationDelegate) return;
    _localizationDelegate = await LocalizationDelegate.create(
        basePath: 'lib/resources/i18n/',
        fallbackLocale: 'en_US',
        supportedLocales: ['en_US', 'de']);
    return;
  }

  _createLocalizedApp() {
    if(_app is LocalizedApp) return;
    _app = LocalizedApp(_localizationDelegate!, PixelMonsterApp(_router));
  }
}
