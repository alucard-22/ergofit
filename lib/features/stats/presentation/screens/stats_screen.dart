import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/shared_widgets.dart';
import '../providers/stats_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(weeklyStatsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          backgroundColor: AppTheme.bgSecondary,
          onRefresh: () async =>
              ref.invalidate(weeklyStatsProvider),
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estadísticas',
                  style: TextStyle(
                    color:        AppTheme.textPrimary,
                    fontSize:     26,
                    fontWeight:   FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const Text(
                  'Tu progreso de pausas activas',
                  style: TextStyle(
                      color:    AppTheme.textSecondary,
                      fontSize: 14),
                ),
                const SizedBox(height: 24),
                statsAsync.when(
                  loading: () => const _StatsLoading(),
                  error: (e, _) =>
                      _StatsError(error: e.toString()),
                  data: (stats) =>
                      _StatsContent(stats: stats),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Contenido principal ───────────────────────────────────────────────────────

class _StatsContent extends StatelessWidget {
  final WeeklyStats stats;
  const _StatsContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricsGrid(stats: stats),
        const SizedBox(height: 20),
        _WeeklyBarChart(stats: stats),
        const SizedBox(height: 20),
        _AchievementsSection(stats: stats),
        const SizedBox(height: 20),
        _TipCard(streak: stats.currentStreak),
      ],
    );
  }
}

// ── Grid de métricas ──────────────────────────────────────────────────────────

