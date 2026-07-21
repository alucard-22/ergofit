import 'dart:convert';
import 'package:drift/drift.dart';
import '../app_database.dart';

class ExercisesSeedData {
  static List<ExercisesCompanion> get all {
    final now = DateTime.now().millisecondsSinceEpoch;

    return [
      // ══════════════════════════════════════════════════════════════════════
      //  CUELLO
      // ══════════════════════════════════════════════════════════════════════

      ExercisesCompanion.insert(
        id: 'neck_lateral_tilt',
        name: 'Inclinación lateral de cuello',
        description:
            'Lleva la oreja hacia el hombro para aliviar la tensión cervical acumulada por horas frente a la pantalla. Validado por fisioterapeuta.',
        benefit: 'Reduce tensión cervical',
        category: 'neck',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 120,
        hasAiCoach: const Value(true),
        emoji: '🦒',
        stepsJson: json.encode([
          '🪑 POSICIÓN INICIAL — Siéntate erguido con la espalda recta. Relaja los hombros alejándolos de las orejas. Pies planos en el suelo.',
          '➡️ LADO DERECHO — Lleva lentamente la oreja derecha hacia el hombro derecho. No levantes el hombro para alcanzarla. Siente el estiramiento en el lado izquierdo del cuello.',
          '⏱️ MANTÉN 20–30 SEGUNDOS — Respira lento y profundo. Con cada exhalación relaja un poco más. Si sientes dolor agudo, reduce el ángulo.',
          '↩️ CENTRO — Regresa al centro lentamente. Nunca uses movimientos bruscos con el cuello.',
          '⬅️ LADO IZQUIERDO — Lleva la oreja izquierda hacia el hombro izquierdo. Mantén otros 20–30 segundos respirando profundo.',
          '⚠️ ADVERTENCIA — Si aparece hormigueo, mareo o dolor intenso, detén el ejercicio inmediatamente y consulta con un profesional de salud.',
        ]),
        createdAt: now,
      ),

      ExercisesCompanion.insert(
        id: 'neck_flexion',
        name: 'Flexión de cuello',
        description:
            'Baja el mentón hacia el pecho para estirar la musculatura posterior del cuello. Ideal para contrarrestar la postura de cabeza adelantada.',
        benefit: 'Estira nuca y cervicales',
        category: 'neck',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 60,
        hasAiCoach: const Value(true),
        emoji: '🧎',
        stepsJson: json.encode([
          '🪑 POSICIÓN INICIAL — Siéntate con la espalda recta. Relaja los hombros. Mira al frente con la barbilla paralela al suelo.',
          '⬇️ BAJA EL MENTÓN — Lentamente baja el mentón hacia el pecho. Sientes el estiramiento en la nuca y la parte posterior del cuello.',
          '⏱️ MANTÉN 20–30 SEGUNDOS — Respira profundo. No fuerces el movimiento. La gravedad hace el trabajo.',
          '⬆️ REGRESA — Sube la cabeza lentamente a la posición inicial. Haz una pausa de 5 segundos.',
          '🔄 REPITE — Realiza 3 repeticiones. Este ejercicio es especialmente útil si pasas horas mirando hacia abajo el celular.',
          '⚠️ ADVERTENCIA — Si aparece hormigueo en los brazos o mareo, detén el ejercicio y consulta con un profesional.',
        ]),
        createdAt: now,
      ),

      ExercisesCompanion.insert(
        id: 'neck_rotation',
        name: 'Rotación de cuello',
        description:
            'Gira la cabeza de lado a lado para mejorar la movilidad cervical y reducir la rigidez por trabajo sedentario.',
        benefit: 'Mejora movilidad cervical',
        category: 'neck',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 90,
        hasAiCoach: const Value(true),
        emoji: '🔄',
        stepsJson: json.encode([
          '🪑 POSICIÓN INICIAL — Siéntate erguido. Mantén la barbilla paralela al suelo durante todo el ejercicio. Hombros relajados y quietos.',
          '➡️ GIRA A LA DERECHA — Gira la cabeza lentamente hacia tu hombro derecho hasta donde sea cómodo. No fuerces más allá de tu límite.',
          '⏱️ MANTÉN 15–20 SEGUNDOS — Respira normalmente. Mira hacia atrás sin mover los hombros.',
          '↩️ CENTRO — Regresa al centro con el mismo ritmo lento.',
          '⬅️ GIRA A LA IZQUIERDA — Repite hacia el lado izquierdo. Mantén otros 15–20 segundos.',
          '⚠️ ADVERTENCIA — Si sientes dolor, mareo o pérdida de fuerza, detén el ejercicio y consulta con un profesional de salud.',
        ]),
        createdAt: now,
      ),

      ExercisesCompanion.insert(
        id: 'neck_chin_tuck',
        name: 'Retracción de mentón',
        description:
            'Corrige la postura de cabeza adelantada típica del trabajo con computadora. Simple pero muy efectivo con práctica diaria.',
        benefit: 'Corrige postura de cuello',
        category: 'neck',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 60,
        hasAiCoach: const Value(true),
        emoji: '🧠',
        stepsJson: json.encode([
          '🪑 POSICIÓN INICIAL — Siéntate mirando al frente. Relaja los hombros. Elige un punto fijo a la altura de tus ojos.',
          '↩️ RETRAE EL MENTÓN — Sin bajar la cabeza, lleva el mentón hacia atrás como haciendo una doble papada. Sientes elongación en la nuca.',
          '⏱️ MANTÉN 5 SEGUNDOS — Respira normalmente. La sensación correcta es de elongación, no de dolor.',
          '➡️ SUELTA Y REPITE — Regresa y repite 10 veces lentas y controladas.',
          '✅ POSTURA FINAL — Mantén esta posición como hábito al trabajar. Es la postura cervical correcta.',
          '⚠️ ADVERTENCIA — Si sientes dolor agudo o hormigueo, reduce el rango o consulta con un profesional.',
        ]),
        createdAt: now,
      ),

      // ══════════════════════════════════════════════════════════════════════
      //  HOMBROS
      // ══════════════════════════════════════════════════════════════════════

      ExercisesCompanion.insert(
        id: 'shoulder_rolls',
        name: 'Rotación de hombros',
        description:
            'Descomprime los hombros y mejora la circulación en la zona superior. Efectivo para liberar tensión por teclear durante horas.',
        benefit: 'Alivia tensión en hombros',
        category: 'shoulders',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 60,
        hasAiCoach: const Value(true),
        emoji: '🙆',
        stepsJson: json.encode([
          '🪑 POSICIÓN INICIAL — Siéntate o párate cómodamente. Brazos relajados a los costados.',
          '⬆️ ELEVA LOS HOMBROS — Sube ambos hombros hacia las orejas. Mantén 2 segundos.',
          '🔙 ROTA HACIA ATRÁS — Lleva los hombros hacia atrás y abajo completando un círculo. Imagina que unes los omóplatos.',
          '⏱️ RITMO LENTO — Cada círculo debe durar 3–4 segundos. La lentitud genera el beneficio.',
          '🔄 10 ROTACIONES — Completa 10 hacia atrás y 10 hacia adelante.',
          '⚠️ ADVERTENCIA — Si aparece dolor agudo en el hombro, detén el ejercicio.',
        ]),
        createdAt: now,
      ),

      ExercisesCompanion.insert(
        id: 'shoulder_cross_stretch',
        name: 'Estiramiento cruzado de hombro',
        description:
            'Estira el músculo deltoides y la cápsula articular del hombro. Recomendado por fisioterapeuta para aliviar tensión del trabajo de oficina.',
        benefit: 'Estira deltoides y hombro',
        category: 'shoulders',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 120,
        hasAiCoach: const Value(false),
        emoji: '🤝',
        stepsJson: json.encode([
          '🪑 POSICIÓN INICIAL — Siéntate o párate erguido con los hombros relajados.',
          '➡️ BRAZO DERECHO — Lleva el brazo derecho extendido cruzando frente al pecho hacia el lado izquierdo.',
          '🤝 AYUDA CON EL OTRO BRAZO — Usa el antebrazo izquierdo para empujar suavemente el brazo derecho más cerca del pecho.',
          '⏱️ MANTÉN 20–30 SEGUNDOS — Siente el estiramiento en la parte posterior del hombro derecho. Respira profundo.',
          '⬅️ CAMBIA DE LADO — Repite con el brazo izquierdo cruzando hacia la derecha. Mantén otros 20–30 segundos.',
          '⚠️ ADVERTENCIA — No fuerces si sientes dolor agudo en el hombro. Reduce la intensidad.',
        ]),
        createdAt: now,
      ),

      ExercisesCompanion.insert(
        id: 'triceps_stretch',
        name: 'Estiramiento de tríceps',
        description:
            'Estira el tríceps y la zona posterior del brazo. Especialmente útil para programadores que mantienen los brazos elevados al teclear.',
        benefit: 'Estira tríceps y brazo posterior',
        category: 'shoulders',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 120,
        hasAiCoach: const Value(false),
        emoji: '💪',
        stepsJson: json.encode([
          '🪑 POSICIÓN INICIAL — Siéntate o párate erguido. Espalda recta.',
          '⬆️ BRAZO DERECHO — Lleva el brazo derecho por encima de la cabeza y flexiona el codo, dejando la mano caer hacia la espalda.',
          '🤝 EMPUJE SUAVE — Con la mano izquierda, empuja suavemente el codo derecho hacia abajo y atrás. Sientes el estiramiento en la parte posterior del brazo.',
          '⏱️ MANTÉN 20–30 SEGUNDOS — Respira profundo. No bajes la cabeza hacia adelante.',
          '⬅️ CAMBIA DE LADO — Repite con el brazo izquierdo. Mantén otros 20–30 segundos.',
          '⚠️ ADVERTENCIA — Si sientes dolor en el codo o el hombro, reduce la presión aplicada.',
        ]),
        createdAt: now,
      ),

      ExercisesCompanion.insert(
        id: 'chest_opener',
        name: 'Apertura de pecho',
        description:
            'Entrelaza las manos detrás de la espalda y lleva los hombros hacia atrás para contrarrestar la postura encorvada del escritorio.',
        benefit: 'Corrige postura encorvada',
        category: 'shoulders',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 120,
        hasAiCoach: const Value(true),
        emoji: '🦅',
        stepsJson: json.encode([
          '🪑 POSICIÓN INICIAL — Siéntate al borde de la silla. Pies planos en el suelo. Espalda recta.',
          '🤝 ENTRELAZA LAS MANOS — Lleva ambas manos detrás de la espalda baja y entrelaza los dedos.',
          '🦅 ABRE EL PECHO — Inhala mientras llevas los hombros hacia atrás y el pecho hacia adelante. Las manos entrelazadas se alejan de tu espalda.',
          '⏱️ MANTÉN 20–30 SEGUNDOS — Con cada inhalación el pecho se abre más. Con cada exhalación los hombros se relajan más atrás.',
          '🔍 QUÉ DEBES SENTIR — Estiramiento en el pecho y la parte frontal de los hombros. Si sientes dolor en el cuello, baja ligeramente el mentón.',
          '⚠️ ADVERTENCIA — No arquees en exceso la zona lumbar. Mantén el abdomen ligeramente activado.',
        ]),
        createdAt: now,
      ),

      // ══════════════════════════════════════════════════════════════════════
      //  ESPALDA
      // ══════════════════════════════════════════════════════════════════════

      ExercisesCompanion.insert(
        id: 'back_cat_cow',
        name: 'Gato-vaca en silla',
        description:
            'Versión adaptada para silla del clásico ejercicio de yoga. Moviliza toda la columna y libera la tensión lumbar acumulada.',
        benefit: 'Moviliza toda la columna',
        category: 'back',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 120,
        hasAiCoach: const Value(true),
        emoji: '🐱',
        stepsJson: json.encode([
          '🪑 POSICIÓN INICIAL — Siéntate al borde de la silla. Pies planos. Manos sobre las rodillas.',
          '🐄 POSICIÓN VACA — Inhala: arquea la espalda hacia adelante, saca el pecho y lleva la mirada ligeramente hacia arriba.',
          '🐱 POSICIÓN GATO — Exhala: redondea la espalda, mete el ombligo y lleva la mirada hacia abajo.',
          '🌊 FLUYE CON LA RESPIRACIÓN — El movimiento lo dicta tu respiración. Inhalación = vaca. Exhalación = gato.',
          '🔄 10 CICLOS — Cada ciclo debe durar 6–8 segundos. Muévete como olas del mar.',
          '⚠️ ADVERTENCIA — Si sientes dolor lumbar agudo, reduce el rango de movimiento.',
        ]),
        createdAt: now,
      ),

      ExercisesCompanion.insert(
        id: 'back_seated_twist',
        name: 'Torsión espinal sentado',
        description:
            'Descomprime los discos intervertebrales y aumenta la flexibilidad rotacional de la columna.',
        benefit: 'Descomprime la columna',
        category: 'back',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 120,
        hasAiCoach: const Value(false),
        emoji: '🌀',
        stepsJson: json.encode([
          '🪑 POSICIÓN INICIAL — Siéntate erguido sin apoyar la espalda. Pies en el suelo. Inhala para alargar la columna.',
          '⬅️ GIRA A LA IZQUIERDA — Coloca la mano derecha en el muslo izquierdo. Gira el torso lentamente hacia la izquierda.',
          '⏱️ MANTÉN 20–30 SEGUNDOS — Respira profundo. Con cada inhalación crece hacia arriba. Con cada exhalación gira un poco más.',
          '↩️ CENTRO — Regresa al centro con una inhalación.',
          '➡️ REPITE AL LADO DERECHO — Mantén otros 20–30 segundos.',
          '⚠️ ADVERTENCIA — Si sientes dolor agudo o punzante, reduce el rango inmediatamente.',
        ]),
        createdAt: now,
      ),

      ExercisesCompanion.insert(
        id: 'back_child_pose',
        name: 'Postura del niño',
        description:
            'Estiramiento profundo de la espalda baja, caderas y muslos. Recomendado por fisioterapeuta para aliviar tensión lumbar.',
        benefit: 'Estira espalda baja y caderas',
        category: 'back',
        difficulty: 'easy',
        position: 'standing',
        durationSeconds: 60,
        hasAiCoach: const Value(false),
        emoji: '🧘',
        stepsJson: json.encode([
          '🧎 POSICIÓN INICIAL — Arrodíllate en el suelo. Las rodillas pueden estar juntas o separadas al ancho de las caderas.',
          '⬇️ BAJA — Siéntate sobre los talones y estira los brazos hacia adelante sobre el suelo. La frente puede tocar el suelo.',
          '⏱️ MANTÉN 30–60 SEGUNDOS — Respira profundo. Siente cómo la espalda baja se estira con cada exhalación.',
          '🔍 QUÉ DEBES SENTIR — Estiramiento suave en la espalda baja, caderas y hombros. No debe doler.',
          '⬆️ REGRESA — Sube lentamente apoyándote en las manos. No te levantes bruscamente.',
          '⚠️ ADVERTENCIA — Evita este ejercicio si tienes problemas en las rodillas. Consulta con un profesional si tienes dolor lumbar severo.',
        ]),
        createdAt: now,
      ),

      ExercisesCompanion.insert(
        id: 'back_knees_to_chest',
        name: 'Rodillas al pecho',
        description:
            'Alivia la tensión lumbar y estira la zona glútea. Recomendado por fisioterapeuta para personas con dolor de espalda baja.',
        benefit: 'Alivia tensión lumbar',
        category: 'back',
        difficulty: 'easy',
        position: 'standing',
        durationSeconds: 60,
        hasAiCoach: const Value(false),
        emoji: '🦵',
        stepsJson: json.encode([
          '🛌 POSICIÓN INICIAL — Acuéstate boca arriba en una superficie firme (colchoneta o suelo con alfombra).',
          '🦵 LLEVA LAS RODILLAS — Lleva una o ambas rodillas hacia el pecho. Abraza las rodillas con los brazos.',
          '⏱️ MANTÉN 20–30 SEGUNDOS — Respira profundo. Siente el estiramiento en la zona lumbar y glúteos.',
          '🔄 ALTERNA — Puedes hacerlo con una rodilla a la vez para mayor control.',
          '⬇️ BAJA LENTAMENTE — Baja los pies al suelo con cuidado. Rueda hacia un lado antes de levantarte.',
          '⚠️ ADVERTENCIA — Si sientes dolor agudo en la espalda o las rodillas, detén el ejercicio.',
        ]),
        createdAt: now,
      ),

      ExercisesCompanion.insert(
        id: 'back_lumbar_rotation',
        name: 'Rotación lumbar',
        description:
            'Estira los músculos lumbares y mejora la movilidad rotacional de la columna. Recomendado por fisioterapeuta.',
        benefit: 'Estira músculos lumbares',
        category: 'back',
        difficulty: 'easy',
        position: 'standing',
        durationSeconds: 120,
        hasAiCoach: const Value(false),
        emoji: '🌀',
        stepsJson: json.encode([
          '🛌 POSICIÓN INICIAL — Acuéstate boca arriba con las rodillas dobladas y los pies planos en el suelo.',
          '⬅️ RODILLAS A LA IZQUIERDA — Deja caer ambas rodillas lentamente hacia el lado izquierdo. Mantén los hombros apoyados en el suelo.',
          '⏱️ MANTÉN 20–30 SEGUNDOS — Respira profundo. Siente el estiramiento en la zona lumbar y la cadera.',
          '↩️ CENTRO — Regresa las rodillas al centro lentamente.',
          '➡️ RODILLAS A LA DERECHA — Repite hacia el lado derecho. Mantén otros 20–30 segundos.',
          '⚠️ ADVERTENCIA — Si sientes dolor agudo en la espalda o las caderas, reduce el rango de movimiento.',
        ]),
        createdAt: now,
      ),

      ExercisesCompanion.insert(
        id: 'back_lateral_stretch',
        name: 'Estiramiento lateral de tronco',
        description:
            'Estira los músculos intercostales y el cuadrado lumbar. Alivia la tensión lateral acumulada por sentarse por horas.',
        benefit: 'Estira costados y zona lumbar',
        category: 'back',
        difficulty: 'easy',
        position: 'standing',
        durationSeconds: 120,
        hasAiCoach: const Value(false),
        emoji: '↔️',
        stepsJson: json.encode([
          '🧍 POSICIÓN INICIAL — De pie con los pies separados al ancho de las caderas. Brazos a los costados.',
          '⬆️ BRAZO DERECHO — Eleva el brazo derecho por encima de la cabeza.',
          '⬅️ INCLÍNATE — Inclínate lentamente hacia el lado izquierdo. Siente el estiramiento en todo el costado derecho.',
          '⏱️ MANTÉN 20–30 SEGUNDOS — Respira profundo. Con cada exhalación profundiza suavemente el estiramiento.',
          '↩️ REGRESA Y CAMBIA — Vuelve al centro y repite con el brazo izquierdo hacia el lado derecho.',
          '⚠️ ADVERTENCIA — Mantén las caderas niveladas. No te inclines hacia adelante ni hacia atrás.',
        ]),
        createdAt: now,
      ),

      // ══════════════════════════════════════════════════════════════════════
      //  OJOS
      // ══════════════════════════════════════════════════════════════════════

      ExercisesCompanion.insert(
        id: 'eyes_20_20_20',
        name: 'Regla 20-20-20',
        description:
            'El método más respaldado científicamente para prevenir la fatiga visual digital. Cada 20 minutos, 20 segundos a 6 metros.',
        benefit: 'Reduce fatiga visual digital',
        category: 'eyes',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 20,
        hasAiCoach: const Value(false),
        emoji: '👁️',
        stepsJson: json.encode([
          '⏰ CUÁNDO — Cada 20 minutos de trabajo continuo frente a la pantalla.',
          '👀 BUSCA UN PUNTO LEJANO — Un objeto a al menos 6 metros de distancia.',
          '🎯 ENFOCA ESE PUNTO — Mira directamente durante 20 segundos completos.',
          '😌 PARPADEA — Parpadea conscientemente cada 3–4 segundos para hidratar los ojos.',
          '🌑 CIERRE OPCIONAL — Si los ojos están muy cansados, ciérralos los últimos 5 segundos.',
          '✅ REANUDA — Vuelve a tu pantalla. Repite en 20 minutos.',
        ]),
        createdAt: now,
      ),

      ExercisesCompanion.insert(
        id: 'eyes_palming',
        name: 'Palmeo ocular',
        description:
            'Técnica de relajación ocular profunda usando el calor natural de las manos para relajar los músculos oculares.',
        benefit: 'Relaja músculos oculares',
        category: 'eyes',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 60,
        hasAiCoach: const Value(false),
        emoji: '🖐️',
        stepsJson: json.encode([
          '🤲 FROTA LAS MANOS — Frota las palmas entre sí 10–15 segundos hasta sentir calor.',
          '👁️ CIERRA LOS OJOS — Cierra los ojos suavemente.',
          '🙏 CUBRE LOS OJOS — Coloca las palmas calientes sobre los ojos sin presionar los globos oculares.',
          '🌑 OSCURIDAD Y CALOR — Relájate en esa oscuridad cálida durante 1 minuto.',
          '🌬️ RESPIRA — Haz 4–5 respiraciones lentas y profundas.',
          '👀 ABRE LENTAMENTE — Retira las manos y abre los ojos hacia una zona de poca luz.',
        ]),
        createdAt: now,
      ),

      // ══════════════════════════════════════════════════════════════════════
      //  MUÑECAS
      // ══════════════════════════════════════════════════════════════════════

      ExercisesCompanion.insert(
        id: 'wrist_extension_stretch',
        name: 'Estiramiento de muñecas',
        description:
            'Previene el síndrome del túnel carpiano estirando el nervio mediano y los tendones flexores tensados por escribir.',
        benefit: 'Previene túnel carpiano',
        category: 'wrists',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 120,
        hasAiCoach: const Value(true),
        emoji: '🤲',
        stepsJson: json.encode([
          '💪 POSICIÓN INICIAL — Extiende el brazo derecho al frente con la palma mirando hacia afuera (gesto de "stop").',
          '🤝 APLICA TENSIÓN — Con la mano izquierda, jala suavemente los dedos hacia tu cuerpo. Codo estirado.',
          '🔍 QUÉ DEBES SENTIR — Estiramiento en la palma, muñeca y antebrazo interno. Si hay hormigueo, reduce la intensidad.',
          '⏱️ MANTÉN 20 SEGUNDOS — Tensión suave y constante. Nunca apliques fuerza brusca.',
          '↩️ INVERSIÓN — Flexiona la muñeca hacia abajo y jala los dedos. Mantén 15 segundos.',
          '🔄 CAMBIA DE BRAZO — Repite con el brazo izquierdo. Finaliza sacudiendo las manos 10 segundos.',
        ]),
        createdAt: now,
      ),

      ExercisesCompanion.insert(
        id: 'wrist_circles',
        name: 'Círculos de muñeca',
        description:
            'Lubrica las articulaciones de la muñeca con líquido sinovial y mejora la circulación en manos y dedos.',
        benefit: 'Lubrica articulaciones',
        category: 'wrists',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 60,
        hasAiCoach: const Value(false),
        emoji: '⭕',
        stepsJson: json.encode([
          '✊ POSICIÓN INICIAL — Cierra ambas manos en puños suaves.',
          '🔄 CÍRCULOS A LA DERECHA — Describe círculos amplios con ambas muñecas en dirección horaria. 10 repeticiones.',
          '⏱️ RITMO LENTO — Cada círculo debe durar 2–3 segundos. Amplitud máxima.',
          '🔄 CÍRCULOS A LA IZQUIERDA — Invierte la dirección. Otros 10 círculos.',
          '🖐️ ABRE Y CIERRA — Abre los dedos completamente, mantén 2 segundos y ciérralos. Repite 5 veces.',
          '💨 SACUDIDA FINAL — Sacude ambas manos 10 segundos para activar la circulación.',
        ]),
        createdAt: now,
      ),

      // ══════════════════════════════════════════════════════════════════════
      //  RESPIRACIÓN
      // ══════════════════════════════════════════════════════════════════════

      ExercisesCompanion.insert(
        id: 'breathing_box',
        name: 'Respiración cuadrada',
        description:
            'Técnica usada por equipos de alto rendimiento para reducir el estrés. Regula el sistema nervioso en minutos.',
        benefit: 'Reduce estrés y ansiedad',
        category: 'breathing',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 240,
        hasAiCoach: const Value(false),
        emoji: '🌬️',
        stepsJson: json.encode([
          '🪑 PREPÁRATE — Siéntate con la espalda recta. Manos sobre los muslos. Cierra los ojos si puedes.',
          '💨 EXHALA PRIMERO — Exhala completamente para vaciar los pulmones.',
          '⬆️ INHALA — 4 SEGUNDOS — Inhala contando: 1… 2… 3… 4. Abdomen primero, luego pecho.',
          '⏸️ RETÉN — 4 SEGUNDOS — Mantén el aire: 1… 2… 3… 4. Hombros relajados.',
          '⬇️ EXHALA — 4 SEGUNDOS — Exhala lentamente: 1… 2… 3… 4. Suelta toda la tensión.',
          '⏸️ RETÉN VACÍO — 4 SEGUNDOS — Pulmones vacíos: 1… 2… 3… 4. Repite 4 ciclos mínimo.',
        ]),
        createdAt: now,
      ),
    ];
  }
}