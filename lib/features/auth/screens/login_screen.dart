import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // ✅ Your Logo
  final String logoUrl = 'https://i.ibb.co/JjFk0xCJ/vdaralogo.png';

  // ✅ School Bus Image
  final String busImageUrl =
      'https://static.vecteezy.com/system/resources/thumbnails/007/586/543/small/map-pointer-with-yellow-school-bus-icon-illustration-vector.jpg';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF0D47A1),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🚌 School Bus Image
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Image.network(
                      busImageUrl,
                      height: 100,
                      width: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.directions_bus,
                          size: 70,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🏷️ Logo
                  Image.network(
                    logoUrl,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'dara',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Safe School Transport',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Login Card
                  Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1A237E),
                                  width: 2,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1A237E),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // TODO: Forgot password functionality
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Color(0xFF1A237E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () async {
                                      final success = await authProvider.login(
                                        _emailController.text.trim(),
                                        _passwordController.text.trim(),
                                      );
                                      if (success && mounted) {
                                        Fluttertoast.showToast(
                                          msg: 'Welcome back!',
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white,
                                          toastLength: Toast.LENGTH_SHORT,
                                        );
                                      } else if (!success && mounted) {
                                        Fluttertoast.showToast(
                                          msg: 'Invalid email or password.',
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          toastLength: Toast.LENGTH_SHORT,
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A237E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 4,
                              ),
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Eugene-AI',   // ✅ Updated
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white54,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ],
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