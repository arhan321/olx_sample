import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'route/routes.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Email dan password tidak boleh kosong';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.triastrapersada.com/api/v1/account/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        String message = responseData['message'] ?? 'Login berhasil';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        final responseData = json.decode(response.body);
        String errorMessage = 'Login gagal';
        if (response.statusCode == 401) {
          errorMessage = 'Email atau password salah';
        } else if (response.statusCode == 500) {
          errorMessage = 'Terjadi kesalahan server';
        } else {
          errorMessage = responseData['message'] ?? 'Login gagal';
        }

        setState(() {
          _errorMessage = errorMessage;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan jaringan: $error';
      });
    }
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Konfirmasi Keluar'),
            content: Text('Apakah Anda ingin keluar dari aplikasi?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Tidak'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Ya'),
              ),
            ],
          ),
        ) ??
        false;

    return shouldExit;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          title: Text('Login'),
          backgroundColor: Colors.blue[800],
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Selamat Datang!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Masuk untuk melanjutkan',
                  style: TextStyle(fontSize: 16, color: Colors.blue[600]),
                ),
                SizedBox(height: 30),
                Container(
                  width: 300,
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email, color: Colors.blue[600]),
                      labelStyle: TextStyle(color: Colors.blue[900]),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: 300,
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock, color: Colors.blue[600]),
                      labelStyle: TextStyle(color: Colors.blue[900]),
                    ),
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 24),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: _login,
                      child: Text('Login', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                if (_errorMessage != null) ...[
                  SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Belum punya akun?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: Text('Daftar di sini'),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Implement "Forgot Password" feature here if needed
                  },
                  child: Text('Lupa Password?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
