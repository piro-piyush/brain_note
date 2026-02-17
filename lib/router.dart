import 'package:brain_note/views/docs/screen/document_screen.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

import 'views/home/screen/home_screen.dart';
import 'views/login/screen/login_screen.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: HomeScreen()),
  '/document/:id': (route) => MaterialPage(
    child: DocumentScreen(
      id: route.pathParameters['id'] ?? '',
    ),
  ),
});