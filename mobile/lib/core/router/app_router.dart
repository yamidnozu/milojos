import 'package:flutter/material.dart';

/// Configuración de rutas de la aplicación.
/// Por ahora expone un router simple, puede migrarse a GoRouter luego.
class AppRouter {
  static final router = RouterConfig<Object>(
    routerDelegate: DefaultRouterDelegate(),
    routeInformationParser: DefaultRouteParser(),
    backButtonDispatcher: RootBackButtonDispatcher(),
  );
}

class DefaultRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: const [
        MaterialPage(
          child: Scaffold(
            body: Center(
              child: Text('MilOjos App - Inicializando...'),
            ),
          ),
        ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}

class DefaultRouteParser extends RouteInformationParser<Object> {
  @override
  Future<Object> parseRouteInformation(RouteInformation routeInformation) async {
    return Object();
  }
}
