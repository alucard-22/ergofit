import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/alarms_provider.dart';

class AddAlarmScreen extends ConsumerStatefulWidget {
  const AddAlarmScreen({super.key});

  @override
  ConsumerState<AddAlarmScreen> createState() =>
      _AddAlarmScreenState();
}

class _AddAlarmScreenState
    extends ConsumerState<AddAlarmScreen> {
  final _nameCtrl = TextEditingController(
      text: 'Pausa activa');
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  int _intervalMinutes = 45;
  List<bool> _weekdays = [
    true, true, true, true, true, false, false
  ]; // Lun-Vie
  final List<String> _selectedCategories = ['Cuello', 'Hombros'];
  bool _saving = false;

  final _categoryOptions = [
    'Cuello', 'Hombros', 'Espalda',
    'Ojos', 'Muñecas', 'Respiración', 'Piernas',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
              primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      await ref.read(alarmsNotifierProvider.notifier).create(
        name:            _nameCtrl.text.isEmpty
            ? 'Pausa activa'
            : _nameCtrl.text,
        startTime:       _startTime,
        intervalMinutes: _intervalMinutes,
        weekdays:        _weekdays,
        categories:      _selectedCategories,
      );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ────────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppTheme.textPrimary),
                    onPressed: () => context.pop(),
                  ),
                  const Text(
                    'Nueva alarma',
                    style: TextStyle(
                      color:      AppTheme.textPrimary,
                      fontSize:   18,
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildSection('Nombre', _buildNameField()),
                    const SizedBox(height: 20),
                    _buildSection(
                        'Hora de inicio', _buildTimePicker()),
                    const SizedBox(height: 20),
                    _buildSection('Intervalo de recordatorio',
                        _buildIntervalPicker()),
                    const SizedBox(height: 20),
                    _buildSection(
                        'Días activos', _buildWeekdayPicker()),
                    const SizedBox(height: 20),
                    _buildSection('Tipo de ejercicios',
                        _buildCategoryPicker()),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color:      AppTheme.textSecondary,
            fontSize:   13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameCtrl,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: const InputDecoration(
          hintText: 'Ej: Pausa de la mañana'),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        AppTheme.bgSecondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppTheme.border, width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded,
                color: AppTheme.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              _startTime.format(context),
              style: const TextStyle(
                color:        AppTheme.textPrimary,
                fontSize:     22,
                fontWeight:   FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalPicker() {
    return Wrap(
      spacing:    8,
      runSpacing: 8,
      children: AppConstants.intervalOptions.map((mins) {
        final isSelected = mins == _intervalMinutes;
        return GestureDetector(
          onTap: () =>
              setState(() => _intervalMinutes = mins),
          child: AnimatedContainer(
            duration:
                const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary
                  : AppTheme.bgSecondary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.border,
                width: 0.5,
              ),
            ),
            child: Text(
              '${mins}min',
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : AppTheme.textSecondary,
                fontSize:   13,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeekdayPicker() {
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return Row(
      children: List.generate(7, (i) {
        final isSelected = _weekdays[i];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 3),
            child: GestureDetector(
              onTap: () => setState(
                  () => _weekdays[i] = !_weekdays[i]),
              child: AnimatedContainer(
                duration:
                    const Duration(milliseconds: 150),
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.bgSecondary,
                  borderRadius:
                      BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.border,
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    days[i],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppTheme.textSecondary,
                      fontSize:   13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCategoryPicker() {
    return Wrap(
      spacing:    8,
      runSpacing: 8,
      children: _categoryOptions.map((cat) {
        final isSelected =
            _selectedCategories.contains(cat);
        return GestureDetector(
          onTap: () => setState(() {
            if (isSelected) {
              _selectedCategories.remove(cat);
            } else {
              _selectedCategories.add(cat);
            }
          }),
          child: AnimatedContainer(
            duration:
                const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary
                  : AppTheme.bgSecondary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.border,
                width: 0.5,
              ),
            ),
            child: Text(
              cat,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : AppTheme.textSecondary,
                fontSize:   13,
                fontWeight: isSelected
                    ? FontWeight.w500
                    : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saving ? null : _save,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
              vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: _saving
            ? const SizedBox(
                width:  20,
                height: 20,
                child: CircularProgressIndicator(
                  color:       Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Guardar alarma',
                style: TextStyle(
                    fontSize:   16,
                    fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}