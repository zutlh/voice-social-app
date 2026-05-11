import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/app/theme.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  int _countdown = 0;
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  bool _isValidPhone(String phone) {
    return phone.length == 11 && RegExp(r'^\d+$').hasMatch(phone);
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (!_isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入11位手机号')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).sendCode(phone);
      if (!mounted) return;
      setState(() {
        _countdown = 60;
        _loading = false;
      });
      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发送失败: $e')),
      );
    }
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_countdown > 0) _countdown--;
      });
      return _countdown > 0;
    });
  }

  Future<void> _login() async {
    final code = _codeController.text.trim();
    if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入6位验证码')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).login(
        _phoneController.text.trim(),
        code,
      );
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登录失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    final canSendCode = _isValidPhone(phone) && _countdown == 0 && !_loading;
    final canLogin = code.length == 6 && !_loading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Card(
            color: AppTheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '语音社交',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '欢迎回来',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    decoration: const InputDecoration(
                      labelText: '手机号',
                      hintText: '请输入11位手机号',
                      counterText: '',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: const InputDecoration(
                            labelText: '验证码',
                            hintText: '6位验证码',
                            counterText: '',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: canSendCode ? _sendCode : null,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(120, 52),
                            backgroundColor: _countdown > 0
                                ? AppTheme.seatLocked
                                : AppTheme.primary,
                            disabledBackgroundColor:
                                AppTheme.seatLocked.withValues(alpha: 0.5),
                          ),
                          child: Text(
                            _countdown > 0 ? '${_countdown}s' : '发送验证码',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: canLogin ? _login : null,
                      child: _loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              '登录',
                              style: TextStyle(fontSize: 18),
                            ),
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
