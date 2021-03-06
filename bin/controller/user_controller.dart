import 'dart:convert';
import 'dart:io';

import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart' as shelf;

class UserController {
  final List _dataJson = jsonDecode(File('users.json').readAsStringSync());

  Router get router {
    final app = Router();
    app.get('/', (request) {
      return shelf.Response.ok(
        jsonEncode(_dataJson),
        headers: {'Content-Type': 'application/json'},
      );
    });

    app.get('/<id>', (request, id) {
      final user =
          _dataJson.firstWhere((x) => x['id'] == id, orElse: () => null);
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

    app.delete('/<id>', (request, id) {
      final user =
          _dataJson.firstWhere((x) => x['id'] == id, orElse: () => null);
      if (user == null) {
        return shelf.Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        _dataJson.remove(user);
        return shelf.Response.ok(
          '',
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    app.post('/', (shelf.Request request) async {
      final userJsonString = await request.readAsString();
      final userJson = jsonDecode(userJsonString);
      userJson['id'] = ((int.parse(_dataJson.last['id'])) + 1).toString();
      _dataJson.add(userJson);

      return Future.value(
        shelf.Response(
          201,
          body: jsonEncode(userJson),
          headers: {'Content-Type': 'application/json'},
        ),
      );
    });

    app.put('', (shelf.Request request) async {
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

      final index = _dataJson.indexWhere(
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

      _dataJson[index] = userJson;
      return shelf.Response.ok(
        '',
        headers: {'Content-Type': 'application/json'},
      );
    });

    return app;
  }
}