class _MetricsGrid extends StatelessWidget {
  final WeeklyStats stats;
  const _MetricsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap:     true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing:  12,
      childAspectRatio: 1.6,
      children: [
        _MetricCard(
          icon:  Icons.timer_rounded,
          value: '${stats.weekMinutes}',
          unit:  'min',
          label: 'Esta semana',
          color: AppTheme.primary,
        ),
        _MetricCard(
          icon:  Icons.repeat_rounded,
          value: '${stats.monthSessions}',
          unit:  'sesiones',
          label: 'Este mes',
          color: AppTheme.primaryLight,
        ),
        _MetricCard(
          icon:  Icons.local_fire_department_rounded,
          value: '${stats.currentStreak}',
          unit:  'días',
          label: 'Racha actual 🔥',
          color: AppTheme.accentOrange,
        ),
        _MetricCard(
          icon:  Icons.trending_up_rounded,
          value: '${stats.adherencePercent.round()}',
          unit:  '%',
          label: 'Adherencia',
          color: AppTheme.accent,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String   value;
  final String   unit;
  final String   label;
  final Color    color;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DeskCard(
      child: Column(
        crossAxisAlignment:  CrossAxisAlignment.start,
        mainAxisAlignment:   MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color:        color,
                      fontSize:     26,
                      fontWeight:   FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      color:    AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ]),
              ),
              Text(label,
                  style: const TextStyle(
                      color:    AppTheme.textHint,
                      fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Gráfica de barras semanal ─────────────────────────────────────────────────

class _WeeklyBarChart extends StatelessWidget {
  final WeeklyStats stats;
  const _WeeklyBarChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final days   = stats.weekDays;
    final maxY   = (stats.maxMinutes * 1.3).ceilToDouble();
    final todayI = DateTime.now().weekday - 1;

    return DeskCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Minutos activos',
                style: TextStyle(
                  color:      AppTheme.textPrimary,
                  fontSize:   15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                'Esta semana',
                style: TextStyle(
                    color:    AppTheme.textSecondary,
                    fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(
                    color:       AppTheme.border,
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles:   true,
                      reservedSize: 28,
                      interval:     maxY / 4,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(
                          color:    AppTheme.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles:
                        SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles:
                        SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final i = value.toInt();
                        if (i < 0 || i >= days.length) {
                          return const SizedBox.shrink();
                        }
                        final isToday = i == todayI;
                        return Padding(
                          padding: const EdgeInsets.only(
                              top: 6),
                          child: Text(
                            days[i].$1,
                            style: TextStyle(
                              color: isToday
                                  ? AppTheme.primary
                                  : AppTheme.textHint,
                              fontSize:   11,
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(days.length, (i) {
                  final isToday = i == todayI;
                  final mins   = days[i].$2.toDouble();
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: mins,
                        color: mins > 0
                            ? (isToday
                                ? AppTheme.primary
                                : AppTheme.primary
                                    .withOpacity(0.35))
                            : AppTheme.bgTertiary,
                        width: 24,
                        borderRadius:
                            const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                        AppTheme.bgCard,
                    getTooltipItem:
                        (group, _, rod, __) =>
                            BarTooltipItem(
                      '${rod.toY.toInt()} min',
                      const TextStyle(
                        color:      AppTheme.primary,
                        fontSize:   12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              const Text('Hoy',
                  style: TextStyle(
                      color:    AppTheme.textSecondary,
                      fontSize: 11)),
              const SizedBox(width: 16),
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              const Text('Otros días',
                  style: TextStyle(
                      color:    AppTheme.textSecondary,
                      fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Logros ────────────────────────────────────────────────────────────────────

class _AchievementsSection extends StatelessWidget {
  final WeeklyStats stats;
  const _AchievementsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final achievements = <_Achievement>[];

    if (stats.currentStreak >= 1) {
      achievements.add(_Achievement(
        emoji:    '🔥',
        title:    '${stats.currentStreak} día${stats.currentStreak > 1 ? "s" : ""} de racha',
        subtitle: stats.currentStreak >= 7
            ? '¡Una semana completa! Increíble.'
            : 'Cada día cuenta — ¡sigue así!',
        color: AppTheme.accentOrange,
      ));
    }

    if (stats.weekMinutes >= 10) {
      achievements.add(_Achievement(
        emoji:    '⏱️',
        title:    '${stats.weekMinutes} minutos activos',
        subtitle: 'Acumulados esta semana',
        color:    AppTheme.primary,
      ));
    }

    if (stats.adherencePercent >= 60) {
      achievements.add(_Achievement(
        emoji:    '🏆',
        title:    'Alta adherencia',
        subtitle: '${stats.adherencePercent.round()}% de días con pausas',
        color:    AppTheme.accent,
      ));
    }

    if (stats.monthSessions >= 5) {
      achievements.add(_Achievement(
        emoji:    '💪',
        title:    '${stats.monthSessions} sesiones este mes',
        subtitle: '¡Estás construyendo un hábito!',
        color:    AppTheme.accentPurple,
      ));
    }

    if (achievements.isEmpty) {
      achievements.add(_Achievement(
        emoji:    '🌱',
        title:    '¡Comienza hoy!',
        subtitle: 'Completa tu primera pausa activa',
        color:    AppTheme.accent,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Logros'),
        const SizedBox(height: 12),
        ...achievements.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DeskCard(
            child: Row(
              children: [
                Container(
                  width:  46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: a.color.withOpacity(0.12),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(a.emoji,
                        style: const TextStyle(
                            fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(a.title,
                          style: const TextStyle(
                            color:      AppTheme.textPrimary,
                            fontSize:   14,
                            fontWeight: FontWeight.w500,
                          )),
                      Text(a.subtitle,
                          style: const TextStyle(
                            color:    AppTheme.textSecondary,
                            fontSize: 12,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

class _Achievement {
  final String emoji;
  final String title;
  final String subtitle;
  final Color  color;
  const _Achievement({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

// ── Consejo del día ───────────────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  final int streak;
  const _TipCard({required this.streak});

  static const _tips = [
    'Levantarte 2 minutos cada hora reduce el riesgo cardiovascular un 33%.',
    'El síndrome del túnel carpiano afecta al 26% de los desarrolladores. Estira las muñecas.',
    'Cada 20 minutos de pantalla, mira 20 segundos a 6 metros de distancia.',
    'Una caminata de 5 minutos mejora el estado de ánimo durante 2 horas.',
    'Los estiramientos de cuello reducen los dolores de cabeza tensionales.',
    'Hidratarte cada hora también te ayuda a levantarte y moverte.',
  ];

  @override
  Widget build(BuildContext context) {
    final tipIndex =
        DateTime.now().difference(DateTime(2025)).inDays %
            _tips.length;

    return DeskCard(
      color:       const Color(0xFF0D2137),
      borderColor: AppTheme.primary.withOpacity(0.25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width:  36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.accentOrange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('💡',
                  style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Consejo del día',
                  style: TextStyle(
                    color:      AppTheme.accentOrange,
                    fontSize:   12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _tips[tipIndex],
                  style: const TextStyle(
                    color:    AppTheme.textSecondary,
                    fontSize: 13,
                    height:   1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Estados de carga y error ──────────────────────────────────────────────────

class _StatsLoading extends StatelessWidget {
  const _StatsLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color:        AppTheme.bgSecondary,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsError extends StatelessWidget {
  final String error;
  const _StatsError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text('⚠️',
              style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Error cargando estadísticas',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(error,
              style: const TextStyle(
                  color:    AppTheme.textHint,
                  fontSize: 12)),
        ],
      ),
    );
  }
}