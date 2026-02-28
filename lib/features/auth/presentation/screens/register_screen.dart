import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_form_field.dart';
import '../../../../shared/widgets/primary_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _loading = true;
    });
    
    // No authentication - direct navigation to dashboard
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      context.go(RouteNames.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create account',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppFormField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                        return 'Invalid email address';
                      }
                      return null;
                    },
                  ),
                  AppFormField(
                    label: 'Password (min 8)',
                    controller: _passwordController,
                    obscureText: true,
                    validator: (v) {
                       if (v == null || v.isEmpty) return 'Required';
                       if (v.length < 8) return 'Password must be at least 8 characters';
                       return null;
                    }
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Register',
                    onPressed: _loading ? null : _submit,
                    isLoading: _loading,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Back to login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
