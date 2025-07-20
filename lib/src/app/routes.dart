import 'package:task_pdf/src/base/base_view.dart';

import 'package:task_pdf/src/common/widgets/file_not_found.dart';

import 'package:task_pdf/src/home/home_view.dart';

import 'package:task_pdf/src/loigin_firebase/bloc/login_firebase_bloc.dart';
import 'package:task_pdf/src/loigin_firebase/logine_firebase_page.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_pdf/src/app/route_names.dart';
import 'package:logger/logger.dart';
import 'package:task_pdf/src/common/widgets/splashscreen.dart';

class Routes {
  final log = Logger();

  GoRouter router = GoRouter(
    routes: [
      GoRoute(
        name: RouteNames.splashscreen,
        path: "/",
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        name: RouteNames.login,
        path: "/login",
        builder: (BuildContext context, GoRouterState state) {
          return LoginFirebasePage();
        },
      ),
      GoRoute(
        name: RouteNames.dashboard,
        path: '/dashboard',
        builder: (context, state) => HomePage(),
      ),

      GoRoute(
        name: RouteNames.base,
        path: "/base",
        builder: (BuildContext context, GoRouterState state) {
          return BaseView();
        },
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final log = Logger();
      final bool signedIn =
          context.read<LoginFirebaseBloc>().state.status ==
          LoginFirebaseStatus.loggedIn;
      log.d("Routes:::Redirect:Is LoggedIn: $signedIn");
      final bool signingIn = state.matchedLocation == '/login';
      final bool isSplashScreen = state.matchedLocation == '/';

      log.d("Routes:::Redirect:MatchedLocation: ${state.matchedLocation}");

      if (isSplashScreen) {
        return null;
      }

      if (!signedIn && !signingIn) {
        return '/login';
      }

      if (signedIn && signingIn) {
        return '/base';
      }

      log.d("Routes:::Redirect:No redirect needed");
      return null;
    },
    debugLogDiagnostics: true,
    errorBuilder: (contex, state) {
      return FileNotFound(message: "${state.error?.message}");
    },
  );
}
