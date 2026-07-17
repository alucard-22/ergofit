import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/shared_widgets.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../providers/exercises_providers.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  final String exerciseId;
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseAsync = ref.watch(exerciseByIdProvider(exerciseId));

    return exerciseAsync.when(
      loading: () =>
          const LoadingScreen(message: 'Cargando ejercicio...'),
      error: (e, _) => Scaffold(
        backgroundColor: AppTheme.bgPrimary,
        body: Center(
          child: Text('Error: $e',
              style:
                  const TextStyle(color: AppTheme.accentRed)),
        ),
      ),
      data: (exercise) {
        if (exercise == null) {
          return Scaffold(
            backgroundColor: AppTheme.bgPrimary,
            appBar: AppBar(),
            body: const EmptyState(
              emoji: '🔍',
              title: 'Ejercicio no encontrado',
              subtitle: 'Este ejercicio no existe.',
            ),
          );
        }
        return _PlayerScreen(exercise: exercise);
      },
    );
  }
}

// ── Player Screen ─────────────────────────────────────────────────────────────

class _PlayerScreen extends ConsumerStatefulWidget {
  final Exercise exercise;
  const _PlayerScreen({required this.exercise});

  @override
  ConsumerState<_PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<_PlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late List<String> _steps;

  int  _elapsed      = 0;
  bool _isRunning    = false;
  bool _isCompleted  = false;
  bool _sessionSaved = false;
  int  _currentStep  = 0;

  @override
  void initState() {
    super.initState();
    _steps = List<String>.from(
        jsonDecode(widget.exercise.stepsJson));
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    if (!_sessionSaved && _elapsed > 0) {
      final progress =
          _elapsed / widget.exercise.durationSeconds;
      if (progress >= 0.5) _persistSession(completed: false);
    }
    super.dispose();
  }

  // ── Timer ─────────────────────────────────────────────────────────────────

  void _start() {
    if (_isCompleted) return;
    setState(() => _isRunning = true);
    _tick();
  }

