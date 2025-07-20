// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:task_pdf/src/loigin_firebase/bloc/login_firebase_bloc.dart';

// class LoginFirebasePage extends StatelessWidget {
//   final emailCtrl = TextEditingController();
//   final passCtrl = TextEditingController();

//   LoginFirebasePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: BlocConsumer<LoginFirebaseBloc, LoginFirebaseState>(
//         listener: (context, state) {
//           if (state.status == LoginFirebaseStatus.loggedIn) {
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(const SnackBar(content: Text('Login Successful')));
//           } else if (state.status == LoginFirebaseStatus.failure) {
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(const SnackBar(content: Text('Login Failed')));
//           }
//         },
//         builder: (context, state) {
//           return Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // App Logo
//                   Icon(Icons.lock_outline, size: 80, color: theme.primaryColor),
//                   const SizedBox(height: 20),

//                   // App Title
//                   Text(
//                     'Welcome Back',
//                     style: theme.textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   // Email Field
//                   TextField(
//                     controller: emailCtrl,
//                     decoration: InputDecoration(
//                       labelText: 'Email',
//                       prefixIcon: const Icon(Icons.email_outlined),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Password Field
//                   TextField(
//                     controller: passCtrl,
//                     obscureText: true,
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       prefixIcon: const Icon(Icons.lock_outline),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   // Login Button or Loader
//                   SizedBox(
//                     width: double.infinity,
//                     child: state.status == LoginFirebaseStatus.loading
//                         ? const Center(child: CircularProgressIndicator())
//                         : ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             onPressed: () {
//                               context.read<LoginFirebaseBloc>().add(
//                                 LoginWithEmail(
//                                   email: emailCtrl.text.trim(),
//                                   password: passCtrl.text.trim(),
//                                 ),
//                               );
//                             },
//                             child: const Text('Login'),
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
