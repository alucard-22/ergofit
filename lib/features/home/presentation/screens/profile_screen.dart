import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_provider.dart';
import '../providers/home_providers.dart';

/// Pantalla de perfil del usuario.
/// Permite editar nombre, rol laboral y meta diaria de minutos.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  String? _selectedRole;
  int? _selectedGoal;
  bool _initialized = false;
  bool _saving = false;

  static const _goalOptions = [10, 15, 20, 30, 45];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Carga los datos actuales del perfil en los controles editables.
  /// Solo se ejecuta una vez, la primera vez que el perfil llega con datos.
  void _initializeFields(profile) {
    if (_initialized || profile == null) return;
    _nameController.text = profile.name;
    _selectedRole = profile.jobRole;
    _selectedGoal = profile.dailyGoalMinutes;
    _initialized = true;
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty || _saving) return;
    setState(() => _saving = true);

    final dao = ref.read(userProfileDaoProvider);
    await dao.updateName(_nameController.text.trim());
    if (_selectedRole != null) {
      await dao.updateJobRole(_selectedRole!);
    }
    if (_selectedGoal != null) {
      await dao.updateDailyGoal(_selectedGoal!);
    }

    if (!mounted) return;
    setState(() => _saving = false);

    // Refresca el home para que se vea el nombre actualizado
    ref.invalidate(homeStatsProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    _initializeFields(profileAsync.value);

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: AppTheme.textPrimary),
                    onPressed: () => context.pop(),
                  ),
                  const Text(
                    'Mi perfil',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ── Formulario ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Text('🙋', style: TextStyle(fontSize: 36)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Nombre
                    const Text(
                      'Nombre',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'Tu nombre',
                        prefixIcon: Icon(Icons.person_outline_rounded,
                            color: AppTheme.textHint),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Rol laboral
                    const Text(
                      'Rol laboral',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: AppConstants.roleLabels.entries.map((entry) {
                        final isSelected = _selectedRole == entry.key;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedRole = entry.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.bgSecondary,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.border,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // Meta diaria
                    const Text(
                      'Meta diaria de minutos activos',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _goalOptions.map((minutes) {
                        final isSelected = _selectedGoal == minutes;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedGoal = minutes),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.bgSecondary,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.border,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              '$minutes min',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),

                    // Botón guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Guardar cambios',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Información de la app
                    Center(
                      child: Column(
                        children: [
                          Text(
                            AppConstants.appName,
                            style: const TextStyle(
                              color: AppTheme.textHint,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Versión ${AppConstants.appVersion}',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}