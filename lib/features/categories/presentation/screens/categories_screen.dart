import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_routes.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../shared/models/category.dart';
import '../../../../shared/models/enums.dart';
import '../providers/category_providers.dart';

/// Manage categories.
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Category>> categories = ref.watch(
      categoriesProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRoutes.categoryForm),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New'),
      ),
      body: categories.when(
        data: (List<Category> all) {
          if (all.isEmpty) {
            return const AppEmptyState(
              icon: Icons.category_outlined,
              title: 'No categories',
              message: 'Add one to start organising your spending.',
            );
          }

          // Grouped by kind so the list mirrors how categories are actually
          // chosen — you pick from income *or* expense, never both at once.
          final List<Category> income = all
              .where((Category c) => c.kind == CategoryKind.income)
              .toList();
          final List<Category> expense = all
              .where((Category c) => c.kind == CategoryKind.expense)
              .toList();
          final List<Category> both = all
              .where((Category c) => c.kind == CategoryKind.both)
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              100,
            ),
            children: <Widget>[
              if (income.isNotEmpty)
                _Group(title: 'Income', categories: income, all: all),
              if (expense.isNotEmpty)
                _Group(title: 'Expenses', categories: expense, all: all),
              if (both.isNotEmpty)
                _Group(title: 'Both', categories: both, all: all),
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.page),
          child: TransactionListSkeleton(),
        ),
        error: (Object error, _) => AppErrorState(
          failure: FailureMapper.from(error),
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.title,
    required this.categories,
    required this.all,
  });

  final String title;
  final List<Category> categories;
  final List<Category> all;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Text(
            title,
            style: context.text.labelLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < categories.length; i++) ...<Widget>[
                if (i > 0) const Divider(height: 1),
                _CategoryRow(
                  category: categories[i],
                  all: all,
                ).animate(delay: (30 * i).ms).fadeIn(),
              ],
            ],
          ),
        ),
        AppSpacing.lg.gapH,
      ],
    );
  }
}

class _CategoryRow extends ConsumerWidget {
  const _CategoryRow({required this.category, required this.all});

  final Category category;
  final List<Category> all;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    // First attempt with no reassignment: the repository tells us whether the
    // category is in use, which is cheaper and simpler than pre-counting here.
    Failure? failure = await ref
        .read(categoryControllerProvider.notifier)
        .delete(category.id);

    if (!context.mounted) return;

    if (failure is ValidationFailure) {
      final String? replacement = await _askForReplacement(context, ref);
      if (replacement == null || !context.mounted) return;

      failure = await ref
          .read(categoryControllerProvider.notifier)
          .delete(category.id, reassignTo: replacement);
    }

    if (!context.mounted) return;
    if (failure != null) {
      AppFeedback.error(context, failure);
    } else {
      AppFeedback.success(context, '${category.name} deleted');
    }
  }

  /// Asks which category the orphaned transactions should move to.
  Future<String?> _askForReplacement(BuildContext context, WidgetRef ref) {
    final List<Category> options = all
        .where((Category c) => c.id != category.id)
        .toList();

    return AppFeedback.sheet<String>(
      context,
      child: AppBottomSheet(
        title: 'Move transactions to…',
        child: Column(
          children: <Widget>[
            Text(
              '"${category.name}" is still in use. Pick where its '
              'transactions should go.',
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            AppSpacing.lg.gapH,
            for (final Category option in options)
              ListTile(
                leading: Icon(option.icon, color: option.color),
                title: Text(option.name),
                onTap: () => Navigator.of(context).pop(option.id),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: category.color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        child: Icon(category.icon, size: 20, color: category.color),
      ),
      title: Text(category.name),
      subtitle: category.isDefault
          ? Text(
              'Built-in',
              style: context.text.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            )
          : null,
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert_rounded, size: 20),
        onSelected: (String action) {
          if (action == 'edit') {
            context.pushNamed(AppRoutes.categoryForm, extra: category.id);
          } else {
            _delete(context, ref);
          }
        },
        itemBuilder: (_) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
          const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () =>
          context.pushNamed(AppRoutes.categoryForm, extra: category.id),
    );
  }
}
