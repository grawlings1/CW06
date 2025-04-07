import 'package:flutter/material.dart';
import 'package:cw06/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

enum AuthMode { SignIn, SignUp }

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  AuthMode _authMode = AuthMode.SignIn;
  String _email = '';
  String _password = '';
  String _errorMessage = '';

  void _toggleAuthMode() {
    setState(() {
      _authMode =
          _authMode == AuthMode.SignIn ? AuthMode.SignUp : AuthMode.SignIn;
      _errorMessage = '';
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      dynamic user;
      if (_authMode == AuthMode.SignIn) {
        user = await _authService.signIn(_email, _password);
      } else {
        user = await _authService.signUp(_email, _password);
      }
      if (user == null) {
        setState(() {
          _errorMessage = 'Authentication Error. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_authMode == AuthMode.SignIn ? 'Sign In' : 'Sign Up'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_errorMessage.isNotEmpty)
                    Text(_errorMessage, style: TextStyle(color: Colors.red)),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (val) => _email = val!.trim(),
                    validator: (val) =>
                        val != null && val.contains('@') ? null : 'Enter a valid email',
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onSaved: (val) => _password = val!,
                    validator: (val) =>
                        val != null && val.length >= 6 ? null : 'Minimum 6 characters required',
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(_authMode == AuthMode.SignIn ? 'Sign In' : 'Sign Up'),
                  ),
                  TextButton(
                      onPressed: _toggleAuthMode,
                      child: Text(_authMode == AuthMode.SignIn
                          ? 'Don’t have an account? Sign Up'
                          : 'Already have an account? Sign In'))
                ],
              )),
        ));
  }
}
