/// Constantes globales de ErgoFit.
/// Centralizar aquí evita magic strings y magic numbers dispersos en el código.
class AppConstants {
  AppConstants._();

  // ── App ──────────────────────────────────────────────────────────────────
  static const String appName = 'ErgoFit';
  static const String appVersion = '1.0.0';

  // ── Categorías de ejercicios ─────────────────────────────────────────────
  static const String catNeck       = 'neck';
  static const String catShoulders  = 'shoulders';
  static const String catBack       = 'back';
  static const String catEyes       = 'eyes';
  static const String catWrists     = 'wrists';
  static const String catLegs       = 'legs';
  static const String catBreathing  = 'breathing';

  static const List<String> allCategories = [
    catNeck, catShoulders, catBack, catEyes, catWrists, catLegs, catBreathing,
  ];

  static const Map<String, String> categoryLabels = {
    catNeck:      'Cuello',
    catShoulders: 'Hombros',
    catBack:      'Espalda',
    catEyes:      'Ojos',
    catWrists:    'Muñecas',
    catLegs:      'Piernas',
    catBreathing: 'Respiración',
  };

  static const Map<String, String> categoryEmojis = {
    catNeck:      '🦒',
    catShoulders: '🙆',
    catBack:      '🐱',
    catEyes:      '👁️',
    catWrists:    '🤲',
    catLegs:      '🦵',
    catBreathing: '🌬️',
  };

  // ── Dificultad ───────────────────────────────────────────────────────────
  static const String diffEasy   = 'easy';
  static const String diffMedium = 'medium';
  static const String diffHard   = 'hard';

  static const Map<String, String> difficultyLabels = {
    diffEasy:   'Fácil',
    diffMedium: 'Moderado',
    diffHard:   'Avanzado',
  };

  // ── Posición ─────────────────────────────────────────────────────────────
  static const String posSeated   = 'seated';
  static const String posStanding = 'standing';
  static const String posBoth     = 'both';

  static const Map<String, String> positionLabels = {
    posSeated:   'Sentado',
    posStanding: 'De pie',
    posBoth:     'Sentado/De pie',
  };

  // ── Roles laborales ──────────────────────────────────────────────────────
  static const String roleDeveloper = 'developer';
  static const String roleDesigner  = 'designer';
  static const String roleAdmin     = 'admin';
  static const String roleStudent   = 'student';
  static const String roleOther     = 'other';

  static const Map<String, String> roleLabels = {
    roleDeveloper: '💻 Desarrollador',
    roleDesigner:  '🎨 Diseñador',
    roleAdmin:     '📋 Administrativo',
    roleStudent:   '📚 Estudiante',
    roleOther:     '👤 Otro',
  };

  // ── Notificaciones ───────────────────────────────────────────────────────
  static const String notifChannelId          = 'ergofit_breaks';
  static const String notifChannelName        = 'Pausas activas';
  static const String notifChannelDescription = 'Recordatorios de pausas y estiramientos';

  // ── Intervalos de pausa disponibles (en minutos) ─────────────────────────
  static const List<int> intervalOptions = [15, 20, 30, 45, 60, 90, 120];

  // ── Meta diaria por defecto ───────────────────────────────────────────────
  static const int defaultDailyGoalMinutes = 15;

  // ── Guardar sesión si completó más de este porcentaje ────────────────────
  static const double autoSaveThreshold = 0.5;
}