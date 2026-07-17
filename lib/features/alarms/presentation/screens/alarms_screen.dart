import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/shared_widgets.dart';
import '../../../../core/database/app_database.dart';
import '../providers/alarms_provider.dart';

class AlarmsScreen extends ConsumerWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmsAsync = ref.watch(alarmsStreamProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alarmas',
                    style: TextStyle(
                      color:      AppTheme.textPrimary,
                      fontSize:   26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    'Recordatorios automáticos de pausa',
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.push('/alarms/add'),
                      icon:  const Icon(Icons.add_rounded),
                      label: const Text('Nueva alarma de pausa'),
                    ),
                  ),
                ],
              ),
            ),

            // ── Lista ──────────────────────────────────────────────────────
            Expanded(
              child: alarmsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.primary),
                ),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(
                          color: AppTheme.accentRed)),
                ),
                data: (alarms) => alarms.isEmpty
                    ? EmptyState(
                        emoji: '⏰',
                        title: 'Sin alarmas aún',
                        subtitle:
                            'Crea tu primera alarma de pausa para recibir recordatorios personalizados.',
                        action: ElevatedButton(
                          onPressed: () =>
                              context.push('/alarms/add'),
                          child: const Text(
                              'Crear primera alarma'),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                            20, 12, 20, 20),
                        itemCount: alarms.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) =>
                            _AlarmCard(alarm: alarms[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Alarm Card ────────────────────────────────────────────────────────────────

class _AlarmCard extends ConsumerWidget {
  final Alarm alarm;
  const _AlarmCard({super.key, required this.alarm});

  String get _timeLabel {
    final h = alarm.startHour.toString().padLeft(2, '0');
    final m = alarm.startMinute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get _weekdaysLabel {
    final raw  = List<bool>.from(jsonDecode(alarm.weekdaysJson));
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final active = <String>[];
    for (int i = 0; i < raw.length; i++) {
      if (raw[i]) active.add(days[i]);
    }
    if (active.length == 7) return 'Todos los días';
    if (active.length == 5 && !raw[5] && !raw[6]) {
      return 'Días laborales';
    }
    return active.join(' · ');
  }

  List<String> get _categories =>
      List<String>.from(jsonDecode(alarm.categoriesJson));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier =
        ref.read(alarmsNotifierProvider.notifier);

    return Dismissible(
      key: Key(alarm.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.bgSecondary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text('Eliminar alarma',
                style:
                    TextStyle(color: AppTheme.textPrimary)),
            content: Text(
              '¿Eliminar "${alarm.name}"? También se cancelarán sus notificaciones.',
              style: const TextStyle(
                  color: AppTheme.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pop(ctx, true),
                child: const Text('Eliminar',
                    style: TextStyle(
                        color: AppTheme.accentRed)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => notifier.delete(alarm),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.accentRed.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppTheme.accentRed, size: 26),
      ),
      child: AnimatedOpacity(
        opacity: alarm.isEnabled ? 1.0 : 0.55,
        duration: const Duration(milliseconds: 200),
        child: DeskCard(
          borderColor: alarm.isEnabled
              ? AppTheme.primary.withOpacity(0.3)
              : AppTheme.border,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hora + switch
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _timeLabel,
                      style: TextStyle(
                        color: alarm.isEnabled
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                        fontSize:    34,
                        fontWeight:  FontWeight.w700,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  Switch(
                    value:    alarm.isEnabled,
                    onChanged: (_) => notifier.toggle(alarm),
                  ),
                ],
              ),

              // Nombre
              Text(
                alarm.name,
                style: const TextStyle(
                  color:      AppTheme.textPrimary,
                  fontSize:   14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),

              // Intervalo y días
              Text(
                'Cada ${alarm.intervalMinutes} min · $_weekdaysLabel',
                style: const TextStyle(
                    color:    AppTheme.textSecondary,
                    fontSize: 12),
              ),

              // Categorías
              if (_categories.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing:    6,
                  runSpacing: 4,
                  children: _categories
                      .map((cat) => Container(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical:   3),
                            decoration: BoxDecoration(
                              color: AppTheme.primary
                                  .withOpacity(0.12),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              cat,
                              style: const TextStyle(
                                color:    AppTheme.primaryLight,
                                fontSize: 11,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}