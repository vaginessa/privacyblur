import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'src/app_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("main");
  runApp(await AppContainer().app);
}
