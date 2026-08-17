import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class GuidedStep {
  final String title;
  final String instruction;
  final double holdSeconds;
  final bool Function(Pose pose, Map<String, double?> calibration) check;

  const GuidedStep({
    required this.title,
    required this.instruction,
    required this.holdSeconds,
    required this.check,
  });
}

List<GuidedStep>? getGuidedSteps(String exerciseId) {
  return switch (exerciseId) {
    'shoulder_rolls'          => _shoulderRolls(),
    'neck_lateral_tilt'       => _neckLateralTilt(),
    'neck_rotation'           => _neckRotation(),
    'neck_chin_tuck'          => _neckChinTuck(),
    'neck_flexion'            => _neckFlexion(),
    'chest_opener'            => _chestOpener(),
    'back_cat_cow'            => _backCatCow(),
    'wrist_extension_stretch' => _wristExtension(),
    _                         => null,
  };
}

// ══════════════════════════════════════════════════════════════════════════════
//  HELPERS NORMALIZADOS
//  Todos los umbrales son proporciones del ancho de hombros (shoulderWidth).
//  Esto hace que el algoritmo sea independiente de la distancia a la cámara.
// ══════════════════════════════════════════════════════════════════════════════

PoseLandmark? _ls(Pose p) => p.landmarks[PoseLandmarkType.leftShoulder];
PoseLandmark? _rs(Pose p) => p.landmarks[PoseLandmarkType.rightShoulder];
PoseLandmark? _nose(Pose p) => p.landmarks[PoseLandmarkType.nose];
PoseLandmark? _le(Pose p) => p.landmarks[PoseLandmarkType.leftElbow];
PoseLandmark? _re(Pose p) => p.landmarks[PoseLandmarkType.rightElbow];
PoseLandmark? _lw(Pose p) => p.landmarks[PoseLandmarkType.leftWrist];
PoseLandmark? _rw(Pose p) => p.landmarks[PoseLandmarkType.rightWrist];
PoseLandmark? _lh(Pose p) => p.landmarks[PoseLandmarkType.leftHip];
PoseLandmark? _rh(Pose p) => p.landmarks[PoseLandmarkType.rightHip];
PoseLandmark? _lear(Pose p) => p.landmarks[PoseLandmarkType.leftEar];
PoseLandmark? _rear(Pose p) => p.landmarks[PoseLandmarkType.rightEar];

/// Ancho entre hombros en píxeles. Es nuestra unidad de referencia.
double _sw(Pose p) {
  final l = _ls(p); final r = _rs(p);
  if (l == null || r == null) return 1;
  return (l.x - r.x).abs().clamp(1.0, double.infinity);
}

/// Diferencia vertical entre hombros, normalizada por ancho de hombros.
/// < 0.10 = hombros muy nivelados
/// < 0.20 = hombros aceptablemente nivelados
/// > 0.30 = hombros muy desnivelados
double _shoulderDiffNorm(Pose p) {
  final l = _ls(p); final r = _rs(p);
  if (l == null || r == null) return 999;
  return (l.y - r.y).abs() / _sw(p);
}

/// Altura promedio de los hombros en píxeles (Y crece hacia abajo).
double _avgShoulderY(Pose p) {
  final l = _ls(p); final r = _rs(p);
  if (l == null || r == null) return 0;
  return (l.y + r.y) / 2;
}

/// Desplazamiento horizontal de la nariz desde el centro de hombros,
/// normalizado por ancho de hombros.
/// 0.0 = cabeza centrada
/// 0.20+ = inclinación lateral visible
/// 0.35+ = buena inclinación lateral
double _noseOffsetNorm(Pose p) {
  final n = _nose(p); final l = _ls(p); final r = _rs(p);
  if (n == null || l == null || r == null) return 999;
  final centerX = (l.x + r.x) / 2;
  return (n.x - centerX).abs() / _sw(p);
}

// ══════════════════════════════════════════════════════════════════════════════
//  SHOULDER ROLLS — normalizado por ancho de hombros
// ══════════════════════════════════════════════════════════════════════════════

