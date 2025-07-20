import 'package:task_pdf/src/common/common.dart';
import 'package:task_pdf/src/home/bloc/home_bloc.dart';
import 'package:task_pdf/src/home/repo/home_repository.dart';
import 'package:task_pdf/src/home/views/desktop/home_page_desktop.dart';
import 'package:task_pdf/src/home/views/mobile/home_page_mobile.dart';
import 'package:task_pdf/src/home/views/tablet/home_page_tablet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/web.dart';

import 'package:responsive_framework/responsive_framework.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final log = Logger();
    log.d("home page initialized");
    return BlocProvider(
      create: (context) => HomePageBloc(
        repository: HomePageRepository(
          pref: context.read<PreferencesRepository>(),
          apiRepo: context.read<ApiRepository>(),
        ),
      ),
      child: Builder(
        builder: (context) {
          context.read<HomePageBloc>().add(const InitializeHomePage());
          return ResponsiveValue<Widget>(
            context,
            defaultValue: const HomePageDesktop(),
            conditionalValues: [
              const Condition.equals(name: TABLET, value: HomePageTablet()),
              const Condition.smallerThan(
                name: TABLET,
                value: HomePageMobile(),
              ),
            ],
          ).value;
        },
      ),
    );
  }
}
