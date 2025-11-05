import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/account_link_controller.dart';
import '../models/snackbar.dart';
import '../utils/l10n_extensions.dart';

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
    final l10n = context.l10n;
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
          ? l10n.accountLinkedSuccessfully
          : l10n.accountCreatedCheckEmail;
      Navigator.of(context).pop(successMessage);
    } catch (error) {
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: l10n.authenticationFailed('$error'),
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
      builder: (dialogContext) {
        final l10n = dialogContext.l10n;
        return AlertDialog(
          title: Text(l10n.useCloudDataTitle),
          content: Text(l10n.useCloudDataMessage(remoteCount)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.keepLocalButton),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.useCloudDataButton),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final submitButtonLabel = _isLogin
        ? l10n.linkAccountButton
        : l10n.createAccountButton;
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
                _isLogin ? l10n.linkCloudAccountTitle : l10n.createCloudAccountTitle,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _isLogin
                    ? l10n.linkCloudAccountSubtitle
                    : l10n.createCloudAccountSubtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n.emailFieldLabel,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.enterYourEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: l10n.passwordFieldLabel,
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
                    return l10n.enterYourPassword;
                  }
                  if (value.length < 6) {
                    return l10n.passwordTooShort;
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
                    : Text(submitButtonLabel),
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
                      ? l10n.needAccountSignUp
                      : l10n.haveAccountSignIn,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.continueOffline),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