List<GuidedStep> _shoulderRolls() => [
  GuidedStep(
    title: 'Posición inicial',
    instruction: 'Siéntate erguido con los hombros relajados a los costados. '
        'Mira al frente. Mantén esta posición.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final l = _ls(pose); final r = _rs(pose);
      if (l == null || r == null) return false;
      // Calibrar baseline Y y ancho de hombros
      cal['baseY'] = _avgShoulderY(pose);
      cal['sw']    = _sw(pose);
      // Hombros nivelados: diferencia < 20% del ancho
      return _shoulderDiffNorm(pose) < 0.20;
    },
  ),
  GuidedStep(
    title: 'Eleva los hombros',
    instruction: 'Sube ambos hombros hacia las orejas. '
        'Mantén la posición elevada.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final baseY = cal['baseY']; final sw = cal['sw'];
      if (baseY == null || sw == null) return false;
      // Elevación mínima: 15% del ancho de hombros hacia arriba
      final elevNorm = (baseY - _avgShoulderY(pose)) / sw;
      return elevNorm > 0.15 && _shoulderDiffNorm(pose) < 0.25;
    },
  ),
  GuidedStep(
    title: 'Hombros atrás y abajo',
    instruction: 'Lleva los hombros hacia atrás y abajo completando el círculo. '
        'Intenta unir los omóplatos.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final baseY = cal['baseY']; final sw = cal['sw'];
      if (baseY == null || sw == null) return false;
      // Regreso al nivel base: diferencia < 8% del ancho
      final diffFromBase = (_avgShoulderY(pose) - baseY).abs() / sw;
      return diffFromBase < 0.08 && _shoulderDiffNorm(pose) < 0.25;
    },
  ),
  GuidedStep(
    title: 'Segunda elevación',
    instruction: 'Vuelve a subir los hombros hacia las orejas. '
        'Segundo ciclo — mantén la posición.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final baseY = cal['baseY']; final sw = cal['sw'];
      if (baseY == null || sw == null) return false;
      final elevNorm = (baseY - _avgShoulderY(pose)) / sw;
      return elevNorm > 0.15 && _shoulderDiffNorm(pose) < 0.25;
    },
  ),
  GuidedStep(
    title: 'Cierre del segundo ciclo',
    instruction: 'Lleva los hombros hacia atrás y abajo por segunda vez. '
        'Respira profundo al bajar.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final baseY = cal['baseY']; final sw = cal['sw'];
      if (baseY == null || sw == null) return false;
      final diffFromBase = (_avgShoulderY(pose) - baseY).abs() / sw;
      return diffFromBase < 0.08 && _shoulderDiffNorm(pose) < 0.25;
    },
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
//  NECK LATERAL TILT — normalizado
// ══════════════════════════════════════════════════════════════════════════════

