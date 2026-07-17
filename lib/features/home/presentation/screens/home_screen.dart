import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/shared_widgets.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final statsAsync   = ref.watch(homeStatsProvider);
    final name  = profileAsync.value?.name ?? 'Profesional';
    final stats = statsAsync.value;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildHeader(name, stats?.currentStreak ?? 0),
                  ),
                  const _ProfileButton(),
                ],
              ),
              const SizedBox(height: 20),
              if (stats != null)
                _HeroCard(stats: stats)
              else
                _HeroCardSkeleton(),
              const SizedBox(height: 24),
              if (stats != null) ...[
                DailyGoalProgress(
                  currentMinutes: stats.todayMinutes,
                  goalMinutes: profileAsync.value?.dailyGoalMinutes
                      ?? AppConstants.defaultDailyGoalMinutes,
                ),
                const SizedBox(height: 24),
              ],
              const SectionTitle('Acceso rápido'),
              const SizedBox(height: 12),
              _QuickAccessGrid(activeAlarms: stats?.activeAlarms ?? 0),
              const SizedBox(height: 24),
              const SectionTitle('Esta semana'),
              const SizedBox(height: 12),
              if (stats != null)
                _WeekMetrics(stats: stats)
              else
                _MetricsSkeleton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name, int streak) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Buenos días'
        : hour < 18 ? 'Buenas tardes' : 'Buenas noches';
    final emoji = hour < 12 ? '☀️' : hour < 18 ? '👋' : '🌙';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$emoji $greeting,',
          style: const TextStyle(
              color: AppTheme.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          name,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        if (streak > 0) ...[
          const SizedBox(height: 8),
          StreakBadge(days: streak),
        ],
      ],
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.push('/profile'),
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.bgSecondary,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: const Icon(
          Icons.person_outline_rounded,
          color: AppTheme.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}

// ── Hero Card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final HomeStats stats;
  const _HeroCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      colors: const [Color(0xFF1E3A5F), Color(0xFF0D2137)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stats.activeAlarms > 0
                ? '${stats.activeAlarms} alarma${stats.activeAlarms > 1 ? "s" : ""} activa${stats.activeAlarms > 1 ? "s" : ""}'
                : 'Sin alarmas configuradas aún',
            style: const TextStyle(color: Color(0xFF7AB8E8), fontSize: 13),
          ),
          const SizedBox(height: 12),
          const Text(
            '¿Listo para tu\npausa activa?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            stats.todayMinutes > 0
                ? '${stats.todayMinutes} min activos hoy · ¡sigue así! 💪'
                : 'Comienza con un ejercicio corto de 1-2 minutos',
            style: const TextStyle(color: Color(0xFF8B9FC8), fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go(AppRoutes.exercises),
              child: const Text('Comenzar ejercicio'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// ── Quick Access Grid ─────────────────────────────────────────────────────────

class _QuickAccessGrid extends StatelessWidget {
  final int activeAlarms;
  const _QuickAccessGrid({required this.activeAlarms});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _QuickCard(
          emoji: '🧘',
          title: 'Estiramientos',
          subtitle: '12 ejercicios',
          bgColor: const Color(0xFF1A2F4E),
          accentColor: AppTheme.primary,
          onTap: () => context.go(AppRoutes.exercises),
        ),
        _QuickCard(
          emoji: '👁️',
          title: 'Descanso visual',
          subtitle: 'Regla 20-20-20',
          bgColor: const Color(0xFF1F1A3E),
          accentColor: AppTheme.accentPurple,
          onTap: () => context.push('/exercise/eyes_20_20_20'),
        ),
        _QuickCard(
          emoji: '🤖',
          title: 'IA Coach',
          subtitle: 'Corrección en vivo',
          bgColor: const Color(0xFF0D2137),
          accentColor: AppTheme.primaryLight,
          onTap: () => context.push('/exercise/shoulder_rolls'),
        ),
        _QuickCard(
          emoji: '⏰',
          title: 'Alarmas',
          subtitle: '$activeAlarms activa${activeAlarms != 1 ? "s" : ""}',
          bgColor: const Color(0xFF2E1C0A),
          accentColor: AppTheme.accentOrange,
          onTap: () => context.go(AppRoutes.alarms),
        ),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color accentColor;
  final VoidCallback onTap;

  const _QuickCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withOpacity(0.25),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Week Metrics ──────────────────────────────────────────────────────────────

class _WeekMetrics extends StatelessWidget {
  final HomeStats stats;
  const _WeekMetrics({required this.stats});

  @override
  Widget build(BuildContext context) {
    return DeskCard(
      child: Row(
        children: [
          Expanded(
            child: _MetricItem(
              value: '${stats.weekMinutes}',
              unit: 'min',
              label: 'Semana',
              color: AppTheme.primary,
            ),
          ),
          Container(width: 0.5, height: 48, color: AppTheme.border),
          Expanded(
            child: _MetricItem(
              value: '${stats.currentStreak}',
              unit: 'días',
              label: 'Racha 🔥',
              color: AppTheme.accentOrange,
            ),
          ),
          Container(width: 0.5, height: 48, color: AppTheme.border),
          Expanded(
            child: _MetricItem(
              value: '${stats.adherencePercent.round()}',
              unit: '%',
              label: 'Adherencia',
              color: AppTheme.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  final Color color;

  const _MetricItem({
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(children: [
            TextSpan(
              text: value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: ' $unit',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textHint, fontSize: 11),
        ),
      ],
    );
  }
}

class _MetricsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const _Skeleton(height: 72, radius: 16);
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _Skeleton extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _Skeleton({
    this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}