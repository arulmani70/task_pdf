import 'package:task_pdf/src/loigin_firebase/bloc/login_firebase_bloc.dart';
import 'package:task_pdf/src/profile/bloc/profile_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

final log = Logger();

class LogoutDialog {
  void showDeleteConfirmation(BuildContext context, ProfileBloc bloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Text('Are you sure you want to Logout ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                context.read<LoginFirebaseBloc>().add(LogoutRequested());

                log.d("Logout triggered");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
