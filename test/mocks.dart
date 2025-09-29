// Ubicación: test/mocks.dart

import 'package:mockito/annotations.dart';
import 'package:hcc_app/providers/user_provider.dart';

// Directiva OBLIGATORIA para que el generador sepa dónde escribir el fichero.
// Le dice a Dart: "Este fichero tiene una parte que será generada y se llamará 'mocks.mocks.dart'".
// ignore: part_of_non_part
part 'mocks.mocks.dart';

// Anotación OBLIGATORIA que le dice a build_runner QUÉ clases debe mockear.
// En este caso, solo necesitamos mockear UserProvider.
@GenerateMocks([UserProvider])
void main() {} // Puedes dejar esto vacío, es solo un "soporte" para la anotación.
