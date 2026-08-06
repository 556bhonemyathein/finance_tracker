import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Change the account password from inside a session.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends ConsumerState<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _current = TextEditingController();
  final TextEditingController _next = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _submitting = false;
  Map<String, List<String>> _fieldErrors = <String, List<String>>{};

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.unfocus();

    setState(() {
      _submitting = true;
      _fieldErrors = <String, List<String>>{};
    });

    final Failure? failure = await ref
        .read(authProvider.notifier)
        .changePassword(
          currentPassword: _current.text,
          newPassword: _next.text,
        );

    if (!mounted) return;
    setState(() {
      _submitting = false;
      if (failure is ValidationFailure) _fieldErrors = failure.fieldErrors;
    });

    if (failure == null) {
      AppFeedback.success(context, 'Password changed');
      Navigator.of(context).pop();
    } else if (failure is! ValidationFailure) {
      AppFeedback.error(context, failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change password')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: <Widget>[
              AppTextField(
                controller: _current,
                label: 'Current password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
                autofocus: true,
                textInputAction: TextInputAction.next,
                errorText: _fieldErrors['currentPassword']?.firstOrNull,
                validator: (String? value) => (value ?? '').isNotEmpty
                    ? null
                    : 'Enter your current password',
              ),
              AppSpacing.lg.gapH,

              AppTextField(
                controller: _next,
                label: 'New password',
                prefixIcon: Icons.lock_reset_rounded,
                obscureText: true,
                textInputAction: TextInputAction.next,
                errorText: _fieldErrors['newPassword']?.firstOrNull,
                validator: (String? value) {
                  final String password = value ?? '';
                  if (!password.isStrongPassword) {
                    return 'Use 8+ characters with a letter and a number';
                  }
                  if (password == _current.text) {
                    return 'Choose a password you have not used before';
                  }
                  return null;
                },
              ),
              AppSpacing.lg.gapH,

              AppTextField(
                controller: _confirm,
                label: 'Confirm new password',
                prefixIcon: Icons.check_circle_outline_rounded,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                validator: (String? value) =>
                    value == _next.text ? null : 'Passwords do not match',
              ),
              AppSpacing.xxxl.gapH,

              AppButton(
                label: 'Update password',
                isLoading: _submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
