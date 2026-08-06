import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../shared/models/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/currency_picker.dart';

/// Edit name, avatar, currency and monthly budget.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final AppUser? _user = ref.read(currentUserProvider);
  late final TextEditingController _name = TextEditingController(
    text: _user?.name ?? '',
  );
  late final TextEditingController _budget = TextEditingController(
    text: (_user?.monthlyBudget ?? 0) > 0
        ? _user!.monthlyBudget.toStringAsFixed(2)
        : '',
  );

  late String _currency = _user?.currencyCode ?? 'USD';
  late String? _avatarPath = _user?.avatarUrl;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _budget.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      imageQuality: 85,
    );
    if (file != null) setState(() => _avatarPath = file.path);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_user == null) return;
    context.unfocus();

    setState(() => _submitting = true);

    final Failure? failure = await ref
        .read(authProvider.notifier)
        .updateProfile(
          _user.copyWith(
            name: _name.text.trim(),
            currencyCode: _currency,
            avatarUrl: _avatarPath,
            monthlyBudget: double.tryParse(_budget.text) ?? 0,
          ),
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (failure != null) {
      AppFeedback.error(context, failure);
    } else {
      AppFeedback.success(context, 'Profile updated');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: <Widget>[
              Center(
                child: Stack(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: context.colors.primaryContainer,
                      child: Text(
                        _name.text.initials,
                        style: context.text.headlineSmall?.copyWith(
                          color: context.colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Material(
                        color: context.colors.primary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: _pickAvatar,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 16,
                              color: context.colors.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.xxl.gapH,

              AppTextField(
                controller: _name,
                label: 'Full name',
                prefixIcon: Icons.person_outline_rounded,
                onChanged: (_) => setState(() {}),
                validator: (String? value) =>
                    (value ?? '').trim().length >= 2
                    ? null
                    : 'Enter your name',
              ),
              AppSpacing.lg.gapH,

              // Email is the account identifier; changing it needs
              // re-verification, so it is read-only here by design.
              AppTextField(
                controller: TextEditingController(text: _user?.email ?? ''),
                label: 'Email',
                prefixIcon: Icons.mail_outline_rounded,
                enabled: false,
              ),
              AppSpacing.lg.gapH,

              Text('Currency', style: context.text.labelMedium),
              AppSpacing.sm.gapH,
              CurrencyPickerField(
                selected: _currency,
                onSelected: (String code) => setState(() => _currency = code),
              ),
              AppSpacing.lg.gapH,

              AppTextField.amount(
                controller: _budget,
                label: 'Monthly budget (optional)',
                hint: 'Leave empty to hide the budget card',
                prefixText: _currency,
              ),
              AppSpacing.xxxl.gapH,

              AppButton(
                label: 'Save changes',
                icon: Icons.check_rounded,
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
