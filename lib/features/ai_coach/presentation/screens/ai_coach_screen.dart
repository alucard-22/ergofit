import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' hide Column;
import 'guided_steps.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../exercises/presentation/providers/exercises_providers.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AiCoachScreen extends ConsumerStatefulWidget {
  final String exerciseId;
  const AiCoachScreen({super.key, required this.exerciseId});

  @override
  ConsumerState<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends ConsumerState<AiCoachScreen> {
  _ScreenState _state = _ScreenState.askingPermission;
  CameraController? _camera;
  bool _processingFrame = false;
  PoseDetector? _detector;
  List<Pose> _poses = [];
  String _feedbackText = 'Posiciónate frente a la cámara para comenzar';
  _FeedbackLevel _feedbackLevel = _FeedbackLevel.neutral;
  int _poseScore = 0;
  late final List<GuidedStep>? _steps = getGuidedSteps(widget.exerciseId);
  bool get _isGuided => _steps != null;

  Color get _skeletonColor {
    if (_feedbackLevel == _FeedbackLevel.good) return AppTheme.accent;
    if (_feedbackLevel == _FeedbackLevel.warning) return AppTheme.accentOrange;
    if (_feedbackLevel == _FeedbackLevel.info) return AppTheme.primary;
    return AppTheme.textHint;
  }

  final Map<String, double?> _calibration = {};
  int _stepIndex = 0;
  double _holdProgress = 0.0;
  DateTime? _holdStart;
  bool _guidedDone = false;
  DateTime? _sessionStart;
  _GuidedState _guidedState = _GuidedState.explaining;
  bool _stepAnnounced = false;
  // ── Text to Speech + contador ─────────────────────────────────────────────
  final FlutterTts _tts = FlutterTts();
  int _countdownSeconds = 0;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _checkPermission();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.85);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) await _tts.stop();
    _isSpeaking = true;
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _tts.stop();
    _camera?.stopImageStream();
    _camera?.dispose();
    _detector?.close();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      _initCamera();
    } else {
      setState(() => _state = _ScreenState.askingPermission);
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _initCamera();
    } else if (status.isPermanentlyDenied) {
      setState(() => _state = _ScreenState.permissionDenied);
    } else {
      setState(() => _state = _ScreenState.askingPermission);
    }
  }

  Future<void> _initCamera() async {
    setState(() => _state = _ScreenState.initializing);
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _camera = CameraController(
        front, ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await _camera!.initialize();
      _detector = PoseDetector(
        options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
      );
      await _camera!.startImageStream(_onCameraFrame);
      if (mounted) setState(() => _state = _ScreenState.active);
    } catch (e) {
      if (mounted) setState(() => _state = _ScreenState.error);
    }
  }

  void _onCameraFrame(CameraImage image) async {
    if (_processingFrame || _detector == null || _guidedDone) return;
    _processingFrame = true;
    try {
      final inputImage = _buildInputImage(image);
      if (inputImage == null) return;
      final poses = await _detector!.processImage(inputImage);
      if (mounted) {
        setState(() {
          _poses = poses;
          _analyzePoses(poses);
        });
      }
    } finally {
      _processingFrame = false;
    }
  }

  InputImage? _buildInputImage(CameraImage image) {
    final camera = _camera?.description;
    if (camera == null) return null;
    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (rotation == null) return null;
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;
    final bytes = image.planes.fold<List<int>>([], (buf, p) => buf..addAll(p.bytes));
    return InputImage.fromBytes(
      bytes: Uint8List.fromList(bytes),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  void _analyzePoses(List<Pose> poses) {
    if (_isGuided) {
      _processGuided(poses);
      return;
    }
    if (poses.isEmpty) {
      _feedbackText = 'No te veo. Aléjate un poco de la cámara.';
      _feedbackLevel = _FeedbackLevel.warning;
      _poseScore = 0;
      return;
    }
    final exercise = ref.read(exerciseByIdProvider(widget.exerciseId)).value;
    final feedback = _getFeedbackForCategory(poses.first, exercise?.category ?? 'general');
    _feedbackText = feedback.text;
    _feedbackLevel = feedback.level;
    _poseScore = feedback.score;
  }

  void _processGuided(List<Pose> poses) {
    _sessionStart ??= DateTime.now();
    if (_guidedDone || _steps == null) return;

    final step = _steps![_stepIndex];

    // ── Fase 1: Anunciar el paso con TTS ─────────────────────────────────────
    if (!_stepAnnounced) {
      _stepAnnounced  = true;
      _guidedState    = _GuidedState.explaining;
      _holdProgress   = 0;
      _holdStart      = null;
      _countdownSeconds = 0;
      _feedbackText   = step.instruction;
      _feedbackLevel  = _FeedbackLevel.neutral;

      // Hablar el paso completo
      _speak('Paso ${_stepIndex + 1}. ${step.title}. ${step.instruction}')
          .then((_) {
        if (mounted && !_guidedDone) {
          setState(() => _guidedState = _GuidedState.detecting);
        }
      });
      return;
    }

    // ── Fase 2: Esperando que el TTS termine de hablar ────────────────────────
    if (_guidedState == _GuidedState.explaining) {
      _feedbackText  = step.instruction;
      _feedbackLevel = _FeedbackLevel.neutral;
      return;
    }

    // ── Fase 3: Detectar postura ──────────────────────────────────────────────
    if (poses.isEmpty) {
      _feedbackText     = 'No te veo. Ubícate frente a la cámara.';
      _feedbackLevel    = _FeedbackLevel.warning;
      _holdProgress     = 0;
      _holdStart        = null;
      _countdownSeconds = 0;
      return;
    }

    final pose    = poses.first;
    final correct = step.check(pose, _calibration);

    if (correct) {
      if (_guidedState == _GuidedState.detecting) {
        _guidedState = _GuidedState.holding;
        _speak('¡Bien! Mantén la posición.');
      }

      _holdStart ??= DateTime.now();
      final ms = DateTime.now().difference(_holdStart!).inMilliseconds;
      _holdProgress = (ms / (step.holdSeconds * 1000)).clamp(0.0, 1.0);

      // Contador regresivo
      final remaining   = ((step.holdSeconds * 1000 - ms) / 1000).ceil();
      final newCountdown = remaining.clamp(0, step.holdSeconds.ceil());

      if (newCountdown != _countdownSeconds &&
          newCountdown <= 3 && newCountdown > 0) {
        _speak(newCountdown.toString());
      }
      _countdownSeconds = newCountdown;
      _feedbackText     = '¡Mantén la posición!';
      _feedbackLevel    = _FeedbackLevel.good;
      _poseScore        = (_holdProgress * 100).round();

      if (_holdProgress >= 1.0) _advance();
    } else {
      if (_guidedState == _GuidedState.holding) {
        // Perdió la postura durante el hold
        _guidedState = _GuidedState.detecting;
        _speak('Ajusta la postura.');
      }
      _holdStart        = null;
      _holdProgress     = 0;
      _countdownSeconds = 0;
      _feedbackText     = step.instruction;
      _feedbackLevel    = _FeedbackLevel.info;
      _poseScore        = 0;
    }
  }

void _advance() {
    _holdStart        = null;
    _holdProgress     = 0;
    _countdownSeconds = 0;
    _stepAnnounced    = false;
    _guidedState      = _GuidedState.explaining;

    final total = _steps?.length ?? 0;
    if (_stepIndex < total - 1) {
      _stepIndex++;
    } else {
      _guidedDone = true;
      _speak('¡Ejercicio completado! Excelente trabajo.');
      _camera?.stopImageStream();
      _saveGuidedSession();
    }
  }
 void _skipStep() {
    setState(() {
      _tts.stop();
      _isSpeaking    = false;
      _stepAnnounced = false;
      _guidedState   = _GuidedState.explaining;
      _advance();
    });
  }

  Future<void> _saveGuidedSession() async {
    final seconds = _sessionStart == null
        ? 0
        : DateTime.now().difference(_sessionStart!).inSeconds;
    final dao = ref.read(sessionsDaoProvider);
    await dao.insertSession(SessionsCompanion.insert(
      id: const Uuid().v4(),
      exerciseId: widget.exerciseId,
      startedAt: DateTime.now().millisecondsSinceEpoch,
      durationSeconds: seconds,
      completed: const Value(true),
      usedAiCoach: const Value(true),
      aiScore: const Value(1.0),
    ));
  }

// ── Helpers normalizados ──────────────────────────────────────────────────

  double _sw(Pose p) {
    final l = p.landmarks[PoseLandmarkType.leftShoulder];
    final r = p.landmarks[PoseLandmarkType.rightShoulder];
    if (l == null || r == null) return 1;
    return (l.x - r.x).abs().clamp(1.0, double.infinity);
  }

  double _shoulderDiffNorm(Pose p) {
    final l = p.landmarks[PoseLandmarkType.leftShoulder];
    final r = p.landmarks[PoseLandmarkType.rightShoulder];
    if (l == null || r == null) return 999;
    return (l.y - r.y).abs() / _sw(p);
  }

  double _noseOffsetNorm(Pose p) {
    final n = p.landmarks[PoseLandmarkType.nose];
    final l = p.landmarks[PoseLandmarkType.leftShoulder];
    final r = p.landmarks[PoseLandmarkType.rightShoulder];
    if (n == null || l == null || r == null) return 999;
    return (n.x - (l.x + r.x) / 2).abs() / _sw(p);
  }

  // ── Feedback genérico normalizado ─────────────────────────────────────────

  _Feedback _getFeedbackForCategory(Pose pose, String category) {
    final nose    = pose.landmarks[PoseLandmarkType.nose];
    final leftSh  = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightSh = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftEl  = pose.landmarks[PoseLandmarkType.leftElbow];
    final rightEl = pose.landmarks[PoseLandmarkType.rightElbow];
    final leftWr  = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWr = pose.landmarks[PoseLandmarkType.rightWrist];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip= pose.landmarks[PoseLandmarkType.rightHip];
    final leftEar = pose.landmarks[PoseLandmarkType.leftEar];
    final rightEar= pose.landmarks[PoseLandmarkType.rightEar];

    switch (category) {
      case 'neck':
        return _analyzeNeck(pose, nose, leftSh, rightSh, leftEar, rightEar);
      case 'shoulders':
        return _analyzeShoulders(pose, leftSh, rightSh, leftEl, rightEl);
      case 'wrists':
        return _analyzeWrists(pose, leftEl, rightEl, leftWr, rightWr);
      case 'back':
        return _analyzeBack(pose, leftSh, rightSh, leftHip, rightHip);
      default:
        return _generalFeedback(pose, leftSh, rightSh);
    }
  }

  _Feedback _analyzeNeck(
    Pose pose,
    PoseLandmark? nose,
    PoseLandmark? leftSh,
    PoseLandmark? rightSh,
    PoseLandmark? leftEar,
    PoseLandmark? rightEar,
  ) {
    if (nose == null || leftSh == null || rightSh == null) {
      return _Feedback(
          'Muestra tu cabeza y hombros completos en el encuadre',
          _FeedbackLevel.neutral, 0);
    }

    final sw = _sw(pose);
    final diffNorm   = _shoulderDiffNorm(pose);
    final offsetNorm = _noseOffsetNorm(pose);

    // Hombros muy desnivelados
    if (diffNorm > 0.30) {
      return _Feedback(
          'Hombros desnivelados — relaja el hombro más alto',
          _FeedbackLevel.warning, 40);
    }

    // Hombro levemente elevado
    if (diffNorm > 0.15) {
      return _Feedback(
          'Hombro ligeramente elevado — respira y relájalo',
          _FeedbackLevel.info, 65);
    }

    // Detectar rotación usando orejas
    if (leftEar != null && rightEar != null) {
      final distLeft  = (nose.x - leftEar.x).abs();
      final distRight = (nose.x - rightEar.x).abs();
      final asymmetry = (distLeft - distRight).abs() / sw;

      if (asymmetry > 0.30) {
        return _Feedback(
            'Buena rotación de cuello — mantén y respira profundo',
            _FeedbackLevel.good, 90);
      }
    }

    // Inclinación lateral
    if (offsetNorm > 0.35) {
      return _Feedback(
          'Buena inclinación lateral — siente el estiramiento en el lado opuesto',
          _FeedbackLevel.good, 88);
    }

    if (offsetNorm > 0.15) {
      return _Feedback(
          'Postura correcta — mantén y respira profundo',
          _FeedbackLevel.good, 92);
    }

    // Flexión (mentón al pecho)
    final noseY  = nose.y;
    final shY    = (leftSh.y + rightSh.y) / 2;
    final dropNorm = (noseY - shY) / sw;
    if (dropNorm > -0.20) {
      return _Feedback(
          'Cabeza bien inclinada — siente el estiramiento en la nuca',
          _FeedbackLevel.good, 90);
    }

    return _Feedback(
        'Inclina la cabeza hacia un lado, al frente o gira para comenzar',
        _FeedbackLevel.info, 60);
  }

  _Feedback _analyzeShoulders(
    Pose pose,
    PoseLandmark? leftSh,
    PoseLandmark? rightSh,
    PoseLandmark? leftEl,
    PoseLandmark? rightEl,
  ) {
    if (leftSh == null || rightSh == null) {
      return _Feedback(
          'Muestra ambos hombros y parte del torso',
          _FeedbackLevel.neutral, 0);
    }

    final sw       = _sw(pose);
    final diffNorm = _shoulderDiffNorm(pose);

    // Detectar brazo cruzado (shoulder_cross_stretch)
    if (leftEl != null && rightEl != null) {
      final lCrossed = (leftEl.x - rightSh.x) / sw;
      final rCrossed = (rightEl.x - leftSh.x) / sw;

      if (lCrossed < -0.10 || rCrossed > 0.10) {
        return _Feedback(
            'Brazo cruzado detectado — mantén el estiramiento 20 segundos',
            _FeedbackLevel.good, 90);
      }

      // Detectar brazo elevado sobre la cabeza (triceps_stretch)
      final lAbove = (leftSh.y - leftEl.y) / sw;
      final rAbove = (rightSh.y - rightEl.y) / sw;

      if (lAbove > 0.40 || rAbove > 0.40) {
        return _Feedback(
            'Brazo elevado — empuja suavemente el codo con la otra mano',
            _FeedbackLevel.good, 88);
      }

      // Rotación simétrica (shoulder_rolls)
      final elbowDiffNorm = (leftEl.y - rightEl.y).abs() / sw;
      if (elbowDiffNorm < 0.10 && diffNorm < 0.10) {
        return _Feedback(
            'Movimiento excelente — rotación simétrica perfecta',
            _FeedbackLevel.good, 96);
      }
    }

    if (diffNorm > 0.25) {
      return _Feedback(
          'Un hombro sube más — sincroniza el movimiento',
          _FeedbackLevel.warning, 45);
    }

    if (diffNorm < 0.12) {
      return _Feedback(
          'Buena simetría — completa el movimiento circular completo',
          _FeedbackLevel.good, 82);
    }

    return _Feedback(
        'Mueve ambos hombros juntos — más lento es más efectivo',
        _FeedbackLevel.info, 60);
  }

  _Feedback _analyzeWrists(
    Pose pose,
    PoseLandmark? leftEl,
    PoseLandmark? rightEl,
    PoseLandmark? leftWr,
    PoseLandmark? rightWr,
  ) {
    if (leftEl == null || leftWr == null) {
      return _Feedback(
          'Extiende el brazo hacia la cámara para analizar tu muñeca',
          _FeedbackLevel.neutral, 0);
    }

    final sw = _sw(pose);

    // Longitud del antebrazo normalizada
    final armLenSq = ((leftEl.x - leftWr.x) * (leftEl.x - leftWr.x) +
                      (leftEl.y - leftWr.y) * (leftEl.y - leftWr.y));
    final armNorm = armLenSq / (sw * sw);

    if (armNorm < 0.10) {
      return _Feedback(
          'Extiende más el codo — debe estar casi recto',
          _FeedbackLevel.warning, 40);
    }

    // Flexión de muñeca (dedos hacia abajo)
    final flexNorm = (leftWr.y - leftEl.y) / sw;
    if (flexNorm > 0.10) {
      return _Feedback(
          'Buena flexión de muñeca — jala los dedos hacia ti',
          _FeedbackLevel.good, 88);
    }

    // Extensión (brazo extendido, palma afuera)
    if (armNorm > 0.20) {
      return _Feedback(
          'Brazo bien extendido — jala los dedos suavemente hacia ti',
          _FeedbackLevel.good, 88);
    }

    if (armNorm > 0.12) {
      return _Feedback(
          'Casi perfecto — extiende un poco más el codo',
          _FeedbackLevel.info, 70);
    }

    return _Feedback(
        'Codo muy doblado — estira el brazo completamente',
        _FeedbackLevel.warning, 35);
  }

  _Feedback _analyzeBack(
    Pose pose,
    PoseLandmark? leftSh,
    PoseLandmark? rightSh,
    PoseLandmark? leftHip,
    PoseLandmark? rightHip,
  ) {
    if (leftSh == null || rightSh == null) {
      return _Feedback(
          'Muestra tu torso completo en el encuadre',
          _FeedbackLevel.neutral, 0);
    }

    final sw       = _sw(pose);
    final diffNorm = _shoulderDiffNorm(pose);

    if (leftHip != null && rightHip != null) {
      final hipDiffNorm = (leftHip.y - rightHip.y).abs() / sw;

      // Postura gato: hombros caen hacia adelante
      final shAvgY  = (leftSh.y + rightSh.y) / 2;
      final hipAvgY = (leftHip.y + rightHip.y) / 2;
      final curvNorm = (shAvgY - hipAvgY) / sw;

      if (diffNorm < 0.10 && hipDiffNorm < 0.10) {
        return _Feedback(
            'Alineación perfecta — continúa el movimiento con la respiración',
            _FeedbackLevel.good, 95);
      }
    }

    if (diffNorm < 0.08) {
      return _Feedback(
          'Hombros nivelados — el movimiento viene de la columna',
          _FeedbackLevel.good, 80);
    }

    if (diffNorm < 0.18) {
      return _Feedback(
          'Pequeño desbalance — mantén los hombros a la misma altura',
          _FeedbackLevel.info, 65);
    }

    return _Feedback(
        'Hombros desnivelados — ambos deben partir del mismo nivel',
        _FeedbackLevel.warning, 40);
  }

  _Feedback _generalFeedback(
    Pose pose,
    PoseLandmark? leftSh,
    PoseLandmark? rightSh,
  ) {
    if (leftSh == null || rightSh == null) {
      return _Feedback(
          'Aléjate para que se vea tu torso completo',
          _FeedbackLevel.neutral, 0);
    }

    final diffNorm = _shoulderDiffNorm(pose);

    if (diffNorm < 0.10) {
      return _Feedback(
          'Detectado — realiza el ejercicio con control y sin apresurarte',
          _FeedbackLevel.good, 85);
    }

    return _Feedback(
        'Nivela los hombros para una postura simétrica',
        _FeedbackLevel.info, 60);
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(exerciseByIdProvider(widget.exerciseId)).value?.name ?? 'IA Coach';
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: _buildCurrentState(name)),
    );
  }

  Widget _buildCurrentState(String name) {
    if (_state == _ScreenState.askingPermission) return _buildAskPermission();
    if (_state == _ScreenState.permissionDenied) return _buildPermissionDenied();
    if (_state == _ScreenState.initializing) return _buildInitializing();
    if (_state == _ScreenState.error) return _buildError();
    return _buildActive(name);
  }

  Widget _buildAskPermission() {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
                  onPressed: () => context.pop(),
                ),
              ),
              const Spacer(),
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 1.5),
                ),
                child: const Center(child: Text('📷', style: TextStyle(fontSize: 40))),
              ),
              const SizedBox(height: 28),
              const Text('IA Coach necesita\nacceso a la cámara',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w700, height: 1.3),
                textAlign: TextAlign.center),
              const SizedBox(height: 12),
              const Text(
                'La cámara se usa únicamente para detectar tu postura en tiempo real. Ninguna imagen o video se guarda ni se envía a internet.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 15, height: 1.5),
                textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ...['100% local — nada sale de tu teléfono',
                  'Sin grabación — solo análisis en tiempo real',
                  'Puedes desactivarla en cualquier momento']
                .map((t) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppTheme.accent, size: 16),
                      const SizedBox(width: 8),
                      Text(t, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                )),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _requestPermission,
                  icon: const Icon(Icons.videocam_rounded),
                  label: const Text('Activar cámara'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: () => context.pop(), child: const Text('Usar sin cámara')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🚫', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 20),
              const Text('Permiso denegado',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
              const SizedBox(height: 12),
              const Text('Ve a Ajustes → Aplicaciones → ErgoFit → Permisos → Cámara → Permitir.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center),
              const SizedBox(height: 28),
              ElevatedButton(onPressed: openAppSettings, child: const Text('Abrir ajustes')),
              const SizedBox(height: 12),
              TextButton(onPressed: () => context.pop(), child: const Text('Volver')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitializing() {
    return const Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primary),
            SizedBox(height: 16),
            Text('Iniciando cámara...', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              const Text('No se pudo iniciar la cámara',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Es posible que otro app esté usando la cámara.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center),
              const SizedBox(height: 28),
              ElevatedButton(onPressed: _initCamera, child: const Text('Reintentar')),
              const SizedBox(height: 12),
              TextButton(onPressed: () => context.pop(), child: const Text('Volver')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActive(String name) {
    if (_isGuided && _guidedDone) return _buildCompleted(name);
    final previewSize = _camera!.value.previewSize!;
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_camera!),
        if (_poses.isNotEmpty)
          CustomPaint(
            painter: _SkeletonPainter(
              poses: _poses,
              imageSize: Size(previewSize.height, previewSize.width),
              skeletonColor: _skeletonColor,
            ),
          ),
        const _CornerBrackets(),
        Positioned(top: 0, left: 0, right: 0, child: _buildAppBar(name)),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: _isGuided ? _buildGuidedPanel() : _buildFeedbackPanel(),
        ),
      ],
    );
  }

  Widget _buildAppBar(String name) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(name,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.accentRed, borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Colors.white, size: 8),
                SizedBox(width: 4),
                Text('EN VIVO', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedPanel() {
    final step = _steps![_stepIndex];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter, end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.92), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Paso ${_stepIndex + 1} de ${_steps!.length}',
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_steps!.length, (i) => Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i < _stepIndex ? AppTheme.accent
                       : i == _stepIndex ? AppTheme.primary
                       : Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )),
          ),
          const SizedBox(height: 16),
         Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _feedbackLevel == _FeedbackLevel.good
                    ? AppTheme.accent.withOpacity(0.6)
                    : _guidedState == _GuidedState.explaining
                        ? AppTheme.accentOrange.withOpacity(0.5)
                        : AppTheme.primary.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Indicador de estado
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_guidedState == _GuidedState.explaining) ...[
                      const Icon(Icons.volume_up_rounded,
                          color: AppTheme.accentOrange, size: 14),
                      const SizedBox(width: 6),
                      const Text('Escucha las instrucciones...',
                          style: TextStyle(
                              color: AppTheme.accentOrange,
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                    ] else if (_guidedState == _GuidedState.detecting) ...[
                      const Icon(Icons.accessibility_new_rounded,
                          color: AppTheme.primary, size: 14),
                      const SizedBox(width: 6),
                      const Text('Adopta la postura indicada',
                          style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                    ] else ...[
                      const Icon(Icons.check_circle_rounded,
                          color: AppTheme.accent, size: 14),
                      const SizedBox(width: 6),
                      const Text('¡Postura correcta! Mantén...',
                          style: TextStyle(
                              color: AppTheme.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                // Título del paso
                Text(
                  step.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _guidedState == _GuidedState.explaining
                        ? AppTheme.accentOrange
                        : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                // Barra de progreso (solo visible durante hold)
                if (_guidedState != _GuidedState.explaining) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _holdProgress,
                      minHeight: 8,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation(
                        _holdProgress > 0
                            ? AppTheme.accent
                            : AppTheme.primary,
                      ),
                    ),
                  ),
                  if (_holdProgress > 0 && _countdownSeconds > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer_outlined,
                            color: AppTheme.accent, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '$_countdownSeconds seg',
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
                const SizedBox(height: 10),
                // Instrucción
                Text(
                  _feedbackText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _skipStep,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white30),
                  ),
                  child: const Text('Saltar paso'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white30),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Salir'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackPanel() {
    Color panelColor;
    IconData icon;
    if (_feedbackLevel == _FeedbackLevel.good) {
      panelColor = AppTheme.accent;
      icon = Icons.check_circle_rounded;
    } else if (_feedbackLevel == _FeedbackLevel.warning) {
      panelColor = AppTheme.accentOrange;
      icon = Icons.warning_amber_rounded;
    } else if (_feedbackLevel == _FeedbackLevel.info) {
      panelColor = AppTheme.primary;
      icon = Icons.info_outline_rounded;
    } else {
      panelColor = AppTheme.textHint;
      icon = Icons.smart_toy_rounded;
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter, end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.9), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_poseScore > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Puntuación: ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('$_poseScore / 100',
                    style: TextStyle(color: panelColor, fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: panelColor.withOpacity(0.5), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.smart_toy_rounded, color: AppTheme.primary, size: 20),
                const SizedBox(width: 4),
                const Text('IA Coach',
                  style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Container(width: 0.5, height: 16, color: Colors.white24),
                const SizedBox(width: 8),
                Icon(icon, color: panelColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_feedbackText,
                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white30),
              ),
              icon: const Icon(Icons.videocam_off_rounded, size: 18),
              label: const Text('Terminar sesión IA'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleted(String name) {
    return Container(
      color: AppTheme.bgPrimary,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accent.withOpacity(0.4), width: 2),
                ),
                child: const Center(child: Text('🎉', style: TextStyle(fontSize: 44))),
              ),
              const SizedBox(height: 24),
              const Text('¡Ejercicio guiado\ncompletado!',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w700, height: 1.3),
                textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('La IA verificó cada paso de "$name"',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8, runSpacing: 8,
                alignment: WrapAlignment.center,
                children: (_steps ?? []).asMap().entries.map((e) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_rounded, color: AppTheme.accent, size: 14),
                      const SizedBox(width: 4),
                      Text(e.value.title.split(' ').take(2).join(' '),
                        style: const TextStyle(color: AppTheme.accent, fontSize: 11)),
                    ],
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.3), width: 0.5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: AppTheme.accent, size: 16),
                    SizedBox(width: 6),
                    Text('Sesión guardada en estadísticas',
                      style: TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Volver al ejercicio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Skeleton Painter ──────────────────────────────────────────────────────────

class _SkeletonPainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final Color skeletonColor;

  _SkeletonPainter({
    required this.poses,
    required this.imageSize,
    required this.skeletonColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (poses.isEmpty) return;
    final pose = poses.first;

    Offset scale(PoseLandmark lm) => Offset(
      (1 - lm.x / imageSize.width) * size.width,
      (lm.y / imageSize.height) * size.height,
    );

    final bonePaint = Paint()
      ..color = skeletonColor.withOpacity(0.7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final jointPaint = Paint()
      ..color = skeletonColor
      ..style = PaintingStyle.fill;

    const connections = [
      [PoseLandmarkType.nose, PoseLandmarkType.leftShoulder],
      [PoseLandmarkType.nose, PoseLandmarkType.rightShoulder],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
      [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
      [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
    ];

    for (final conn in connections) {
      final a = pose.landmarks[conn[0]];
      final b = pose.landmarks[conn[1]];
      if (a == null || b == null || a.likelihood < 0.3 || b.likelihood < 0.3) continue;
      canvas.drawLine(scale(a), scale(b), bonePaint);
    }

    // ── T invertida: nariz → centro hombros ───────────────────────────────────
    final tLeftSh  = pose.landmarks[PoseLandmarkType.leftShoulder];
    final tRightSh = pose.landmarks[PoseLandmarkType.rightShoulder];
    final tNose    = pose.landmarks[PoseLandmarkType.nose];

    if (tLeftSh != null && tRightSh != null && tNose != null &&
        tLeftSh.likelihood > 0.3 && tRightSh.likelihood > 0.3 && tNose.likelihood > 0.3) {

      final midShX = (tLeftSh.x + tRightSh.x) / 2;
      final midShY = (tLeftSh.y + tRightSh.y) / 2;
      final midShoulder = Offset(
        (1 - midShX / imageSize.width) * size.width,
        (midShY / imageSize.height) * size.height,
      );
      final nosePos = scale(tNose);

      canvas.drawLine(nosePos, midShoulder, bonePaint);
      canvas.drawCircle(midShoulder, 6, Paint()
        ..color = skeletonColor
        ..style = PaintingStyle.fill);
      canvas.drawCircle(midShoulder, 6, Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);

      // ── Eje central: centro hombros → centro caderas ─────────────────────────
      final axisLeftHip  = pose.landmarks[PoseLandmarkType.leftHip];
      final axisRightHip = pose.landmarks[PoseLandmarkType.rightHip];

      if (axisLeftHip != null && axisRightHip != null &&
          axisLeftHip.likelihood > 0.3 && axisRightHip.likelihood > 0.3) {

        final midHipX = (axisLeftHip.x + axisRightHip.x) / 2;
        final midHipY = (axisLeftHip.y + axisRightHip.y) / 2;
        final midHip  = Offset(
          (1 - midHipX / imageSize.width) * size.width,
          (midHipY / imageSize.height) * size.height,
        );

        final axisPaint = Paint()
          ..color      = skeletonColor.withOpacity(0.5)
          ..strokeWidth = 1.5
          ..style      = PaintingStyle.stroke
          ..strokeCap  = StrokeCap.round;

        // Línea centro hombros → centro caderas
        canvas.drawLine(midShoulder, midHip, axisPaint);

        // Punto en centro caderas
        canvas.drawCircle(midHip, 5, Paint()
          ..color = skeletonColor
          ..style = PaintingStyle.fill);

        // Línea de referencia vertical punteada
        final referencePaint = Paint()
          ..color      = Colors.white.withOpacity(0.15)
          ..strokeWidth = 1.0
          ..style      = PaintingStyle.stroke;

        const dashH = 6.0;
        const dashS = 4.0;
        double startY = nosePos.dy;
        final endY    = midHip.dy;
        final refX    = midShoulder.dx;

        while (startY < endY) {
          canvas.drawLine(
            Offset(refX, startY),
            Offset(refX, (startY + dashH).clamp(startY, endY)),
            referencePaint,
          );
          startY += dashH + dashS;
        }

        // Curva de Bezier si hay desviación del eje
        final deviation = (midShoulder.dx - midHip.dx).abs();
        if (deviation > 15) {
          final curvePaint = Paint()
            ..color      = skeletonColor.withOpacity(0.6)
            ..strokeWidth = 2.0
            ..style      = PaintingStyle.stroke;
          final path = Path()
            ..moveTo(nosePos.dx, nosePos.dy)
            ..quadraticBezierTo(
              midShoulder.dx, midShoulder.dy,
              midHip.dx, midHip.dy,
            );
          canvas.drawPath(path, curvePaint);
        }
      }
    }

    // ── Joints ────────────────────────────────────────────────────────────────
    for (final lm in pose.landmarks.values) {
      if (lm.likelihood < 0.3) continue;
      final pos = scale(lm);
      canvas.drawCircle(pos, 5, jointPaint);
      canvas.drawCircle(pos, 5, Paint()
        ..color      = Colors.white.withOpacity(0.4)
        ..style      = PaintingStyle.stroke
        ..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(_SkeletonPainter old) =>
      old.poses != poses || old.skeletonColor != skeletonColor;
}

// ── Corner Brackets ───────────────────────────────────────────────────────────

class _CornerBrackets extends StatelessWidget {
  const _CornerBrackets();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Align(alignment: Alignment.topLeft,     child: _Bracket(tl: true)),
          Align(alignment: Alignment.topRight,    child: _Bracket(tr: true)),
          Align(alignment: Alignment.bottomLeft,  child: _Bracket(bl: true)),
          Align(alignment: Alignment.bottomRight, child: _Bracket(br: true)),
        ],
      ),
    );
  }
}

class _Bracket extends StatelessWidget {
  final bool tl, tr, bl, br;
  const _Bracket({this.tl=false, this.tr=false, this.bl=false, this.br=false});

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(28, 28),
    painter: _BracketPainter(tl: tl, tr: tr, bl: bl, br: br),
  );
}

class _BracketPainter extends CustomPainter {
  final bool tl, tr, bl, br;
  _BracketPainter({this.tl=false, this.tr=false, this.bl=false, this.br=false});

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    if (tl) { canvas.drawLine(Offset(0,s.height), Offset(0,0), p); canvas.drawLine(Offset(0,0), Offset(s.width,0), p); }
    if (tr) { canvas.drawLine(Offset(0,0), Offset(s.width,0), p); canvas.drawLine(Offset(s.width,0), Offset(s.width,s.height), p); }
    if (bl) { canvas.drawLine(Offset(0,0), Offset(0,s.height), p); canvas.drawLine(Offset(0,s.height), Offset(s.width,s.height), p); }
    if (br) { canvas.drawLine(Offset(s.width,0), Offset(s.width,s.height), p); canvas.drawLine(Offset(s.width,s.height), Offset(0,s.height), p); }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Modelos ───────────────────────────────────────────────────────────────────

enum _ScreenState { askingPermission, permissionDenied, initializing, active, error }
enum _FeedbackLevel { good, warning, info, neutral }
enum _GuidedState { explaining, detecting, holding }

class _Feedback {
  final String text;
  final _FeedbackLevel level;
  final int score;
  const _Feedback(this.text, this.level, this.score);
}