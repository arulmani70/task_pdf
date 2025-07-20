import 'package:task_pdf/src/loigin_firebase/bloc/login_firebase_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginFirebasePageMobile extends StatelessWidget {
  const LoginFirebasePageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();

    return BlocBuilder<LoginFirebaseBloc, LoginFirebaseState>(
      builder: (context, state) {
        final isLoginMode = state.isLoginMode;
        final isLoading = state.status == LoginFirebaseStatus.loading;

        void onSubmit() {
          if (formKey.currentState?.saveAndValidate() ?? false) {
            final values = formKey.currentState!.value;

            if (isLoginMode) {
              context.read<LoginFirebaseBloc>().add(
                LoginWithEmail(
                  email: values['email'],
                  password: values['password'],
                ),
              );
            } else {
              context.read<LoginFirebaseBloc>().add(
                RegisterWithEmail(
                  email: values['email'],
                  password: values['password'],
                  fullName: values['name'],
                  phone: values['phone'] ?? '',
                ),
              );
            }
          }
        }

        final inputDecoration = InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.indigo, width: 2),
          ),
        );

        return Scaffold(
          backgroundColor: const Color(0xFFF1F4F9),
          body: Center(
            child: Container(
              width: 440,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: FormBuilder(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_person_rounded,
                      size: 64,
                      color: Colors.indigo,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isLoginMode
                          ? "Login to your account"
                          : "Create a new account",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (!isLoginMode)
                      Column(
                        children: [
                          FormBuilderTextField(
                            name: 'name',
                            decoration: inputDecoration.copyWith(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.person),
                            ),
                            validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    FormBuilderTextField(
                      name: 'email',
                      decoration: inputDecoration.copyWith(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    if (!isLoginMode)
                      Column(
                        children: [
                          FormBuilderTextField(
                            name: 'phone',
                            decoration: inputDecoration.copyWith(
                              labelText: 'Mobile (Optional)',
                              prefixIcon: const Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    _PasswordField(inputDecoration: inputDecoration),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        onPressed: isLoading ? null : onSubmit,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                isLoginMode ? 'Login' : 'Sign Up',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        context.read<LoginFirebaseBloc>().add(
                          ToggleLoginSignupMode(),
                        );
                      },
                      child: Text(
                        isLoginMode
                            ? "Don't have an account? Sign Up"
                            : "Already have an account? Login",
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PasswordField extends StatefulWidget {
  final InputDecoration inputDecoration;
  const _PasswordField({required this.inputDecoration});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: 'password',
      obscureText: _obscurePassword,
      decoration: widget.inputDecoration.copyWith(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: FormBuilderValidators.required(),
    );
  }
}

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Reset Password"),
      content: FormBuilder(
        key: formKey,
        child: FormBuilderTextField(
          name: 'email',
          decoration: const InputDecoration(
            labelText: 'Enter your email',
            prefixIcon: Icon(Icons.email),
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.email(),
          ]),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState?.saveAndValidate() ?? false) {
              final email = formKey.currentState!.value['email'];
              context.read<LoginFirebaseBloc>().add(
                ForgotPasswordWithEmail(email: email),
              );
              Navigator.pop(context);
            }
          },
          child: const Text("Send Reset Link"),
        ),
      ],
    );
  }
}
