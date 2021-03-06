import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;

import 'controller/user_controller.dart';

void main(List<String> args) async {
  final app = Router();
  app.mount('/users/', UserController().router);

  final server = await io.serve(app, 'localhost', 8080);

  print('Listening on http://${server.address.host}:${server.port}');
}
