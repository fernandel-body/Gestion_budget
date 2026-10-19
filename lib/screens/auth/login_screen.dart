import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();

  bool _isLogin = true;
  bool _loading = false;
  bool _hidePass = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _msg(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? Colors.red.shade700 : null,
      ),
    );
  }

  String _translate(String message) {
    final m = message.toLowerCase();
    if (m.contains('invalid login credentials')) {
      return 'Email ou mot de passe incorrect.';
    }
    if (m.contains('already registered')) {
      return 'Cet email est déjà utilisé.';
    }
    if (m.contains('password should be at least')) {
      return 'Mot de passe trop court (6 caractères minimum).';
    }
    if (m.contains('email not confirmed')) {
      return 'Email non confirmé. Vérifiez votre boîte mail.';
    }
    return message;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    try {
      if (_isLogin) {
        await _auth.signIn(email: email, password: password);
      } else {
        final res = await _auth.signUp(
          email: email,
          password: password,
          fullName: _nameCtrl.text.trim(),
        );
        if (res.session == null) {
          _msg('Compte créé. Vérifiez votre email pour confirmer.');
        }
      }
    } on AuthException catch (e) {
      _msg(_translate(e.message), error: true);
    } catch (_) {
      _msg('Erreur de connexion. Vérifiez votre accès Internet.', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (!email.contains('@')) {
      _msg('Saisissez d\'abord votre email.', error: true);
      return;
    }
    try {
      await _auth.resetPassword(email);
      _msg('Email de réinitialisation envoyé.');
    } on AuthException catch (e) {
      _msg(_translate(e.message), error: true);
    } catch (_) {
      _msg('Impossible d\'envoyer l\'email.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: primary,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(Icons.account_balance_wallet,
                                color: primary, size: 32),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Gestion Budget',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Suivez vos dépenses, gardez le contrôle de votre budget.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28)),
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _isLogin ? 'Connexion' : 'Créer un compte',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 20),
                              if (!_isLogin) ...[
                                TextFormField(
                                  controller: _nameCtrl,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'Nom complet',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Saisissez votre nom'
                                          : null,
                                ),
                                const SizedBox(height: 14),
                              ],
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.mail_outline),
                                ),
                                validator: (v) {
                                  final value = v?.trim() ?? '';
                                  if (value.isEmpty) {
                                    return 'Saisissez votre email';
                                  }
                                  if (!value.contains('@') ||
                                      !value.contains('.')) {
                                    return 'Email invalide';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: _hidePass,
                                decoration: InputDecoration(
                                  labelText: 'Mot de passe',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(_hidePass
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined),
                                    onPressed: () =>
                                        setState(() => _hidePass = !_hidePass),
                                  ),
                                ),
                                validator: (v) => (v == null || v.length < 6)
                                    ? '6 caractères minimum'
                                    : null,
                              ),
                              if (_isLogin)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed:
                                        _loading ? null : _forgotPassword,
                                    child: const Text('Mot de passe oublié ?'),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: _loading ? null : _submit,
                                child: _loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(_isLogin
                                        ? 'Se connecter'
                                        : 'Créer mon compte'),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _loading
                                    ? null
                                    : () =>
                                        setState(() => _isLogin = !_isLogin),
                                child: Text(_isLogin
                                    ? 'Pas de compte ? Inscrivez-vous'
                                    : 'Déjà un compte ? Connectez-vous'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
