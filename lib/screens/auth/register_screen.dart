import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../controllers/user_controller.dart';
import '../../utils/user_session.dart';
import '../../theme/halus.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

enum ActiveField { name, email, password, confirm, none }

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserController userController = Get.find();
  final UserSession userSession = Get.find();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  final GlobalKey _nameKey = GlobalKey();
  final GlobalKey _emailKey = GlobalKey();
  final GlobalKey _passwordKey = GlobalKey();
  final GlobalKey _confirmPasswordKey = GlobalKey();

  bool _isLoading = false;
  String? _error;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  ActiveField _activeField = ActiveField.name;
  double _bubbleYPosition = 0;

  bool _isEmailEnabled = false;
  bool _isPasswordEnabled = false;
  bool _isConfirmPasswordEnabled = false;

  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation =
        CurvedAnimation(parent: _animationController!, curve: Curves.easeOut);

    _nameFocus.addListener(() => _handleFocusChange(ActiveField.name, _nameKey));
    _emailFocus.addListener(() => _handleFocusChange(ActiveField.email, _emailKey));
    _passwordFocus.addListener(() => _handleFocusChange(ActiveField.password, _passwordKey));
    _confirmPasswordFocus.addListener(() => _handleFocusChange(ActiveField.confirm, _confirmPasswordKey));

    _nameController.addListener(() => _updateFieldState(ActiveField.name));
    _emailController.addListener(() => _updateFieldState(ActiveField.email));
    _passwordController.addListener(() => _updateFieldState(ActiveField.password));
    _confirmPasswordController.addListener(() => setState(() {}));


    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleFocusChange(ActiveField.name, _nameKey);
    });
  }

  void _handleFocusChange(ActiveField field, GlobalKey key) {
    if ((field == ActiveField.name && _nameFocus.hasFocus) ||
        (field == ActiveField.email && _emailFocus.hasFocus) ||
        (field == ActiveField.password && _passwordFocus.hasFocus) ||
        (field == ActiveField.confirm && _confirmPasswordFocus.hasFocus)) {
      if (key.currentContext != null) {
        final RenderBox renderBox =
            key.currentContext!.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero);
        setState(() {
          _activeField = field;
          _bubbleYPosition = position.dy + (renderBox.size.height / 2);
        });
        _animationController!.forward(from: 0);
      }
    }
  }

  void _updateFieldState(ActiveField field) {
    setState(() {
      if (field == ActiveField.name) {
        _isEmailEnabled = _nameController.text.isNotEmpty;
      } else if (field == ActiveField.email) {
        _isPasswordEnabled = GetUtils.isEmail(_emailController.text);
      } else if (field == ActiveField.password) {
        _isConfirmPasswordEnabled = _passwordController.text.length >= 6;
      }
    });
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _error = "Password tidak cocok!";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // ## PENYESUAIAN DISINI ##
        // Mengirim saldo sebagai angka (num) 0, bukan string "0"
        await userController.createUser(
          userCredential.user!.uid,
          _nameController.text.trim(),
          _emailController.text.trim(),
          0, // <-- Diubah dari "0" menjadi 0
        );
        await userSession.startSession(userCredential.user!.uid);
        Get.offAllNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'weak-password') {
          _error = 'Password yang diberikan terlalu lemah.';
        } else if (e.code == 'email-already-in-use') {
          _error = 'Akun sudah ada untuk email tersebut.';
        } else {
          _error = 'Terjadi kesalahan. Silakan coba lagi.';
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan. Silakan coba lagi.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool isRegisterButtonEnabled = _isConfirmPasswordEnabled &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomPaint(
        painter: SmoothLinePainter(),
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/GrowME.png', height: 100),
                    const SizedBox(height: 30),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    _buildTextField(
                        key: _nameKey,
                        controller: _nameController,
                        focusNode: _nameFocus,
                        labelText: 'Nama Lengkap',
                        icon: Icons.person,
                        enabled: true),
                    const SizedBox(height: 20),
                    _buildTextField(
                        key: _emailKey,
                        controller: _emailController,
                        focusNode: _emailFocus,
                        labelText: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        enabled: _isEmailEnabled),
                    const SizedBox(height: 20),
                    _buildTextField(
                        key: _passwordKey,
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        labelText: 'Password',
                        icon: Icons.lock,
                        obscureText: !_passwordVisible,
                        enabled: _isPasswordEnabled,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        )),
                    const SizedBox(height: 20),
                    _buildTextField(
                        key: _confirmPasswordKey,
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocus,
                        labelText: 'Konfirmasi Password',
                        icon: Icons.lock_outline,
                        obscureText: !_confirmPasswordVisible,
                        enabled: _isConfirmPasswordEnabled,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmPasswordVisible = !_confirmPasswordVisible;
                            });
                          },
                        )),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: isRegisterButtonEnabled ? _register : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: theme.colorScheme.secondary,
                              disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Daftar',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Sudah punya akun? Login',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_activeField != ActiveField.none)
              AnimatedBuilder(
                animation: _animation!,
                builder: (context, child) {
                  return Positioned(
                    top: _bubbleYPosition -
                        (15 * _animation!.value),
                    left: 20,
                    child: Opacity(
                      opacity: _animation!.value,
                      child: CustomPaint(
                        painter: BubblePainter(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Text(
                            _getBubbleText(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required GlobalKey key,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    Widget? suffixIcon,
  }) {
    return TextField(
      key: key,
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
            color: enabled ? Colors.white : Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(icon,
            color: enabled ? Colors.white70 : Colors.white.withOpacity(0.5)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      style: TextStyle(
          color: enabled ? Colors.white : Colors.white.withOpacity(0.7)),
    );
  }

  String _getBubbleText() {
    switch (_activeField) {
      case ActiveField.name:
        return 'Masukkan nama lengkapmu, ya!';
      case ActiveField.email:
        return 'Pastikan emailnya aktif, oke?';
      case ActiveField.password:
        return 'Buat password yang kuat, minimal 6 karakter.';
      case ActiveField.confirm:
        return 'Ulangi password di atas.';
      default:
        return '';
    }
  }
}

class BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(8)))
      ..moveTo(size.width - 20, size.height)
      ..relativeLineTo(5, 5)
      ..relativeLineTo(5, -5)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}