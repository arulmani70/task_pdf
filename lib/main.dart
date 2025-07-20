import 'package:task_pdf/firebase_options.dart';
import 'package:task_pdf/src/loigin_firebase/bloc/login_firebase_bloc.dart';
import 'package:task_pdf/src/loigin_firebase/repo/login_firebase_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:task_pdf/src/app/app.dart';
import 'package:task_pdf/src/base/bloc/base_bloc.dart';
import 'package:task_pdf/src/base/repository/base_repository.dart';
import 'package:task_pdf/src/common/common.dart';
import 'package:task_pdf/src/common/services/services_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupLocator();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => getIt<PreferencesRepository>()),
        RepositoryProvider<ApiRepository>(
          create: (context) => getIt<ApiRepository>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LoginFirebaseBloc(
              repository: LoginFirebaseRepository(
                prefRepo: getIt<PreferencesRepository>(),
                apiRepo: getIt<ApiRepository>(),
              ),
            )..add(LoginInitial()),
          ),
          BlocProvider(
            create: (context) => BaseBloc(
              repository: BaseRepository(
                apiRepo: context.read<ApiRepository>(),
                prefRepo: context.read<PreferencesRepository>(),
              ),
            ),
          ),
        ],
        child: const App(),
      ),
    ),
  );
}