  void _tick() {
    if (!_isRunning || !mounted) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || !_isRunning) return;
      setState(() {
        _elapsed++;
        if (_steps.isNotEmpty) {
          final stepDur =
              widget.exercise.durationSeconds / _steps.length;
          _currentStep = (_elapsed / stepDur)
              .floor()
              .clamp(0, _steps.length - 1);
        }
        if (_elapsed >= widget.exercise.durationSeconds) {
          _isRunning   = false;
          _isCompleted = true;
          _persistSession(completed: true);
        }
      });
      _tick();
    });
  }

  void _pause() => setState(() => _isRunning = false);

  void _reset() => setState(() {
        _isRunning    = false;
        _isCompleted  = false;
        _sessionSaved = false;
        _elapsed      = 0;
        _currentStep  = 0;
      });

  void _completeManually() {
    setState(() {
      _isRunning   = false;
      _isCompleted = true;
    });
    _persistSession(completed: true);
  }

  Future<void> _persistSession({required bool completed}) async {
    if (_sessionSaved) return;
    _sessionSaved = true;
    final dao = ref.read(sessionsDaoProvider);
    await dao.insertSession(SessionsCompanion.insert(
      id:              const Uuid().v4(),
      exerciseId:      widget.exercise.id,
      startedAt:       DateTime.now().millisecondsSinceEpoch,
      durationSeconds: _elapsed,
      completed:       Value(completed),
      usedAiCoach:     const Value(false),
    ));
  }

  double get _progress =>
      (_elapsed / widget.exercise.durationSeconds).clamp(0.0, 1.0);

  String _fmt(int s) {
    final m   = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return Scaffold(
        backgroundColor: AppTheme.bgPrimary,
        body: SafeArea(
          child: _CompletedView(
            exercise:       widget.exercise,
            elapsedSeconds: _elapsed,
            onRestart:      _reset,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildTimer(),
                    const SizedBox(height: 32),
                    _buildControls(),
                    const SizedBox(height: 32),
                    _buildSteps(),
                    if (widget.exercise.hasAiCoach) ...[
                      const SizedBox(height: 20),
                      _buildAiCoachBanner(context),
                    ],
                    const SizedBox(height: 20),
                    _buildInfoRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppTheme.textPrimary),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(
              widget.exercise.name,
              style: const TextStyle(
                color:      AppTheme.textPrimary,
                fontSize:   16,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.exercise.hasAiCoach)
            TextButton.icon(
              onPressed: () =>
                  context.push('/ai-coach/${widget.exercise.id}'),
              icon: const Icon(Icons.smart_toy_rounded,
                  size: 16, color: AppTheme.primary),
              label: const Text('IA Coach',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.primary)),
            ),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    return SizedBox(
      width:  220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox(
            width:  220,
            height: 220,
            child: CircularProgressIndicator(
              value:       1,
              strokeWidth: 10,
              color:       AppTheme.bgTertiary,
              strokeCap:   StrokeCap.round,
            ),
          ),
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => SizedBox(
              width:  220,
              height: 220,
              child: CircularProgressIndicator(
                value:       _progress,
                strokeWidth: 10,
                color: _isRunning
                    ? Color.lerp(AppTheme.primary,
                        AppTheme.primaryLight,
                        _pulseCtrl.value * 0.3)!
                    : AppTheme.primary,
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.exercise.emoji,
                  style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 6),
              Text(
                _fmt(_elapsed),
                style: const TextStyle(
                  color:       AppTheme.textPrimary,
                  fontSize:    38,
                  fontWeight:  FontWeight.w700,
                  letterSpacing: -2,
                ),
              ),
              Text(
                'de ${_fmt(widget.exercise.durationSeconds)}',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                '${(_progress * 100).round()}%',
                style: const TextStyle(
                  color:      AppTheme.primary,
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CtrlBtn(
          icon:      Icons.refresh_rounded,
          onTap:     _reset,
          size:      48,
          bg:        AppTheme.bgSecondary,
          iconColor: AppTheme.textSecondary,
          border:    AppTheme.border,
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: _isRunning ? _pause : _start,
          child: Container(
            width:  72,
            height: 72,
            decoration: BoxDecoration(
              color:  AppTheme.primary,
              shape:  BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:       AppTheme.primary.withOpacity(0.35),
                  blurRadius:  20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              _isRunning
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: Colors.white,
              size:  34,
            ),
          ),
        ),
        const SizedBox(width: 20),
        _CtrlBtn(
          icon:      Icons.check_rounded,
          onTap:     _completeManually,
          size:      48,
          bg:        AppTheme.accent.withOpacity(0.15),
          iconColor: AppTheme.accent,
          border:    AppTheme.accent.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildSteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Pasos',
              style: TextStyle(
                color:      AppTheme.textPrimary,
                fontSize:   16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_currentStep + 1} / ${_steps.length}',
              style: const TextStyle(
                  color: AppTheme.textHint, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._steps.asMap().entries.map((e) {
          final i      = e.key;
          final step   = e.value;
          final isActive = i == _currentStep;
          final isDone   = i < _currentStep;

          return GestureDetector(
            onTap: () => setState(() => _currentStep = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin:   const EdgeInsets.only(bottom: 8),
              padding:  const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primary.withOpacity(0.08)
                    : AppTheme.bgSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? AppTheme.primary.withOpacity(0.4)
                      : AppTheme.border,
                  width: isActive ? 1 : 0.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width:  26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppTheme.accent
                          : isActive
                              ? AppTheme.primary
                              : AppTheme.bgTertiary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check_rounded,
                              size: 14, color: Colors.white)
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: isActive
                                    ? Colors.white
                                    : AppTheme.textHint,
                                fontSize:   12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(
                        color: isActive
                            ? AppTheme.textPrimary
                            : isDone
                                ? AppTheme.textHint
                                : AppTheme.textSecondary,
                        fontSize: 14,
                        height:   1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAiCoachBanner(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push('/ai-coach/${widget.exercise.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppTheme.primary.withOpacity(0.25),
              width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width:  40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IA Coach disponible',
                    style: TextStyle(
                      color:      AppTheme.textPrimary,
                      fontSize:   14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Activa la cámara para corrección de postura en tiempo real',
                    style: TextStyle(
                        color:    AppTheme.textSecondary,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textHint, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow() {
    return Wrap(
      spacing:    8,
      runSpacing: 8,
      children: [
        MetaBadge(
          AppConstants.categoryLabels[widget.exercise.category] ??
              widget.exercise.category,
          icon: Icons.category_rounded,
        ),
        MetaBadge(
          AppConstants.difficultyLabels[
                  widget.exercise.difficulty] ??
              widget.exercise.difficulty,
          icon: Icons.fitness_center_rounded,
        ),
        MetaBadge(
          AppConstants.positionLabels[widget.exercise.position] ??
              widget.exercise.position,
          icon: Icons.accessibility_new_rounded,
        ),
      ],
    );
  }
}

// ── Control Button ────────────────────────────────────────────────────────────

class _CtrlBtn extends StatelessWidget {
  final IconData   icon;
  final VoidCallback onTap;
  final double     size;
  final Color      bg;
  final Color      iconColor;
  final Color      border;

  const _CtrlBtn({
    required this.icon,
    required this.onTap,
    required this.size,
    required this.bg,
    required this.iconColor,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  size,
        height: size,
        decoration: BoxDecoration(
          color:  bg,
          shape:  BoxShape.circle,
          border: Border.all(color: border, width: 0.5),
        ),
        child: Icon(icon, color: iconColor, size: size * 0.45),
      ),
    );
  }
}

// ── Completed View ────────────────────────────────────────────────────────────

class _CompletedView extends StatelessWidget {
  final Exercise     exercise;
  final int          elapsedSeconds;
  final VoidCallback onRestart;

  const _CompletedView({
    required this.exercise,
    required this.elapsedSeconds,
    required this.onRestart,
  });

  String _fmt(int s) {
    final m   = s ~/ 60;
    final sec = s % 60;
    return m > 0 ? '${m}m ${sec}s' : '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width:  100,
            height: 100,
            decoration: BoxDecoration(
              color:  AppTheme.accent.withOpacity(0.1),
              shape:  BoxShape.circle,
              border: Border.all(
                  color: AppTheme.accent.withOpacity(0.4),
                  width: 2),
            ),
            child: const Center(
              child: Text('🎉',
                  style: TextStyle(fontSize: 44)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '¡Ejercicio completado!',
            style: TextStyle(
              color:      AppTheme.textPrimary,
              fontSize:   24,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            exercise.name,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatPill('⏱️', _fmt(elapsedSeconds), 'Duración'),
              const SizedBox(width: 16),
              _StatPill('✅', 'Guardado', 'En estadísticas'),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppTheme.accent.withOpacity(0.3),
                  width: 0.5),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: AppTheme.accent, size: 16),
                SizedBox(width: 6),
                Text(
                  'Sesión guardada en tus estadísticas',
                  style: TextStyle(
                    color:      AppTheme.accent,
                    fontSize:   12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/exercises'),
              icon:  const Icon(Icons.self_improvement_rounded),
              label: const Text('Ver más ejercicios'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRestart,
              icon:  const Icon(Icons.refresh_rounded),
              label: const Text('Repetir este ejercicio'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text('Volver al inicio'),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _StatPill(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:        AppTheme.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        children: [
          Text(emoji,
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color:      AppTheme.textPrimary,
              fontSize:   14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
                color: AppTheme.textHint, fontSize: 11),
          ),
        ],
      ),
    );
  }
}