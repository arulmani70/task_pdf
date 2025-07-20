import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_pdf/src/loigin_firebase/bloc/login_firebase_bloc.dart';

class AppBarWidger extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppBarWidger({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LoginFirebaseBloc>().state;

    // Username extract panna logic
    final userName = (state.user.name.isNotEmpty)
        ? state.user.name
        : state.user.email.split('@').first;

    return AppBar(
      backgroundColor: Colors.indigo,
      elevation: 2,
      title: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          if (userName.isNotEmpty)
            Text(
              'Welcome, $userName!',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: "Logout",
          onPressed: () {
            context.read<LoginFirebaseBloc>().add(LogoutRequested());
            Future.delayed(const Duration(milliseconds: 300), () {
              context.go('/login');
            });
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
