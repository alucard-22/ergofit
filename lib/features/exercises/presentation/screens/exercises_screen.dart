import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/shared_widgets.dart';
import '../../../../core/database/app_database.dart';
import '../providers/exercises_providers.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  @override
  ConsumerState<ExercisesScreen> createState() =>
      _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync    = ref.watch(filteredExercisesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header fijo ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ejercicios',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    'Para desarrolladores y oficinistas',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Buscador
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => ref
                        .read(searchQueryProvider.notifier)
                        .state = v,
                    style: const TextStyle(
                        color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Buscar ejercicio o beneficio...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppTheme.textHint,
                        size: 20,
                      ),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: AppTheme.textHint,
                                size: 18,
                              ),
                              onPressed: () {
                                _searchCtrl.clear();
                                ref
                                    .read(searchQueryProvider
                                        .notifier)
                                    .state = '';
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Filtros de categoría
                  _CategoryFilter(
                      selectedCategory: selectedCategory),
                ],
              ),
            ),

            // ── Lista ─────────────────────────────────────────────────────
            Expanded(
              child: filteredAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.primary),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Error: $e',
                    style: const TextStyle(
                        color: AppTheme.accentRed),
                  ),
                ),
                data: (exercises) {
                  if (exercises.isEmpty) {
                    return EmptyState(
                      emoji: '🔍',
                      title: 'Sin resultados',
                      subtitle:
                          'Intenta con otra categoría o búsqueda.',
                      action: TextButton(
                        onPressed: () {
                          ref
                              .read(selectedCategoryProvider
                                  .notifier)
                              .state = null;
                          _searchCtrl.clear();
                          ref
                              .read(searchQueryProvider.notifier)
                              .state = '';
                        },
                        child: const Text('Limpiar filtros'),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        20, 12, 20, 20),
                    itemCount: exercises.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _ExerciseCard(exercise: exercises[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category Filter ───────────────────────────────────────────────────────────

class _CategoryFilter extends ConsumerWidget {
  final String? selectedCategory;
  const _CategoryFilter({required this.selectedCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CategoryChip(
              category: '',
              label: 'Todos',
              emoji: '✨',
              isSelected: selectedCategory == null,
              onTap: () => ref
                  .read(selectedCategoryProvider.notifier)
                  .state = null,
            ),
          ),
          ...AppConstants.allCategories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CategoryChip(
                  category: cat,
                  label: AppConstants.categoryLabels[cat] ?? cat,
                  emoji:
                      AppConstants.categoryEmojis[cat] ?? '💪',
                  isSelected: selectedCategory == cat,
                  onTap: () => ref
                      .read(selectedCategoryProvider.notifier)
                      .state = cat,
                ),
              )),
        ],
      ),
    );
  }
}

// ── Exercise Card ─────────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  const _ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return DeskCard(
      padding: const EdgeInsets.all(14),
      onTap: () => context.push('/exercise/${exercise.id}'),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.categoryBg(exercise.category),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(exercise.emoji,
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: [
                    MetaBadge(_formatDuration(
                        exercise.durationSeconds)),
                    MetaBadge(
                      AppConstants.difficultyLabels[
                              exercise.difficulty] ??
                          exercise.difficulty,
                    ),
                    MetaBadge(
                      AppConstants.positionLabels[
                              exercise.position] ??
                          exercise.position,
                    ),
                    if (exercise.hasAiCoach)
                      const AiCoachBadge(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.benefit,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textHint,
            size: 22,
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return secs == 0 ? '$mins min' : '${mins}m ${secs}s';
  }
}