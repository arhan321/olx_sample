import 'package:flutter/material.dart';
import '/login.dart';
import '/register.dart';
import '/main.dart';
import '/add_car.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String addCar = '/add_car';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case home:
        return MaterialPageRoute(
            builder: (_) => MyHomePage(title: 'Daftar Kendaraan Dijual'));
      case addCar:
        return MaterialPageRoute(builder: (_) => AddCarPage());
      default:
        // Jika route tidak ditemukan, arahkan ke halaman login
        return MaterialPageRoute(builder: (_) => LoginPage());
    }
  }
}
