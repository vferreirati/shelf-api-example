import 'dart:convert';
import 'dart:io';

import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

void main(List<String> args) async {
  final dataString = await File('users.json').readAsString();
  final List dataJson = jsonDecode(dataString);
  final app = Router();

  app.get('/', (request) {
    return shelf.Response.ok('Hello world!');
  });

  app.get('/users', (request) {
    return shelf.Response.ok(
      jsonEncode(dataJson),
      headers: {'Content-Type': 'application/json'},
    );
  });

  app.get('/users/<id>', (request, id) {
    final user = dataJson.firstWhere((x) => x['id'] == id, orElse: () => null);
    if (user == null) {
      return shelf.Response.notFound(
        jsonEncode({'error': 'User not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      return shelf.Response.notFound(
        jsonEncode(user),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  app.delete('/users/<id>', (request, id) {
    final user = dataJson.firstWhere((x) => x['id'] == id, orElse: () => null);
    if (user == null) {
      return shelf.Response.notFound(
        jsonEncode({'error': 'User not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      dataJson.remove(user);
      return shelf.Response.ok(
        '',
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  app.post('/users', (shelf.Request request) async {
    final userJsonString = await request.readAsString();
    final userJson = jsonDecode(userJsonString);
    userJson['id'] = ((int.parse(dataJson.last['id'])) + 1).toString();
    dataJson.add(userJson);

    return Future.value(
      shelf.Response(
        201,
        body: jsonEncode(userJson),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  });

  app.put('/users', (shelf.Request request) async {
    final userJsonString = await request.readAsString();
    final userJson = jsonDecode(userJsonString);
    if (userJson['id'] == null) {
      return Future.value(
        shelf.Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        ),
      );
    }

    final index = dataJson.indexWhere(
      (x) => x['id'] == userJson['id'],
    );
    if (index == -1) {
      return Future.value(
        shelf.Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        ),
      );
    }

    dataJson[index] = userJson;
    return shelf.Response.ok(
      '',
      headers: {'Content-Type': 'application/json'},
    );
  });

  final server = await io.serve(app, 'localhost', 8080);

  print('Listening on http://${server.address.host}:${server.port}');
}
