import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyblur/src/app.dart';
import 'package:privacyblur/src/di.dart';
import 'package:privacyblur/src/router.dart';
/*
import 'package:privacyblur/src/screens/home/helpers/home_events.dart';
import 'package:privacyblur/src/screens/home/helpers/home_states.dart';
import 'package:privacyblur/src/screens/home/home_bloc.dart';
import 'package:privacyblur/src/screens/home/home_repo.dart';

class MockDependencyInjection extends Mock implements DependencyInjection {}

class MockScreenBloc extends Mock implements HomeBloc {}

class MockScreenNavigator extends Mock implements ScreenNavigator {}

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  const String appName = 'PrivacyBlur';
  var di = MockDependencyInjection();
  var navigator = MockScreenNavigator();
  var bloc = MockScreenBloc();
  var repo = MockHomeRepository();

  testWidgets('Full HomeScreen test with mock bloc and UI for initial Load',
      (WidgetTester tester) async {
    when(di.getRepositoryProviders()).thenAnswer((realInvocation) =>
        [RepositoryProvider<HomeRepository>(create: (context) => repo)]);
    when(di.getHomeBloc()).thenAnswer(
        (realInvocation) => BlocProvider<HomeBloc>(create: (context) => bloc));
    when(bloc.state).thenAnswer((realInvocation) => HomeInitialized(
        filterShapeIndex: 0,
        filterPower: 50,
        filterSize: 30,
        sourceImagePath: null,
        displayImage: null));

    await tester.pumpWidget(
        PixelMonsterApp(AppRouter.fromHomeScreen(navigator, di), appName));
    await tester.pumpAndSettle();

    // App title render
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('PrivacyBlur'), findsOneWidget);

    // check if placeholder is rendered
    expect(find.text('No Image selected'), findsOneWidget);
  });

  blocTest(
    'emits [HomeLoading, HomeInitialized] on load',
    build: () => HomeBloc(repo),
    act: (bloc) => bloc.add(HomeInitialize()),
    expect: [
      isA<HomeLoading>(),
      isA<HomeInitialized>(),
    ],
  );

  blocTest(
    'emits [HomeEditing] on filter size set',
    build: () => HomeBloc(repo),
    act: (bloc) => bloc.add(HomeFilterSizeSet(20)),
    expect: [
      isA<HomeEditing>(),
    ],
  );

  blocTest(
    'emits [HomeLoadError] on wrong filter size set',
    build: () => HomeBloc(repo),
    act: (bloc) => bloc.add(HomeFilterSizeSet(null)),
    expect: [
      isA<HomeLoadError>(),
    ],
  );

  blocTest(
    'emits [HomeEditing] on pixelate size set',
    build: () => HomeBloc(repo),
    act: (bloc) => bloc.add(HomePixelateSizeSet(20)),
    expect: [
      isA<HomeEditing>(),
    ],
  );

  blocTest(
    'emits [HomeLoadError] on wrong pixelate size set',
    build: () => HomeBloc(repo),
    act: (bloc) => bloc.add(HomePixelateSizeSet(null)),
    expect: [
      isA<HomeLoadError>(),
    ],
  );

  blocTest(
    'emits [HomeEditing] on pixel shape select set',
    build: () => HomeBloc(repo),
    act: (bloc) => bloc.add(HomePixelShapeSelect(0)),
    expect: [
      isA<HomeEditing>(),
    ],
  );

  blocTest(
    'emits [HomeLoadError] on wrong pixelate size set',
    build: () => HomeBloc(repo),
    act: (bloc) => bloc.add(HomePixelShapeSelect(10)),
    expect: [
      isA<HomeLoadError>(),
    ],
  );

  blocTest(
    'emits [HomeEditingInitialized] on display image set',
    build: () => HomeBloc(repo),
    act: (bloc) => bloc.add(HomeDisplayImageSet(null)),
    expect: [
      isA<HomeEditingInitialized>(),
    ],
  );

  blocTest(
    'emits [HomeEditingInitialized] on image source path set',
    build: () => HomeBloc(repo),
    act: (bloc) => bloc.add(HomeSourceImagePathSet('')),
    expect: [
      isA<HomeEditingInitialized>(),
    ],
  );

  tearDown(() {
    bloc.close();
  });
}*/