List<GuidedStep> _neckLateralTilt() => [
  GuidedStep(
    title: 'Posición inicial',
    instruction: 'Siéntate erguido. Relaja los hombros. '
        'Mira al frente con la barbilla paralela al suelo.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final l = _ls(pose); final r = _rs(pose); final n = _nose(pose);
      if (l == null || r == null || n == null) return false;
      cal['baseY']   = _avgShoulderY(pose);
      cal['centerX'] = (l.x + r.x) / 2;
      cal['sw']      = _sw(pose);
      // Cabeza centrada: desplazamiento < 15% del ancho de hombros
      return _shoulderDiffNorm(pose) < 0.20 && _noseOffsetNorm(pose) < 0.15;
    },
  ),
  GuidedStep(
    title: 'Inclina hacia la derecha',
    instruction: 'Lleva la oreja derecha hacia el hombro derecho. '
        'No levantes el hombro. Mantén 20 segundos.',
    holdSeconds: 20.0,
    check: (pose, cal) {
      final n = _nose(pose); final center = cal['centerX']; final sw = cal['sw'];
      if (n == null || center == null || sw == null) return false;
      // Desplazamiento lateral > 25% del ancho de hombros
      final offset = (center - n.x) / sw;
      return offset > 0.25 && _shoulderDiffNorm(pose) < 0.25;
    },
  ),
  GuidedStep(
    title: 'Vuelve al centro',
    instruction: 'Regresa la cabeza al centro lentamente. '
        'Inhala profundo.',
    holdSeconds: 3.0,
    check: (pose, cal) =>
        _noseOffsetNorm(pose) < 0.15 && _shoulderDiffNorm(pose) < 0.25,
  ),
  GuidedStep(
    title: 'Inclina hacia la izquierda',
    instruction: 'Lleva la oreja izquierda hacia el hombro izquierdo. '
        'Mantén 20 segundos.',
    holdSeconds: 20.0,
    check: (pose, cal) {
      final n = _nose(pose); final center = cal['centerX']; final sw = cal['sw'];
      if (n == null || center == null || sw == null) return false;
      final offset = (n.x - center) / sw;
      return offset > 0.25 && _shoulderDiffNorm(pose) < 0.25;
    },
  ),
  GuidedStep(
    title: 'Posición final',
    instruction: 'Regresa al centro lentamente. '
        'Ejercicio completado correctamente.',
    holdSeconds: 3.0,
    check: (pose, cal) =>
        _noseOffsetNorm(pose) < 0.15 && _shoulderDiffNorm(pose) < 0.25,
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
//  NECK ROTATION — normalizado
// ══════════════════════════════════════════════════════════════════════════════

List<GuidedStep> _neckRotation() => [
  GuidedStep(
    title: 'Posición inicial',
    instruction: 'Siéntate erguido. Barbilla paralela al suelo. '
        'Hombros quietos y relajados. Mira al frente.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final n    = _nose(pose);
      final lear = _lear(pose);
      final rear = _rear(pose);
      final l    = _ls(pose); final r = _rs(pose);
      if (n == null || lear == null || rear == null || l == null || r == null) return false;
      cal['sw']       = _sw(pose);
      cal['centerX']  = (l.x + r.x) / 2;
      // Distancia nariz a cada oreja normalizada
      final distLeft  = (n.x - lear.x).abs();
      final distRight = (n.x - rear.x).abs();
      cal['distLeft']  = distLeft;
      cal['distRight'] = distRight;
      // Cabeza centrada: ambas distancias similares (diferencia < 20% del ancho)
      final ratio = (distLeft - distRight).abs() / _sw(pose);
      return ratio < 0.20 && _shoulderDiffNorm(pose) < 0.20;
    },
  ),
  GuidedStep(
    title: 'Gira a la derecha',
    instruction: 'Gira la cabeza despacio hacia tu hombro derecho '
        'hasta donde sea cómodo. Mantén 15 segundos.',
    holdSeconds: 15.0,
    check: (pose, cal) {
      final n    = _nose(pose);
      final rear = _rear(pose);
      final lear = _lear(pose);
      if (n == null || rear == null || lear == null) return false;
      final sw = cal['sw'] ?? 1.0;
      // Al girar a la derecha: oreja derecha se acerca a la nariz,
      // oreja izquierda se aleja. La diferencia debe ser > 25% del ancho.
      final distRight = (n.x - rear.x).abs();
      final distLeft  = (n.x - lear.x).abs();
      final asymmetry = (distLeft - distRight) / sw;
      return asymmetry > 0.25 && _shoulderDiffNorm(pose) < 0.25;
    },
  ),
  GuidedStep(
    title: 'Vuelve al centro',
    instruction: 'Regresa al centro con calma. Respira profundo.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final n    = _nose(pose);
      final lear = _lear(pose);
      final rear = _rear(pose);
      if (n == null || lear == null || rear == null) return false;
      final sw = cal['sw'] ?? 1.0;
      final distLeft  = (n.x - lear.x).abs();
      final distRight = (n.x - rear.x).abs();
      final ratio = (distLeft - distRight).abs() / sw;
      return ratio < 0.20;
    },
  ),
  GuidedStep(
    title: 'Gira a la izquierda',
    instruction: 'Gira la cabeza hacia tu hombro izquierdo. '
        'Mantén 15 segundos.',
    holdSeconds: 15.0,
    check: (pose, cal) {
      final n    = _nose(pose);
      final rear = _rear(pose);
      final lear = _lear(pose);
      if (n == null || rear == null || lear == null) return false;
      final sw = cal['sw'] ?? 1.0;
      // Al girar a la izquierda: oreja izquierda se acerca,
      // oreja derecha se aleja.
      final distRight = (n.x - rear.x).abs();
      final distLeft  = (n.x - lear.x).abs();
      final asymmetry = (distRight - distLeft) / sw;
      return asymmetry > 0.25 && _shoulderDiffNorm(pose) < 0.25;
    },
  ),
  GuidedStep(
    title: 'Posición final',
    instruction: 'Vuelve al centro. Baja suavemente la barbilla '
        'hacia el pecho por 3 segundos para cerrar.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final n    = _nose(pose);
      final lear = _lear(pose);
      final rear = _rear(pose);
      if (n == null || lear == null || rear == null) return false;
      final sw = cal['sw'] ?? 1.0;
      final distLeft  = (n.x - lear.x).abs();
      final distRight = (n.x - rear.x).abs();
      final ratio = (distLeft - distRight).abs() / sw;
      return ratio < 0.20;
    },
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
//  NECK CHIN TUCK — normalizado
// ══════════════════════════════════════════════════════════════════════════════

