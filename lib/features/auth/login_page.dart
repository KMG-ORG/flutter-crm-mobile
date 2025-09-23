// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../core/app_routes.dart';
// import '../../services/auth_service.dart';

// class LoginPage extends StatefulWidget {
// const LoginPage({super.key});

// @override
// State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
// final _formKey = GlobalKey<FormState>();
// final _emailCtrl = TextEditingController();
// final _passwordCtrl = TextEditingController();
// bool _loading = false;

// Future<void> _submit() async {
// if (!_formKey.currentState!.validate()) return;
// setState(() => _loading = true);
// final auth = Provider.of<AuthService>(context, listen: false);
// final success = await auth.login(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
// setState(() => _loading = false);
// if (success) {
// Navigator.pushReplacementNamed(context, AppRoutes.home);
// } else {
// ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed')));
// }
// }

// @override
// void dispose() {
// _emailCtrl.dispose();
// _passwordCtrl.dispose();
// super.dispose();
// }

// @override
// Widget build(BuildContext context) {
// return Scaffold(
// body: Center(
// child: ConstrainedBox(
// constraints: const BoxConstraints(maxWidth: 420),
// child: Padding(
// padding: const EdgeInsets.all(24.0),
// child: Card(
// elevation: 6,
// child: Padding(
// padding: const EdgeInsets.all(16.0),
// child: Form(
// key: _formKey,
// child: Column(
// mainAxisSize: MainAxisSize.min,
// children: [
// const Text('Welcome', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
// const SizedBox(height: 16),
// TextFormField(
// controller: _emailCtrl,
// decoration: const InputDecoration(labelText: 'Email'),
// validator: (v) => (v == null || v.isEmpty) ? 'Enter email' : null,
// ),
// const SizedBox(height: 8),
// TextFormField(
// controller: _passwordCtrl,
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _controller = TextEditingController();

  void _saveToken() async {
    final token = _controller.text.trim();
    if (token.isNotEmpty) {
      await context.read<AuthService>().saveToken(token);

      // Navigate to home page
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/home");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid token")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Token")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Access Token",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveToken,
              child: const Text("Save Token"),
            ),
          ],
        ),
      ),
    );
  }
}
