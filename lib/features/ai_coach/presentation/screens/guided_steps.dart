import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Define los pasos guiados para cada ejercicio que tiene IA Coach.
/// Cada paso tiene:
/// - title: título corto que aparece en la UI
/// - instruction: qué debe hacer el usuario
/// - holdSeconds: cuántos segundos debe mantener la postura correcta
/// - check: función que evalúa si la postura es correcta usando los landmarks
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

/// Retorna los pasos guiados para un ejercicio dado su ID.
/// Si el ejercicio no tiene guía definida, retorna null.
List<GuidedStep>? getGuidedSteps(String exerciseId) {
  return switch (exerciseId) {
    'shoulder_rolls'          => _shoulderRolls(),
    'neck_lateral_tilt'       => _neckLateralTilt(),
    'neck_rotation'           => _neckRotation(),
    'neck_chin_tuck'          => _neckChinTuck(),
    'chest_opener'            => _chestOpener(),
    'back_cat_cow'            => _backCatCow(),
    'wrist_extension_stretch' => _wristExtension(),
    _                         => null,
  };
}

// ── Helpers de landmarks ──────────────────────────────────────────────────────

PoseLandmark? _ls(Pose p) => p.landmarks[PoseLandmarkType.leftShoulder];
PoseLandmark? _rs(Pose p) => p.landmarks[PoseLandmarkType.rightShoulder];
PoseLandmark? _nose(Pose p) => p.landmarks[PoseLandmarkType.nose];
PoseLandmark? _le(Pose p) => p.landmarks[PoseLandmarkType.leftElbow];
PoseLandmark? _re(Pose p) => p.landmarks[PoseLandmarkType.rightElbow];
PoseLandmark? _lw(Pose p) => p.landmarks[PoseLandmarkType.leftWrist];
PoseLandmark? _rw(Pose p) => p.landmarks[PoseLandmarkType.rightWrist];
PoseLandmark? _lh(Pose p) => p.landmarks[PoseLandmarkType.leftHip];
PoseLandmark? _rh(Pose p) => p.landmarks[PoseLandmarkType.rightHip];

double _shoulderDiff(Pose p) {
  final l = _ls(p); final r = _rs(p);
  if (l == null || r == null) return 999;
  return (l.y - r.y).abs();
}

double _avgShoulderY(Pose p) {
  final l = _ls(p); final r = _rs(p);
  if (l == null || r == null) return 0;
  return (l.y + r.y) / 2;
}

double _noseOffsetFromCenter(Pose p) {
  final n = _nose(p); final l = _ls(p); final r = _rs(p);
  if (n == null || l == null || r == null) return 999;
  return (n.x - (l.x + r.x) / 2).abs();
}

// ══════════════════════════════════════════════════════════════════════════════
//  SHOULDER ROLLS — Rotación de hombros
// ══════════════════════════════════════════════════════════════════════════════

