import 'dart:convert';
import 'package:drift/drift.dart';
import '../app_database.dart';

class ExercisesSeedData {
  static List<ExercisesCompanion> get all {
    final now = DateTime.now().millisecondsSinceEpoch;

    return [
      // ── CUELLO ────────────────────────────────────────────────────────────
      ExercisesCompanion.insert(
        id: 'neck_lateral_tilt',
        name: 'Inclinación lateral de cuello',
        description:
            'Alivia la tensión acumulada en el cuello por horas frente a la pantalla. Ideal para hacer cada 45 minutos de trabajo.',
        benefit: 'Reduce tensión cervical',
        category: 'neck',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 120,
        hasAiCoach: const Value(true),
        emoji: '🦒',
        stepsJson: json.encode([
          '🪑 POSICIÓN INICIAL — Siéntate en el borde de la silla con la espalda recta. Coloca ambos pies planos en el suelo. Relaja los hombros alejándolos de las orejas.',
          '➡️ LADO DERECHO — Inhala profundo. Al exhalar, inclina lentamente la cabeza hacia el hombro derecho. No levantes el hombro para alcanzar la oreja. El estiramiento debe sentirse en el lado izquierdo del cuello.',
          '⏱️ MANTÉN 20 SEGUNDOS — Respira normalmente. Con cada exhalación intenta relajar un poco más. Siente cómo se estira el músculo esternocleidomastoideo (el músculo largo del cuello).',
          '↩️ VUELVE AL CENTRO — Inhala y regresa la cabeza al centro muy lentamente. Nunca hagas movimientos bruscos con el cuello.',
          '⬅️ LADO IZQUIERDO — Repite el mismo proceso hacia el hombro izquierdo. Mantén otros 20 segundos respirando profundo.',
          '🔄 REPITE — Realiza 3 repeticiones por cada lado. Al terminar, rota suavemente la cabeza haciendo pequeños círculos para relajar la zona.',
        ]),
        createdAt: now,
      ),
      ExercisesCompanion.insert(
        id: 'neck_rotation',
        name: 'Rotación de cuello',
        description:
            'Moviliza las vértebras cervicales y mejora el rango de movimiento. Perfecto para contrarrestar la rigidez de mirar una pantalla fija.',
        benefit: 'Mejora movilidad cervical',
        category: 'neck',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 90,
        hasAiCoach: const Value(true),
        emoji: '🔄',
        stepsJson: json.encode([
          '🪑 POSICIÓN INICIAL — Siéntate erguido. Mantén la barbilla paralela al suelo durante todo el ejercicio. Los hombros deben estar completamente relajados y quietos.',
          '➡️ GIRA A LA DERECHA — Exhala y gira la cabeza lentamente hacia la derecha hasta donde sea cómodo. No fuerces más allá de tu límite natural. Deberías sentir un leve estiramiento en el lado izquierdo del cuello.',
          '⏱️ MANTÉN 10 SEGUNDOS — Respira normalmente. Mira hacia atrás sin mover los hombros. Si sientes dolor o mareo, reduce el rango de movimiento.',
          '↩️ CENTRO — Inhala y regresa al centro con el mismo ritmo lento. Nunca uses rebotes o movimientos rápidos.',
          '⬅️ GIRA A LA IZQUIERDA — Repite hacia el lado izquierdo. Mantén otros 10 segundos.',
          '🔄 REPITE 5 VECES POR LADO — Cada repetición puedes intentar aumentar ligeramente el rango si te sientes cómodo. Al terminar, baja la cabeza suavemente hacia el pecho y mantén 5 segundos.',
        ]),
        createdAt: now,
      ),
      ExercisesCompanion.insert(
        id: 'neck_chin_tuck',
        name: 'Retracción de mentón',
        description:
            'Corrige la postura de "cabeza adelantada" que desarrollan el 90% de las personas que trabajan con computadora. Un ejercicio simple pero muy efectivo.',
        benefit: 'Corrige postura de cuello',
        category: 'neck',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 60,
        hasAiCoach: const Value(true),
        emoji: '🧠',
        stepsJson: json.encode([
          '🪑 POSICIÓN INICIAL — Siéntate con la espalda recta mirando al frente. Imagina que una cuerda jala la parte superior de tu cabeza hacia el techo.',
          '👁️ BUSCA UN PUNTO DE REFERENCIA — Elige un punto fijo al frente a la altura de tus ojos. Esto te ayudará a mantener la cabeza nivelada durante el movimiento.',
          '↩️ RETRAE EL MENTÓN — Sin mover los hombros y sin bajar la cabeza, lleva el mentón hacia atrás como si quisieras hacer una doble papada. Deberías sentir un leve estiramiento en la base del cráneo.',
          '⏱️ MANTÉN 5 SEGUNDOS — Respira normalmente. La sensación correcta es de "elongación" en la nuca, no de dolor.',
          '➡️ SUELTA Y REPITE — Regresa a la posición inicial y repite. La diferencia entre la posición normal y la corregida es la que debes trabajar.',
          '🔄 10 REPETICIONES — Realiza 10 repeticiones lentas y controladas. Este ejercicio es más efectivo si lo haces varias veces al día.',
        ]),
        createdAt: now,
      ),

      // ── HOMBROS ───────────────────────────────────────────────────────────
      ExercisesCompanion.insert(
        id: 'shoulder_rolls',
        name: 'Rotación de hombros',
        description:
            'Descomprime los hombros y mejora la circulación en la zona superior. Muy efectivo para liberar la tensión acumulada por teclear durante horas.',
        benefit: 'Alivia tensión en hombros',
        category: 'shoulders',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 60,
        hasAiCoach: const Value(true),
        emoji: '🙆',
        stepsJson: json.encode([
          '🪑 POSICIÓN INICIAL — Siéntate o párate cómodamente. Coloca los brazos relajados a los costados del cuerpo. Respira profundo para preparar la zona.',
          '⬆️ ELEVA LOS HOMBROS — Inhala mientras subes ambos hombros hacia las orejas lo más que puedas. Mantén esta posición 2 segundos.',
          '🔙 ROTA HACIA ATRÁS — Exhala mientras llevas los hombros hacia atrás y luego hacia abajo, completando un círculo amplio. Imagina que quieres unir los omóplatos detrás de tu espalda.',
          '⏱️ RITMO LENTO — Cada círculo completo debe durar 3-4 segundos. No hagas los movimientos rápidos. La lentitud es lo que genera el beneficio.',
          '🔄 10 ROTACIONES HACIA ATRÁS — Completa 10 rotaciones hacia atrás. Deberías sentir un ligero crujido o chasquido — es normal si no hay dolor.',
          '➡️ 10 ROTACIONES HACIA ADELANTE — Repite en dirección contraria. Al terminar, sacude los brazos suavemente para relajar toda la zona.',
        ]),
        createdAt: now,
      ),
      ExercisesCompanion.insert(
        id: 'chest_opener',
        name: 'Apertura de pecho',
        description:
            'Contrarresta la postura encorvada típica del trabajo de escritorio. Abre el pecho y fortalece los músculos posturales de la espalda alta.',
        benefit: 'Corrige postura encorvada',
        category: 'shoulders',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 120,
        hasAiCoach: const Value(true),
        emoji: '🦅',
        stepsJson: json.encode([
          '🪑 POSICIÓN INICIAL — Siéntate al borde de la silla, alejado del respaldo. Pies planos en el suelo, separados al ancho de las caderas.',
          '🤝 ENTRELAZA LOS DEDOS — Lleva ambas manos detrás de la nuca (no detrás de la cabeza). Los codos deben apuntar hacia los lados.',
          '🦅 ABRE EL PECHO — Inhala profundo mientras llevas los codos hacia atrás y el pecho hacia adelante. Imagina que quieres mostrar el logo de tu camiseta al frente.',
          '⏱️ MANTÉN 20 SEGUNDOS — Sigue respirando normalmente. Con cada inhalación sientes el pecho abrirse más. Con cada exhalación los hombros se relajan más hacia atrás.',
          '🔍 QUÉ DEBES SENTIR — Estiramiento en el pecho (pectorales) y en la parte frontal de los hombros. Si sientes dolor en el cuello, baja ligeramente el mentón.',
          '🔄 REPITE 4-5 VECES — Descansa 5 segundos entre cada repetición. Con la práctica diaria, este ejercicio mejora visiblemente la postura en 2-3 semanas.',
        ]),
        createdAt: now,
      ),

      // ── ESPALDA ───────────────────────────────────────────────────────────
      ExercisesCompanion.insert(
        id: 'back_cat_cow',
        name: 'Gato-vaca en silla',
        description:
            'Versión adaptada para silla del clásico ejercicio de yoga. Moviliza toda la columna vertebral y libera la tensión lumbar acumulada.',
        benefit: 'Moviliza toda la columna',
        category: 'back',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 120,
        hasAiCoach: const Value(true),
        emoji: '🐱',
        stepsJson: json.encode([
          '🪑 POSICIÓN INICIAL — Siéntate al borde de la silla. Pies planos en el suelo, rodillas a 90°. Coloca las manos sobre las rodillas con los codos ligeramente doblados.',
          '🐄 POSICIÓN VACA (inhalación) — Inhala profundo. Mientras inhalas, arquea la espalda hacia adelante, lleva el pecho hacia el frente y la mirada ligeramente hacia arriba. La pelvis se inclina hacia adelante.',
          '🐱 POSICIÓN GATO (exhalación) — Exhala completamente. Mientras exhalas, redondea toda la espalda hacia afuera, mete el ombligo hacia la columna y lleva la mirada hacia el ombligo. La pelvis se inclina hacia atrás.',
          '🌊 FLUYE CON LA RESPIRACIÓN — El movimiento lo dicta tu respiración, no al revés. Inhalación = vaca. Exhalación = gato. Nunca contengas el aliento.',
          '⏱️ RITMO SUAVE — Cada ciclo completo (vaca + gato) debe durar 6-8 segundos. Muévete como olas del mar, sin pausas bruscas entre posiciones.',
          '🔄 10 CICLOS COMPLETOS — Al terminar, quédate en posición neutral y nota la diferencia en tu columna. Deberías sentirla más libre y menos rígida.',
        ]),
        createdAt: now,
      ),
      ExercisesCompanion.insert(
        id: 'back_seated_twist',
        name: 'Torsión espinal sentado',
        description:
            'Descomprime los discos intervertebrales y aumenta la flexibilidad rotacional. Muy recomendado para personas que pasan más de 4 horas sentadas.',
        benefit: 'Descomprime la columna',
        category: 'back',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 120,
        hasAiCoach: const Value(false),
        emoji: '🌀',
        stepsJson: json.encode([
          '🪑 POSICIÓN INICIAL — Siéntate erguido sin apoyar la espalda en el respaldo. Los pies bien plantados en el suelo. Inhala para alargar la columna.',
          '⬅️ GIRA A LA IZQUIERDA — Coloca la mano derecha en el muslo izquierdo. La mano izquierda puede apoyarse en el respaldo de la silla si la alcanzas.',
          '🌀 REALIZA LA TORSIÓN — Exhala mientras giras el torso hacia la izquierda desde la cintura. La cabeza acompaña el movimiento mirando por encima del hombro izquierdo.',
          '⏱️ MANTÉN 25-30 SEGUNDOS — Respira profundo. Con cada inhalación crece un poco más hacia arriba. Con cada exhalación gira un poco más si el cuerpo lo permite. Nunca fuerces.',
          '🔍 QUÉ DEBES SENTIR — Una sensación de torsión agradable a lo largo de toda la columna. Si sientes dolor agudo o punzante, reduce el rango de movimiento inmediatamente.',
          '➡️ REPITE AL LADO DERECHO — Regresa al centro con una inhalación y repite hacia el lado derecho. Mantén otros 25-30 segundos.',
        ]),
        createdAt: now,
      ),

      // ── OJOS ──────────────────────────────────────────────────────────────
      ExercisesCompanion.insert(
        id: 'eyes_20_20_20',
        name: 'Regla 20-20-20',
        description:
            'El método más respaldado científicamente para prevenir la fatiga visual digital. Cada 20 minutos de pantalla, 20 segundos mirando a 20 pies (6 metros).',
        benefit: 'Reduce fatiga visual digital',
        category: 'eyes',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 20,
        hasAiCoach: const Value(false),
        emoji: '👁️',
        stepsJson: json.encode([
          '⏰ CUÁNDO APLICARLA — Cada 20 minutos de trabajo continuo frente a la pantalla. Puedes configurar una alarma en ErgoFit para que te recuerde.',
          '👀 BUSCA UN PUNTO LEJANO — Identifica un objeto a al menos 6 metros de distancia (una ventana, un cuadro en la pared, un árbol afuera). Cuanto más lejos, mejor.',
          '🎯 ENFOCA ESE PUNTO — Mira directamente ese objeto durante 20 segundos completos. El músculo del ojo (ciliar) necesita relajarse después de enfocar de cerca por mucho tiempo.',
          '😌 PARPADEA CONSCIENTEMENTE — Cuando miramos pantallas parpadeamos un 60% menos de lo normal. Durante estos 20 segundos, parpadea cada 3-4 segundos para hidratar los ojos.',
          '🌑 CIERRE OPCIONAL — Si los ojos están muy cansados, ciérralos suavemente los últimos 5 segundos. La oscuridad total da el mayor descanso.',
          '✅ REANUDA TU TRABAJO — Vuelve a tu pantalla. Tu enfoque y productividad deberían estar un poco más frescos. Recuerda: en 20 minutos, repite.',
        ]),
        createdAt: now,
      ),
      ExercisesCompanion.insert(
        id: 'eyes_palming',
        name: 'Palmeo ocular',
        description:
            'Técnica de relajación ocular profunda usada en yoga y optometría conductual. El calor de las palmas relaja los músculos oculares tensos.',
        benefit: 'Relaja músculos oculares',
        category: 'eyes',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 60,
        hasAiCoach: const Value(false),
        emoji: '🖐️',
        stepsJson: json.encode([
          '🤲 PREPARA LAS MANOS — Frota vigorosamente las palmas de las manos entre sí durante 10-15 segundos hasta que sientas calor en ellas. Ese calor es lo que va a relajar tus ojos.',
          '👁️ CIERRA LOS OJOS — Cierra los ojos suavemente. No los aprietes.',
          '🙏 CUBRE LOS OJOS — Coloca las palmas calientes sobre los ojos sin presionar los globos oculares. Los dedos deben descansar en la frente. Que quede oscuridad total.',
          '🌑 OSCURIDAD Y CALOR — Relájate en esa oscuridad cálida. Si ves patrones de luz o colores, es normal — son las células de la retina descansando.',
          '🌬️ RESPIRA PROFUNDO — Haz 4-5 respiraciones lentas y profundas. Con cada exhalación imagina que la tensión sale de tus ojos y de tu frente.',
          '👀 ABRE LENTAMENTE — Retira las manos y abre los ojos muy despacio hacia una zona de poca luz. Notarás los colores más vívidos y la visión más nítida.',
        ]),
        createdAt: now,
      ),

      // ── MUÑECAS ───────────────────────────────────────────────────────────
      ExercisesCompanion.insert(
        id: 'wrist_extension_stretch',
        name: 'Estiramiento de muñecas',
        description:
            'El ejercicio más importante para prevenir el síndrome del túnel carpiano. Estira el nervio mediano y los tendones flexores que se tensan al escribir.',
        benefit: 'Previene túnel carpiano',
        category: 'wrists',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 120,
        hasAiCoach: const Value(true),
        emoji: '🤲',
        stepsJson: json.encode([
          '💪 POSICIÓN INICIAL — Extiende el brazo derecho al frente, paralelo al suelo, con la palma mirando hacia afuera (como haciendo el gesto de "stop").',
          '🤝 APLICA LA TENSIÓN — Con la mano izquierda, toma los dedos de la mano derecha y jálalos suavemente hacia tu cuerpo. El codo debe permanecer estirado.',
          '🔍 QUÉ DEBES SENTIR — Estiramiento en la palma de la mano, muñeca y antebrazo interno. Si sientes hormigueo en los dedos, reduce la intensidad — es señal de que estás cerca del límite.',
          '⏱️ MANTÉN 20 SEGUNDOS — Respira normalmente. La tensión debe ser suave pero constante. Nunca apliques fuerza brusca en las articulaciones de la muñeca.',
          '↩️ INVERSIÓN — Ahora flexiona la muñeca hacia abajo (dedos apuntando al suelo) y usa la otra mano para jalar suavemente los dedos hacia ti. Mantén otros 15 segundos.',
          '🔄 REPITE CON LA IZQUIERDA — Cambia de brazo y repite todo el proceso. Finaliza sacudiendo suavemente las manos durante 10 segundos.',
        ]),
        createdAt: now,
      ),
      ExercisesCompanion.insert(
        id: 'wrist_circles',
        name: 'Círculos de muñeca',
        description:
            'Lubrica las articulaciones de la muñeca con líquido sinovial y mejora la circulación en manos y dedos. Ideal antes y después de sesiones largas de escritura.',
        benefit: 'Lubrica articulaciones',
        category: 'wrists',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 60,
        hasAiCoach: const Value(false),
        emoji: '⭕',
        stepsJson: json.encode([
          '✊ POSICIÓN INICIAL — Cierra ambas manos en puños suaves (no apretados). Los codos pueden estar flexionados a 90° o los brazos extendidos al frente.',
          '🔄 CÍRCULOS HACIA LA DERECHA — Describe círculos amplios y lentos con ambas muñecas en dirección horaria. El movimiento viene de la muñeca, no del codo ni del hombro.',
          '⏱️ 10 CÍRCULOS LENTOS — Cada círculo debe durar 2-3 segundos. La amplitud debe ser máxima — lleva la muñeca a todos sus rangos de movimiento.',
          '🔄 CÍRCULOS HACIA LA IZQUIERDA — Invierte la dirección. Otros 10 círculos en sentido antihorario. Deberías escuchar o sentir pequeños chasquidos — es normal y beneficioso.',
          '🖐️ ABRE Y CIERRA — Abre los dedos completamente separándolos, mantén 2 segundos, y ciérralos en puño. Repite 5 veces para activar la circulación.',
          '💨 SACUDIDA FINAL — Sacude ambas manos durante 10 segundos como si estuvieras secándolas sin toalla. Esto termina de activar la circulación.',
        ]),
        createdAt: now,
      ),

      // ── RESPIRACIÓN ───────────────────────────────────────────────────────
      ExercisesCompanion.insert(
        id: 'breathing_box',
        name: 'Respiración cuadrada',
        description:
            'Técnica de respiración usada por Navy SEALs y atletas de élite para reducir el estrés en segundos. Regula el sistema nervioso autónomo y mejora la concentración.',
        benefit: 'Reduce estrés y ansiedad',
        category: 'breathing',
        difficulty: 'easy',
        position: 'seated',
        durationSeconds: 240,
        hasAiCoach: const Value(false),
        emoji: '🌬️',
        stepsJson: json.encode([
          '🪑 PREPÁRATE — Siéntate con la espalda recta y los pies en el suelo. Coloca las manos sobre los muslos con las palmas hacia arriba. Cierra los ojos si te resulta cómodo.',
          '💨 EXHALA PRIMERO — Antes de comenzar, exhala completamente vaciando los pulmones. Esto es importante para sincronizar el ciclo correctamente.',
          '⬆️ INHALA — 4 SEGUNDOS — Inhala lentamente por la nariz contando mentalmente: 1... 2... 3... 4. Siente cómo se expande primero el abdomen, luego el pecho.',
          '⏸️ RETÉN — 4 SEGUNDOS — Mantén el aire dentro contando: 1... 2... 3... 4. No te pongas rígido — mantén los hombros relajados.',
          '⬇️ EXHALA — 4 SEGUNDOS — Exhala lentamente por la boca contando: 1... 2... 3... 4. Imagina que sueltas toda la tensión con el aire.',
          '⏸️ RETÉN VACÍO — 4 SEGUNDOS — Mantén los pulmones vacíos contando: 1... 2... 3... 4. Luego reinicia el ciclo. Completa 4 ciclos mínimo — notarás la diferencia desde el segundo ciclo.',
        ]),
        createdAt: now,
      ),
    ];
  }
}