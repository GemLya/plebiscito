import 'package:flutter_test/flutter_test.dart';
import 'package:plebiscito/modelos/opcion_votacion.dart';
import 'package:plebiscito/modelos/votacion.dart';
import 'package:plebiscito/logica/resultado_voto.dart';
import 'package:plebiscito/logica/servicio_votacion.dart';

Votacion _crearVotacionDePrueba({DateTime? fechaCierre}) {
  return Votacion(
    pregunta: 'Pregunta de prueba',
    opciones: [
      OpcionVotacion(id: 'op1', texto: 'Opcion 1'),
      OpcionVotacion(id: 'op2', texto: 'Opcion 2'),
    ],
    fechaCierre: fechaCierre ?? DateTime.now().add(const Duration(days: 7)),
  );
}

void main() {
  test('registrar un voto valido incrementa el contador de esa opcion', () {
    final votacion = _crearVotacionDePrueba();
    final servicio = ServicioVotacion(votacion);

    final resultado = servicio.registrarVoto(idUsuario: 'user1', idOpcion: 'op1');

    expect(resultado, ResultadoVoto.exitoso);
    expect(votacion.opciones[0].votos, 1);
  });

  test('votar por una opcion que no existe regresa opcionInvalida', () {
    final votacion = _crearVotacionDePrueba();
    final servicio = ServicioVotacion(votacion);

    final resultado = servicio.registrarVoto(idUsuario: 'user1', idOpcion: 'no-existe');

    expect(resultado, ResultadoVoto.opcionInvalida);
  });


  test('un mismo usuario no puede votar dos veces', () {
    final votacion = _crearVotacionDePrueba();
    final servicio = ServicioVotacion(votacion);

    servicio.registrarVoto(idUsuario: 'user1', idOpcion: 'op1');
    final segundoIntento = servicio.registrarVoto(idUsuario: 'user1', idOpcion: 'op2');

    expect(segundoIntento, ResultadoVoto.usuarioYaVoto);
    expect(votacion.opciones[1].votos, 0); // op2 no debio incrementarse
  });



  test('calcula el porcentaje de cada opcion correctamente', () {
    final votacion = _crearVotacionDePrueba();
    final servicio = ServicioVotacion(votacion);

    servicio.registrarVoto(idUsuario: 'u1', idOpcion: 'op1');
    servicio.registrarVoto(idUsuario: 'u2', idOpcion: 'op1');
    servicio.registrarVoto(idUsuario: 'u3', idOpcion: 'op1');
    servicio.registrarVoto(idUsuario: 'u4', idOpcion: 'op2');

    final resultados = servicio.obtenerResultados();
    final op1 = resultados.firstWhere((r) => r.opcion.id == 'op1');
    final op2 = resultados.firstWhere((r) => r.opcion.id == 'op2');

    expect(op1.porcentaje, 75.0);
    expect(op2.porcentaje, 25.0);
  });

  test('si no hay ningun voto, todos los porcentajes son 0', () {
    final votacion = _crearVotacionDePrueba();
    final servicio = ServicioVotacion(votacion);

    final resultados = servicio.obtenerResultados();

    expect(resultados.every((r) => r.porcentaje == 0), true);
  });


  test('determinarGanador regresa la opcion con mas votos', () {
    final votacion = _crearVotacionDePrueba();
    final servicio = ServicioVotacion(votacion);

    servicio.registrarVoto(idUsuario: 'u1', idOpcion: 'op1');
    servicio.registrarVoto(idUsuario: 'u2', idOpcion: 'op1');
    servicio.registrarVoto(idUsuario: 'u3', idOpcion: 'op2');

    final ganadores = servicio.determinarGanador();

    expect(ganadores.length, 1);
    expect(ganadores.first.id, 'op1');
  });
}