List<GuidedStep> _shoulderRolls() => [
  GuidedStep(
    title: '🪑 Posición inicial',
    instruction: 'Siéntate con la espalda recta y los hombros relajados '
        'a los costados. Mira al frente.',
    holdSeconds: 1.5,
    check: (pose, cal) {
      final l = _ls(pose); final r = _rs(pose);
      if (l == null || r == null) return false;
      cal['baseY'] = (l.y + r.y) / 2;
      return _shoulderDiff(pose) < 35;
    },
  ),
  GuidedStep(
    title: '⬆️ Eleva los hombros',
    instruction: 'Sube ambos hombros hacia las orejas '
        'lo más que puedas. ¡Como encogerte de hombros!',
    holdSeconds: 1.0,
    check: (pose, cal) {
      final base = cal['baseY'];
      if (base == null) return false;
      return _avgShoulderY(pose) < base - 20 && _shoulderDiff(pose) < 40;
    },
  ),
  GuidedStep(
    title: '🔙 Hombros atrás y abajo',
    instruction: 'Lleva los hombros hacia atrás y hacia abajo '
        'completando el círculo. Intenta unir los omóplatos.',
    holdSeconds: 1.0,
    check: (pose, cal) {
      final base = cal['baseY'];
      if (base == null) return false;
      return _avgShoulderY(pose) >= base - 10 && _shoulderDiff(pose) < 35;
    },
  ),
  GuidedStep(
    title: '⬆️ Eleva de nuevo',
    instruction: 'Segunda repetición: vuelve a subir los hombros '
        'hacia las orejas con el mismo movimiento.',
    holdSeconds: 1.0,
    check: (pose, cal) {
      final base = cal['baseY'];
      if (base == null) return false;
      return _avgShoulderY(pose) < base - 20 && _shoulderDiff(pose) < 40;
    },
  ),
  GuidedStep(
    title: '🔙 Completa el círculo',
    instruction: 'Lleva los hombros hacia atrás y abajo por última vez. '
        '¡Ya casi terminas!',
    holdSeconds: 1.0,
    check: (pose, cal) {
      final base = cal['baseY'];
      if (base == null) return false;
      return _avgShoulderY(pose) >= base - 10 && _shoulderDiff(pose) < 35;
    },
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
//  NECK LATERAL TILT — Inclinación lateral de cuello
// ══════════════════════════════════════════════════════════════════════════════

List<GuidedStep> _neckLateralTilt() => [
  GuidedStep(
    title: '🪑 Posición inicial',
    instruction: 'Siéntate erguido. Relaja los hombros hacia abajo, '
        'lejos de las orejas. Mira al frente.',
    holdSeconds: 1.5,
    check: (pose, cal) {
      final l = _ls(pose); final r = _rs(pose); final n = _nose(pose);
      if (l == null || r == null || n == null) return false;
      cal['baseY'] = (l.y + r.y) / 2;
      cal['centerX'] = (l.x + r.x) / 2;
      return _shoulderDiff(pose) < 30 && _noseOffsetFromCenter(pose) < 30;
    },
  ),
  GuidedStep(
    title: '➡️ Inclina hacia la derecha',
    instruction: 'Inclina suavemente la cabeza hacia el hombro derecho. '
        'No levantes el hombro. Siente el estiramiento al lado izquierdo.',
    holdSeconds: 2.0,
    check: (pose, cal) {
      final n = _nose(pose); final center = cal['centerX'];
      if (n == null || center == null) return false;
      // En cámara frontal espejada: derecha del usuario = izquierda en imagen
      final offset = n.x - center;
      return offset > 40 && _shoulderDiff(pose) < 40;
    },
  ),
  GuidedStep(
    title: '↩️ Vuelve al centro',
    instruction: 'Regresa la cabeza al centro lentamente. '
        'Inhala profundo antes del siguiente movimiento.',
    holdSeconds: 1.0,
    check: (pose, cal) => _noseOffsetFromCenter(pose) < 25 && _shoulderDiff(pose) < 35,
  ),
  GuidedStep(
    title: '⬅️ Inclina hacia la izquierda',
    instruction: 'Ahora inclina la cabeza hacia el hombro izquierdo. '
        'Mantén el hombro relajado. Siente el estiramiento al lado derecho.',
    holdSeconds: 2.0,
    check: (pose, cal) {
      final n = _nose(pose); final center = cal['centerX'];
      if (n == null || center == null) return false;
      final offset = center - n.x;
      return offset > 40 && _shoulderDiff(pose) < 40;
    },
  ),
  GuidedStep(
    title: '↩️ Vuelve al centro',
    instruction: 'Regresa al centro lentamente. '
        '¡Excelente trabajo! Has completado el estiramiento.',
    holdSeconds: 1.0,
    check: (pose, cal) => _noseOffsetFromCenter(pose) < 25 && _shoulderDiff(pose) < 35,
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
//  NECK ROTATION — Rotación de cuello
// ══════════════════════════════════════════════════════════════════════════════

List<GuidedStep> _neckRotation() => [
  GuidedStep(
    title: '🪑 Posición inicial',
    instruction: 'Siéntate erguido. Mantén la barbilla paralela al suelo. '
        'Hombros quietos y relajados.',
    holdSeconds: 1.5,
    check: (pose, cal) {
      final n = _nose(pose); final l = _ls(pose); final r = _rs(pose);
      if (n == null || l == null || r == null) return false;
      cal['centerX'] = (l.x + r.x) / 2;
      return _noseOffsetFromCenter(pose) < 30 && _shoulderDiff(pose) < 30;
    },
  ),
  GuidedStep(
    title: '➡️ Gira a la derecha',
    instruction: 'Gira la cabeza lentamente hacia tu hombro derecho '
        'hasta donde sea cómodo. No fuerces.',
    holdSeconds: 2.0,
    check: (pose, cal) {
      final n = _nose(pose); final center = cal['centerX'];
      if (n == null || center == null) return false;
      return (n.x - center) > 50 && _shoulderDiff(pose) < 35;
    },
  ),
  GuidedStep(
    title: '↩️ Vuelve al centro',
    instruction: 'Regresa al centro con calma. '
        'Respira profundo.',
    holdSeconds: 1.0,
    check: (pose, cal) => _noseOffsetFromCenter(pose) < 25,
  ),
  GuidedStep(
    title: '⬅️ Gira a la izquierda',
    instruction: 'Gira la cabeza hacia tu hombro izquierdo. '
        'Mismo rango que el lado derecho.',
    holdSeconds: 2.0,
    check: (pose, cal) {
      final n = _nose(pose); final center = cal['centerX'];
      if (n == null || center == null) return false;
      return (center - n.x) > 50 && _shoulderDiff(pose) < 35;
    },
  ),
  GuidedStep(
    title: '↩️ Centro y relaja',
    instruction: 'Vuelve al centro y baja suavemente '
        'la barbilla hacia el pecho por 3 segundos para cerrar.',
    holdSeconds: 1.0,
    check: (pose, cal) => _noseOffsetFromCenter(pose) < 25,
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
//  NECK CHIN TUCK — Retracción de mentón
// ══════════════════════════════════════════════════════════════════════════════

List<GuidedStep> _neckChinTuck() => [
  GuidedStep(
    title: '🪑 Posición inicial',
    instruction: 'Siéntate mirando al frente. '
        'Relaja los hombros. Elige un punto fijo al frente a la altura de tus ojos.',
    holdSeconds: 1.5,
    check: (pose, cal) {
      final n = _nose(pose); final l = _ls(pose); final r = _rs(pose);
      if (n == null || l == null || r == null) return false;
      cal['noseY'] = n.y;
      cal['centerX'] = (l.x + r.x) / 2;
      return _shoulderDiff(pose) < 35 && _noseOffsetFromCenter(pose) < 30;
    },
  ),
  GuidedStep(
    title: '↩️ Retrae el mentón',
    instruction: 'Sin bajar la cabeza, lleva el mentón hacia atrás '
        'como si quisieras hacer una doble papada. '
        'Sientes elongación en la nuca.',
    holdSeconds: 2.0,
    check: (pose, cal) {
      final n = _nose(pose); final baseY = cal['noseY'];
      if (n == null || baseY == null) return false;
      // La nariz se mueve ligeramente hacia atrás (en imagen: se aleja de la cámara)
      // Detectamos que los hombros siguen nivelados y la cabeza está centrada
      return _noseOffsetFromCenter(pose) < 35 && _shoulderDiff(pose) < 30;
    },
  ),
  GuidedStep(
    title: '➡️ Suelta y repite',
    instruction: 'Regresa a posición normal. '
        'Prepárate para la segunda retracción.',
    holdSeconds: 1.0,
    check: (pose, cal) => _shoulderDiff(pose) < 35 && _noseOffsetFromCenter(pose) < 30,
  ),
  GuidedStep(
    title: '↩️ Segunda retracción',
    instruction: 'Vuelve a llevar el mentón hacia atrás. '
        'Cada vez que lo haces mejoras tu postura cervical.',
    holdSeconds: 2.0,
    check: (pose, cal) =>
        _noseOffsetFromCenter(pose) < 35 && _shoulderDiff(pose) < 30,
  ),
  GuidedStep(
    title: '✅ Posición final',
    instruction: 'Mantén la posición corregida con el mentón ligeramente '
        'retraído. Esta es la postura correcta para trabajar.',
    holdSeconds: 2.0,
    check: (pose, cal) =>
        _shoulderDiff(pose) < 35 && _noseOffsetFromCenter(pose) < 30,
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
//  CHEST OPENER — Apertura de pecho
// ══════════════════════════════════════════════════════════════════════════════

List<GuidedStep> _chestOpener() => [
  GuidedStep(
    title: '🪑 Posición inicial',
    instruction: 'Siéntate al borde de la silla. '
        'Pies planos en el suelo. Espalda recta.',
    holdSeconds: 1.5,
    check: (pose, cal) {
      final l = _ls(pose); final r = _rs(pose);
      if (l == null || r == null) return false;
      cal['baseY'] = (l.y + r.y) / 2;
      cal['baseWidth'] = (l.x - r.x).abs();
      return _shoulderDiff(pose) < 35;
    },
  ),
  GuidedStep(
    title: '🤝 Lleva los codos atrás',
    instruction: 'Entrelaza los dedos detrás de la nuca. '
        'Lleva los codos hacia atrás abriendo el pecho hacia adelante.',
    holdSeconds: 2.0,
    check: (pose, cal) {
      final le = _le(pose); final re = _re(pose);
      final l = _ls(pose); final r = _rs(pose);
      if (le == null || re == null || l == null || r == null) return false;
      // Codos deben estar más separados que los hombros (apertura)
      final elbowWidth = (le.x - re.x).abs();
      final shoulderWidth = (l.x - r.x).abs();
      return elbowWidth > shoulderWidth * 0.8 && _shoulderDiff(pose) < 40;
    },
  ),
  GuidedStep(
    title: '🦅 Mantén la apertura',
    instruction: 'Inhala profundo mientras mantienes el pecho abierto. '
        'Con cada exhalación siente cómo se relajan más los hombros hacia atrás.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final le = _le(pose); final re = _re(pose);
      final l = _ls(pose); final r = _rs(pose);
      if (le == null || re == null || l == null || r == null) return false;
      final elbowWidth = (le.x - re.x).abs();
      final shoulderWidth = (l.x - r.x).abs();
      return elbowWidth > shoulderWidth * 0.8;
    },
  ),
  GuidedStep(
    title: '⬇️ Baja los brazos',
    instruction: 'Suelta los dedos y baja los brazos lentamente. '
        'Nota la diferencia en tu postura.',
    holdSeconds: 1.5,
    check: (pose, cal) {
      final le = _le(pose); final re = _re(pose);
      if (le == null || re == null) return false;
      // Codos vuelven a estar más bajos que los hombros
      final l = _ls(pose); final r = _rs(pose);
      if (l == null || r == null) return false;
      return le.y > l.y && re.y > r.y;
    },
  ),
  GuidedStep(
    title: '✅ Postura corregida',
    instruction: 'Mantén esta postura con el pecho ligeramente elevado. '
        '¡Este es el efecto del ejercicio!',
    holdSeconds: 2.0,
    check: (pose, cal) => _shoulderDiff(pose) < 40,
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
//  BACK CAT COW — Gato-vaca en silla
// ══════════════════════════════════════════════════════════════════════════════

List<GuidedStep> _backCatCow() => [
  GuidedStep(
    title: '🪑 Posición neutral',
    instruction: 'Siéntate al borde de la silla. Pies en el suelo. '
        'Manos sobre las rodillas. Espalda en posición neutral.',
    holdSeconds: 1.5,
    check: (pose, cal) {
      final l = _ls(pose); final r = _rs(pose);
      final lh = _lh(pose); final rh = _rh(pose);
      if (l == null || r == null || lh == null || rh == null) return false;
      cal['shoulderY'] = (l.y + r.y) / 2;
      cal['hipY'] = (lh.y + rh.y) / 2;
      return _shoulderDiff(pose) < 35;
    },
  ),
  GuidedStep(
    title: '🐄 Posición VACA — arquea',
    instruction: 'Inhala: arquea la espalda hacia adelante, '
        'saca el pecho y lleva la mirada ligeramente hacia arriba. '
        'La pelvis se inclina hacia adelante.',
    holdSeconds: 2.0,
    check: (pose, cal) {
      final l = _ls(pose); final r = _rs(pose);
      final baseY = cal['shoulderY'];
      if (l == null || r == null || baseY == null) return false;
      final currentY = (l.y + r.y) / 2;
      // En posición vaca los hombros se llevan hacia atrás y arriba
      return currentY < baseY - 15 && _shoulderDiff(pose) < 40;
    },
  ),
  GuidedStep(
    title: '🐱 Posición GATO — redondea',
    instruction: 'Exhala: redondea la espalda hacia afuera, '
        'mete el ombligo y lleva la mirada hacia abajo. '
        'La pelvis se inclina hacia atrás.',
    holdSeconds: 2.0,
    check: (pose, cal) {
      final l = _ls(pose); final r = _rs(pose);
      final baseY = cal['shoulderY'];
      if (l == null || r == null || baseY == null) return false;
      final currentY = (l.y + r.y) / 2;
      // En posición gato los hombros caen hacia adelante
      return currentY > baseY + 15;
    },
  ),
  GuidedStep(
    title: '🐄 Segunda vez VACA',
    instruction: 'Inhala de nuevo y arquea la espalda. '
        'Cada ciclo mejora la movilidad de tu columna.',
    holdSeconds: 2.0,
    check: (pose, cal) {
      final l = _ls(pose); final r = _rs(pose);
      final baseY = cal['shoulderY'];
      if (l == null || r == null || baseY == null) return false;
      return (l.y + r.y) / 2 < baseY - 15;
    },
  ),
  GuidedStep(
    title: '🐱 Segunda vez GATO',
    instruction: 'Exhala y redondea. Quédate aquí 2 segundos '
        'sintiendo el estiramiento en toda la columna.',
    holdSeconds: 2.0,
    check: (pose, cal) {
      final l = _ls(pose); final r = _rs(pose);
      final baseY = cal['shoulderY'];
      if (l == null || r == null || baseY == null) return false;
      return (l.y + r.y) / 2 > baseY + 15;
    },
  ),
  GuidedStep(
    title: '↩️ Posición neutral',
    instruction: 'Regresa a la posición neutral. '
        'Siente la diferencia — tu columna debería sentirse más libre.',
    holdSeconds: 1.5,
    check: (pose, cal) => _shoulderDiff(pose) < 35,
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
//  WRIST EXTENSION STRETCH — Estiramiento de muñecas
// ══════════════════════════════════════════════════════════════════════════════

List<GuidedStep> _wristExtension() => [
  GuidedStep(
    title: '🪑 Posición inicial',
    instruction: 'Siéntate erguido. Extiende el brazo derecho '
        'hacia adelante paralelo al suelo.',
    holdSeconds: 1.5,
    check: (pose, cal) {
      final le = _le(pose); final lw = _lw(pose);
      if (le == null || lw == null) return false;
      cal['baseY'] = (le.y + lw.y) / 2;
      // Verificar que el brazo está relativamente extendido
      final len = (le.x - lw.x) * (le.x - lw.x) + (le.y - lw.y) * (le.y - lw.y);
      return len > 800;
    },
  ),
  GuidedStep(
    title: '🖐️ Palma hacia afuera',
    instruction: 'Gira la muñeca para que la palma mire hacia afuera '
        '(gesto de "stop"). Mantén el codo estirado.',
    holdSeconds: 2.0,
    check: (pose, cal) {
      final le = _le(pose); final lw = _lw(pose);
      if (le == null || lw == null) return false;
      final len = (le.x - lw.x) * (le.x - lw.x) + (le.y - lw.y) * (le.y - lw.y);
      return len > 1000;
    },
  ),
  GuidedStep(
    title: '↩️ Jala los dedos hacia ti',
    instruction: 'Con la otra mano, jala suavemente los dedos '
        'hacia tu cuerpo. Siente el estiramiento en la palma y el antebrazo.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final le = _le(pose); final lw = _lw(pose);
      final re = _re(pose); final rw = _rw(pose);
      if (le == null || lw == null || re == null || rw == null) return false;
      // Ambos brazos activos
      final leftLen = (le.x - lw.x) * (le.x - lw.x) + (le.y - lw.y) * (le.y - lw.y);
      return leftLen > 800;
    },
  ),
  GuidedStep(
    title: '⬇️ Flexión de muñeca',
    instruction: 'Ahora flexiona la muñeca hacia abajo '
        '(dedos apuntando al suelo) y jala los dedos hacia ti.',
    holdSeconds: 3.0,
    check: (pose, cal) {
      final le = _le(pose); final lw = _lw(pose);
      if (le == null || lw == null) return false;
      // La muñeca está más abajo que el codo
      return lw.y > le.y + 20;
    },
  ),
  GuidedStep(
    title: '🔄 Cambia de brazo',
    instruction: 'Ahora extiende el brazo izquierdo. '
        'Repite el mismo estiramiento en la muñeca izquierda.',
    holdSeconds: 2.0,
    check: (pose, cal) {
      final re = _re(pose); final rw = _rw(pose);
      if (re == null || rw == null) return false;
      final len = (re.x - rw.x) * (re.x - rw.x) + (re.y - rw.y) * (re.y - rw.y);
      return len > 800;
    },
  ),
  GuidedStep(
    title: '✅ Sacude las manos',
    instruction: 'Sacude ambas manos durante 10 segundos '
        'para activar la circulación. ¡Ejercicio completado!',
    holdSeconds: 2.0,
    check: (pose, cal) {
      // Solo verificamos que el usuario está en encuadre
      return _ls(pose) != null && _rs(pose) != null;
    },
  ),
];