List<GuidedStep> _neckChinTuck() => [
  GuidedStep(
    title: 'Posición inicial',
    instruction: 'Siéntate mirando al frente con los hombros relajados. '
        'Elige un punto fijo a la altura de los ojos.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final n = _nose(pose); final l = _ls(pose); final r = _rs(pose);
      if (n == null || l == null || r == null) return false;
      cal['noseY']   = n.y;
      cal['centerX'] = (l.x + r.x) / 2;
      cal['sw']      = _sw(pose);
      return _shoulderDiffNorm(pose) < 0.20 && _noseOffsetNorm(pose) < 0.20;
    },
  ),
  GuidedStep(
    title: 'Primera retracción — 5 seg',
    instruction: 'Sin bajar la cabeza, lleva el mentón hacia atrás '
        'como haciendo doble papada. Mantén 5 segundos.',
    holdSeconds: 5.0,
    check: (pose, cal) =>
        _noseOffsetNorm(pose) < 0.20 && _shoulderDiffNorm(pose) < 0.25,
  ),
  GuidedStep(
    title: 'Suelta',
    instruction: 'Regresa a la posición normal. '
        'Prepárate para la segunda retracción.',
    holdSeconds: 2.0,
    check: (pose, cal) =>
        _shoulderDiffNorm(pose) < 0.25 && _noseOffsetNorm(pose) < 0.20,
  ),
  GuidedStep(
    title: 'Segunda retracción — 5 seg',
    instruction: 'Vuelve a llevar el mentón hacia atrás. '
        'Mantén 5 segundos más.',
    holdSeconds: 5.0,
    check: (pose, cal) =>
        _noseOffsetNorm(pose) < 0.20 && _shoulderDiffNorm(pose) < 0.25,
  ),
  GuidedStep(
    title: 'Tercera retracción — 5 seg',
    instruction: 'Una última retracción. Mantén 5 segundos. '
        'Cada repetición fortalece los músculos cervicales.',
    holdSeconds: 5.0,
    check: (pose, cal) =>
        _noseOffsetNorm(pose) < 0.20 && _shoulderDiffNorm(pose) < 0.25,
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
//  NECK FLEXION — normalizado
// ══════════════════════════════════════════════════════════════════════════════

List<GuidedStep> _neckFlexion() => [
  GuidedStep(
    title: 'Posición inicial',
    instruction: 'Siéntate erguido mirando al frente. '
        'Relaja los hombros. Barbilla paralela al suelo.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final n = _nose(pose); final l = _ls(pose); final r = _rs(pose);
      if (n == null || l == null || r == null) return false;
      cal['noseY'] = n.y;
      cal['sw']    = _sw(pose);
      return _shoulderDiffNorm(pose) < 0.20 && _noseOffsetNorm(pose) < 0.20;
    },
  ),
  GuidedStep(
    title: 'Baja el mentón',
    instruction: 'Baja lentamente el mentón hacia el pecho. '
        'La gravedad hace el trabajo.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final n = _nose(pose); final baseY = cal['noseY']; final sw = cal['sw'];
      if (n == null || baseY == null || sw == null) return false;
      // Nariz baja > 15% del ancho de hombros
      final dropNorm = (n.y - baseY) / sw;
      return dropNorm > 0.15 && _shoulderDiffNorm(pose) < 0.25;
    },
  ),
  GuidedStep(
    title: 'Mantén 20 segundos',
    instruction: 'Mentón hacia el pecho. Respira profundo y siente '
        'el estiramiento en la nuca. Mantén 20 segundos.',
    holdSeconds: 20.0,
    check: (pose, cal) {
      final n = _nose(pose); final baseY = cal['noseY']; final sw = cal['sw'];
      if (n == null || baseY == null || sw == null) return false;
      final dropNorm = (n.y - baseY) / sw;
      return dropNorm > 0.15 && _shoulderDiffNorm(pose) < 0.25;
    },
  ),
  GuidedStep(
    title: 'Regresa al centro',
    instruction: 'Sube la cabeza lentamente. Haz una pausa.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final n = _nose(pose); final baseY = cal['noseY']; final sw = cal['sw'];
      if (n == null || baseY == null || sw == null) return false;
      final diffNorm = (n.y - baseY).abs() / sw;
      return diffNorm < 0.10 && _shoulderDiffNorm(pose) < 0.25;
    },
  ),
  GuidedStep(
    title: 'Segunda flexión — 20 seg',
    instruction: 'Vuelve a bajar el mentón hacia el pecho. '
        'Mantén otros 20 segundos respirando profundo.',
    holdSeconds: 20.0,
    check: (pose, cal) {
      final n = _nose(pose); final baseY = cal['noseY']; final sw = cal['sw'];
      if (n == null || baseY == null || sw == null) return false;
      final dropNorm = (n.y - baseY) / sw;
      return dropNorm > 0.15 && _shoulderDiffNorm(pose) < 0.25;
    },
  ),
  GuidedStep(
    title: 'Posición final',
    instruction: 'Regresa al centro lentamente. '
        'Barbilla paralela al suelo.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final n = _nose(pose); final baseY = cal['noseY']; final sw = cal['sw'];
      if (n == null || baseY == null || sw == null) return false;
      final diffNorm = (n.y - baseY).abs() / sw;
      return diffNorm < 0.10 && _shoulderDiffNorm(pose) < 0.25;
    },
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
//  CHEST OPENER 
// ══════════════════════════════════════════════════════════════════════════════

