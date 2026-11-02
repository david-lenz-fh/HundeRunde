import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:starter_flutter/services/pocketbase_service.dart'; // Passe den Pfad an dein Projekt an

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // Nur für Registrierung

  bool _isLogin = true; // True = Login-Modus, False = Registrierungs-Modus
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        await PocketBaseService.instance.login(_emailController.text.trim(),_passwordController.text.trim());
      } else {
        await PocketBaseService.instance.client.collection('users').create(body: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'passwordConfirm': _passwordController.text.trim(),
          'name': _nameController.text.trim(),
        });

        await PocketBaseService.instance.client.collection('users').authWithPassword(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
      }
    } on ClientException catch (e) {
      setState(() {
        _errorMessage = e.response['message'] ?? 'Ein Fehler ist aufgetreten.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Netzwerkfehler oder Server nicht erreichbar.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo oder App-Titel
                  const Icon(Icons.pets, size: 80, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    _isLogin ? 'Willkommen zurück!' : 'Account erstellen',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (!_isLogin && (value == null || value.isEmpty)) {
                          return 'Bitte gib deinen Namen ein';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // E-Mail-Feld
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-Mail',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Bitte gib eine gültige E-Mail ein';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Passwort-Feld
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Passwort',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 8) {
                        return 'Passwort muss mindestens 8 Zeichen lang sein';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit-Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isLogin ? 'Einloggen' : 'Registrieren',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Umschalter zwischen Login und Registrierung
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _errorMessage = null;
                      });
                    },
                    child: Text(
                      _isLogin ? 'Noch keinen Account? Registrieren':'Bereits einen Account? Einloggen',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}