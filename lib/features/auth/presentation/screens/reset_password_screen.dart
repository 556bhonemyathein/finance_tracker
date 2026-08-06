import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_routes.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_providers.dart';

/// Step 3 of password recovery: choose a new password.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    required this.email,
    required this.code,
    super.key,
  });

  final String email;
  final String code;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends ConsumerState<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.unfocus();
    setState(() => _submitting = true);

    final Failure? failure = await ref
        .read(passwordResetControllerProvider.notifier)
        .reset(
          email: widget.email,
          code: widget.code,
          newPassword: _password.text,
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (failure != null) {
      AppFeedback.error(context, failure);
      return;
    }

    AppFeedback.success(context, 'Password updated — sign in to continue');
    // `go` rather than `push`: the recovery stack is finished and must not be
    // reachable with the back button.
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Choose a new password',
                    style: context.text.headlineSmall,
                  ),
                  AppSpacing.sm.gapH,
                  Text(
                    'Make it something you have not used before.',
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.xxxl.gapH,

                  AppTextField(
                    controller: _password,
                    label: 'New password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    validator: (String? value) =>
                        (value ?? '').isStrongPassword
                        ? null
                        : 'Use 8+ characters with a letter and a number',
                  ),
                  AppSpacing.lg.gapH,

                  AppTextField(
                    controller: _confirm,
                    label: 'Confirm password',
                    prefixIcon: Icons.lock_reset_rounded,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    validator: (String? value) => value == _password.text
                        ? null
                        : 'Passwords do not match',
                  ),
                  AppSpacing.xxl.gapH,

                  AppButton(
                    label: 'Update password',
                    isLoading: _submitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms),
        ),
      ),
    );
  }
}