List<GuidedStep> _chestOpener() => [
  GuidedStep(
    title: 'Posición inicial',
    instruction: 'Siéntate al borde de la silla. '
        'Pies planos en el suelo. Espalda recta. '
        'Brazos relajados a los costados.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final l = _ls(pose); final r = _rs(pose);
      if (l == null || r == null) return false;
      cal['baseY'] = (l.y + r.y) / 2;
      cal['sw']    = _sw(pose);
      // Hombros nivelados y brazos abajo
      final le = _le(pose); final re = _re(pose);
      if (le == null || re == null) return false;
      // Codos deben estar por debajo de los hombros
      final lElbowBelow = le.y > l.y;
      final rElbowBelow = re.y > r.y;
      return _shoulderDiffNorm(pose) < 0.20 && lElbowBelow && rElbowBelow;
    },
  ),
  GuidedStep(
    title: 'Lleva las manos detrás de la espalda',
    instruction: 'Lleva ambas manos detrás de la espalda baja '
        'y entrelaza los dedos. Los codos apuntan hacia afuera.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final le = _le(pose); final re = _re(pose);
      final lw = _lw(pose); final rw = _rw(pose);
      final l  = _ls(pose); final r  = _rs(pose);
      if (le == null || re == null || lw == null || rw == null ||
          l == null || r == null) return false;
      final sw = cal['sw'] ?? _sw(pose);
      // Muñecas deben estar detrás del cuerpo (más abajo que los hombros)
      // y codos apuntan hacia afuera (más separados que hombros)
      final wristsBelow  = lw.y > l.y && rw.y > r.y;
      final elbowWidth   = (le.x - re.x).abs();
      final shoulderWidth = sw;
      final elbowsWide   = elbowWidth > shoulderWidth * 0.60;
      return wristsBelow && elbowsWide && _shoulderDiffNorm(pose) < 0.25;
    },
  ),
  GuidedStep(
    title: 'Abre el pecho — lleva hombros atrás',
    instruction: 'Inhala y lleva los hombros hacia atrás. '
        'El pecho se abre hacia adelante. '
        'Los brazos entrelazados bajan hacia el suelo.',
    holdSeconds: 5.0,
    check: (pose, cal) {
      final le = _le(pose); final re = _re(pose);
      final lw = _lw(pose); final rw = _rw(pose);
      final l  = _ls(pose); final r  = _rs(pose);
      if (le == null || re == null || lw == null || rw == null ||
          l == null || r == null) return false;
      final sw         = cal['sw'] ?? _sw(pose);
      final baseY      = cal['baseY'] ?? (l.y + r.y) / 2;
      // Muñecas bien abajo (> 30% del ancho de hombros por debajo de hombros)
      final lWristBelow = (lw.y - l.y) / sw > 0.30;
      final rWristBelow = (rw.y - r.y) / sw > 0.30;
      // Codos apuntan hacia afuera (> 60% del ancho de hombros)
      final elbowWidth  = (le.x - re.x).abs();
      final elbowsWide  = elbowWidth / sw > 0.60;
      // Hombros nivelados
      final shouldersOk = _shoulderDiffNorm(pose) < 0.25;
      return lWristBelow && rWristBelow && elbowsWide && shouldersOk;
    },
  ),
  GuidedStep(
    title: 'Mantén 20 segundos',
    instruction: 'Mantén el pecho abierto y los hombros atrás. '
        'Con cada inhalación abre más. Mantén 20 segundos.',
    holdSeconds: 20.0,
    check: (pose, cal) {
      final le = _le(pose); final re = _re(pose);
      final lw = _lw(pose); final rw = _rw(pose);
      final l  = _ls(pose); final r  = _rs(pose);
      if (le == null || re == null || lw == null || rw == null ||
          l == null || r == null) return false;
      final sw          = cal['sw'] ?? _sw(pose);
      final lWristBelow = (lw.y - l.y) / sw > 0.30;
      final rWristBelow = (rw.y - r.y) / sw > 0.30;
      final elbowWidth  = (le.x - re.x).abs();
      final elbowsWide  = elbowWidth / sw > 0.60;
      return lWristBelow && rWristBelow && elbowsWide;
    },
  ),
 GuidedStep(
    title: 'Baja los brazos',
    instruction: 'Suelta los dedos y baja los brazos lentamente '
        'a los costados. Respira profundo.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final l = _ls(pose); final r = _rs(pose);
      if (l == null || r == null) return false;
      // Solo verificamos que el usuario sigue en encuadre
      // con hombros visibles y razonablemente nivelados
      return _shoulderDiffNorm(pose) < 0.30;
    },
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
//  BACK CAT COW
// ══════════════════════════════════════════════════════════════════════════════

