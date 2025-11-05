import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/account_link_controller.dart';
import '../models/snackbar.dart';

class AccountLinkSheet extends StatefulWidget {
  const AccountLinkSheet({super.key});

  static Future<void> show(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: bottomInset,
          ),
          child: const AccountLinkSheet(),
        );
      },
    );

    if (result != null && context.mounted) {
      context.showBeautifulSnackBar(message: result, isError: false);
    }
  }

  @override
  State<AccountLinkSheet> createState() => _AccountLinkSheetState();
}

class _AccountLinkSheetState extends State<AccountLinkSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isObscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });

    final controller = context.read<AccountLinkController>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final result = await controller.authenticate(
        mode: _isLogin ? AccountAuthMode.login : AccountAuthMode.signup,
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (_isLogin && result.mergeRequired && result.remoteData.isNotEmpty) {
        final shouldOverride = await _confirmOverride(result.remoteData.length);
        if (shouldOverride == true) {
          await controller.replaceLocalWith(result.remoteData);
        }
      }

      if (!mounted) return;
      _formKey.currentState!.reset();
      _emailController.clear();
      _passwordController.clear();

      final successMessage = _isLogin
          ? 'Account linked successfully.'
          : 'Account created. Check your email to confirm.';
      Navigator.of(context).pop(successMessage);
    } catch (error) {
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: 'Authentication failed: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool?> _confirmOverride(int remoteCount) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Use cloud data?'),
        content: Text(
          'Cloud backup contains $remoteCount item(s). '
          'Do you want to replace your local entries with the cloud data?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep local'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Use cloud data'),
          ),
        ],
      ),
    );
  }

  String get _submitButtonLabel => _isLogin ? 'Link Account' : 'Create Account';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isLogin ? 'Link cloud account' : 'Create cloud account',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _isLogin
                    ? 'Sign in to sync your OTP secrets securely.'
                    : 'Create an account to enable secure backups.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_submitButtonLabel),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                child: Text(
                  _isLogin
                      ? 'Need an account? Sign up'
                      : 'Already have an account? Sign in',
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue offline'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
