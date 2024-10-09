import 'dart:developer';
import 'package:dntgk/features/account/signup_page.dart';
import 'package:dntgk/features/product/product_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const Spacer(),
            const Text("Đăng nhập",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500)),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  labelStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                controller: _email,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "Mật khẩu",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  labelStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                controller: _password,
                obscureText: true,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                elevation: 8.0,
                backgroundColor: const Color(0xFF36D7FF),
              ),
              onPressed: () {
                _login();
              },
              child: const Text('Đăng nhập',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16)),
            ),
            const SizedBox(height: 15),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Bạn chưa có tài khoản? "),
              InkWell(
                onTap: () => goToSignup(context),
                child:
                    const Text("Đăng ký", style: TextStyle(color: Colors.red)),
              )
            ]),
            const Spacer()
          ],
        ),
      ),
    );
  }

  goToSignup(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignupScreen()),
      );

  goToHome(BuildContext context, User user) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProductPage(displayName: user.displayName)),
      );

  void _login() async {
    try {
      final user = await _auth.loginUserWithEmailAndPassword(
          _email.text, _password.text);
      if (user != null) {
        log("User Logged In");
        goToHome(context, user);
      }
    } on FirebaseAuthException catch (e) {
      log("FirebaseAuthException: ${e.code}"); // Log error code for debugging
      String errorMessage;
      if (e.code == 'wrong-password' || e.code == 'user-not-found') {
        errorMessage = "Bạn sai tài khoản hoặc mật khẩu, vui lòng đăng nhập lại";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Địa chỉ email không hợp lệ, vui lòng nhập lại";
      } else {
        errorMessage = e.message ?? "An unknown error occurred"; // Other Firebase error messages
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      log("Unknown error: $e"); // Log unknown errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An unknown error occurred"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}