List<GuidedStep> _backCatCow() => [
  GuidedStep(
    title: 'Posición neutral',
    instruction: 'Siéntate al borde de la silla con los pies planos '
        'en el suelo. Manos sobre las rodillas. '
        'Espalda en posición neutral.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final l = _ls(pose); final r = _rs(pose);
      if (l == null || r == null) return false;
      cal['shoulderY'] = (l.y + r.y) / 2;
      cal['sw']        = _sw(pose);
      cal['swBase']    = _sw(pose);
      return _shoulderDiffNorm(pose) < 0.20;
    },
  ),
  GuidedStep(
    title: 'Posición VACA',
    instruction: 'Inhala profundo y arquea la espalda hacia adelante. '
        'Saca el pecho y lleva los hombros hacia atrás y arriba. '
        'La pelvis se inclina hacia adelante.',
    holdSeconds: 4.0,
    check: (pose, cal) {
      final l = _ls(pose); final r = _rs(pose);
      if (l == null || r == null) return false;
      final baseY  = cal['shoulderY'] ?? (l.y + r.y) / 2;
      final swBase = cal['swBase']    ?? _sw(pose);
      final sw     = cal['sw']        ?? _sw(pose);

      // En posición vaca:
      // 1. Hombros suben (Y disminuye) > 8% del ancho base
      final elevNorm = (baseY - (l.y + r.y) / 2) / swBase;

      // 2. Hombros se abren un poco más (ancho aumenta)
      final openNorm = (_sw(pose) - swBase) / swBase;

      // Cualquiera de los dos indicadores válido
      return (elevNorm > 0.08 || openNorm > 0.05) &&
             _shoulderDiffNorm(pose) < 0.25;
    },
  ),
  GuidedStep(
    title: 'Posición GATO',
    instruction: 'Exhala completamente y redondea la espalda. '
        'Mete el ombligo hacia adentro. '
        'Los hombros caen hacia adelante y se acercan entre sí.',
    holdSeconds: 4.0,
    check: (pose, cal) {
      final l = _ls(pose); final r = _rs(pose);
      if (l == null || r == null) return false;
      final baseY  = cal['shoulderY'] ?? (l.y + r.y) / 2;
      final swBase = cal['swBase']    ?? _sw(pose);

      // En posición gato:
      // 1. Hombros bajan (Y aumenta) > 8% del ancho base
      final dropNorm = ((l.y + r.y) / 2 - baseY) / swBase;

      // 2. Hombros se cierran (ancho disminuye)
      final closeNorm = (swBase - _sw(pose)) / swBase;

      return (dropNorm > 0.08 || closeNorm > 0.05) &&
             _shoulderDiffNorm(pose) < 0.25;
    },
  ),
  GuidedStep(
    title: 'VACA — segundo ciclo',
    instruction: 'Inhala de nuevo y arquea la espalda. '
        'Lleva el pecho hacia adelante y los hombros hacia atrás.',
    holdSeconds: 4.0,
    check: (pose, cal) {
      final l = _ls(pose); final r = _rs(pose);
      if (l == null || r == null) return false;
      final baseY  = cal['shoulderY'] ?? (l.y + r.y) / 2;
      final swBase = cal['swBase']    ?? _sw(pose);
      final elevNorm = (baseY - (l.y + r.y) / 2) / swBase;
      final openNorm = (_sw(pose) - swBase) / swBase;
      return (elevNorm > 0.08 || openNorm > 0.05) &&
             _shoulderDiffNorm(pose) < 0.25;
    },
  ),
  GuidedStep(
    title: 'GATO — segundo ciclo',
    instruction: 'Exhala y redondea la espalda por última vez. '
        'Siente el estiramiento en toda la columna.',
    holdSeconds: 4.0,
    check: (pose, cal) {
      final l = _ls(pose); final r = _rs(pose);
      if (l == null || r == null) return false;
      final baseY  = cal['shoulderY'] ?? (l.y + r.y) / 2;
      final swBase = cal['swBase']    ?? _sw(pose);
      final dropNorm  = ((l.y + r.y) / 2 - baseY) / swBase;
      final closeNorm = (swBase - _sw(pose)) / swBase;
      return (dropNorm > 0.08 || closeNorm > 0.05) &&
             _shoulderDiffNorm(pose) < 0.25;
    },
  ),
  GuidedStep(
    title: 'Posición neutral final',
    instruction: 'Regresa a la posición neutral. '
        'Respira profundo y siente tu columna más libre.',
    holdSeconds: 3.0,
    check: (pose, cal) => _shoulderDiffNorm(pose) < 0.25,
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
//  WRIST EXTENSION STRETCH
// ══════════════════════════════════════════════════════════════════════════════

List<GuidedStep> _wristExtension() => [
  GuidedStep(
    title: 'Posición inicial',
    instruction: 'Siéntate erguido. Extiende el brazo derecho '
        'hacia adelante paralelo al suelo.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final le = _le(pose); final lw = _lw(pose);
      final l  = _ls(pose); final r  = _rs(pose);
      if (le == null || lw == null || l == null || r == null) return false;
      // Longitud del antebrazo normalizada por ancho de hombros
      final armLen = ((le.x - lw.x) * (le.x - lw.x) +
                      (le.y - lw.y) * (le.y - lw.y));
      cal['armLen'] = armLen;
      cal['sw']     = _sw(pose);
      // Brazo extendido si longitud > 40% del ancho de hombros al cuadrado
      return armLen > (_sw(pose) * _sw(pose) * 0.16);
    },
  ),
  GuidedStep(
    title: 'Palma hacia afuera',
    instruction: 'Gira la muñeca con la palma mirando hacia afuera. '
        'Codo estirado.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final le = _le(pose); final lw = _lw(pose);
      if (le == null || lw == null) return false;
      final sw = cal['sw'] ?? 1.0;
      final armLen = ((le.x - lw.x) * (le.x - lw.x) +
                      (le.y - lw.y) * (le.y - lw.y));
      return armLen > (sw * sw * 0.20);
    },
  ),
  GuidedStep(
    title: 'Estiramiento extensión — 20 seg',
    instruction: 'Con la otra mano, jala suavemente los dedos hacia tu cuerpo. '
        'Siente el estiramiento. Mantén 20 segundos.',
    holdSeconds: 20.0,
    check: (pose, cal) {
      final le = _le(pose); final lw = _lw(pose);
      if (le == null || lw == null) return false;
      final sw = cal['sw'] ?? 1.0;
      final armLen = ((le.x - lw.x) * (le.x - lw.x) +
                      (le.y - lw.y) * (le.y - lw.y));
      return armLen > (sw * sw * 0.16);
    },
  ),
  GuidedStep(
    title: 'Flexión de muñeca — 20 seg',
    instruction: 'Flexiona la muñeca hacia abajo y jala los dedos. '
        'Mantén 20 segundos.',
    holdSeconds: 20.0,
    check: (pose, cal) {
      final le = _le(pose); final lw = _lw(pose);
      if (le == null || lw == null) return false;
      final sw = cal['sw'] ?? 1.0;
      // Muñeca más abajo que el codo en > 10% del ancho de hombros
      return (lw.y - le.y) / sw > 0.10;
    },
  ),
  GuidedStep(
    title: 'Cambia de brazo',
    instruction: 'Extiende el brazo izquierdo. '
        'Repite el mismo estiramiento en la muñeca izquierda.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final re = _re(pose); final rw = _rw(pose);
      if (re == null || rw == null) return false;
      final sw = cal['sw'] ?? 1.0;
      final armLen = ((re.x - rw.x) * (re.x - rw.x) +
                      (re.y - rw.y) * (re.y - rw.y));
      return armLen > (sw * sw * 0.16);
    },
  ),
  GuidedStep(
    title: 'Sacude las manos',
    instruction: 'Sacude ambas manos durante 10 segundos '
        'para activar la circulación.',
    holdSeconds: 3.0,
    check: (pose, cal) => _ls(pose) != null && _rs(pose) != null,
  ),
];