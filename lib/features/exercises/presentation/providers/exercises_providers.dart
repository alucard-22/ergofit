import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';

/// Categoría seleccionada en el filtro (null = todas).
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Texto de búsqueda actual.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Stream de todos los ejercicios.
/// Drift actualiza este stream automáticamente si cambia la tabla.
final allExercisesProvider = StreamProvider<List<Exercise>>((ref) {
  final dao = ref.watch(exercisesDaoProvider);
  return dao.watchAll();
});

/// Lista filtrada según categoría y búsqueda.
/// Deriva de allExercisesProvider — no hace queries extra a la BD.
final filteredExercisesProvider =
    Provider<AsyncValue<List<Exercise>>>((ref) {
  final allAsync = ref.watch(allExercisesProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query    = ref.watch(searchQueryProvider).toLowerCase().trim();

  return allAsync.whenData((exercises) {
    var filtered = exercises;

    if (category != null) {
      filtered = filtered
          .where((e) => e.category == category)
          .toList();
    }

    if (query.isNotEmpty) {
      filtered = filtered
          .where((e) =>
              e.name.toLowerCase().contains(query) ||
              e.benefit.toLowerCase().contains(query) ||
              e.category.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  });
});

/// Ejercicio individual por ID (para la pantalla de detalle y el player).
final exerciseByIdProvider =
    FutureProvider.family<Exercise?, String>((ref, id) {
  final dao = ref.watch(exercisesDaoProvider);
  return dao.getById(id);
});