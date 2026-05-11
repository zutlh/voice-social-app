import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import '../models/user.dart';

class AuthState {
  final bool isLoggedIn;
  final int? userId;
  final String? accessToken;
  final String? refreshToken;
  final User? user;

  const AuthState({this.isLoggedIn = false, this.userId, this.accessToken, this.refreshToken, this.user});
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _loadTokens();
    return const AuthState();
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString('accessToken');
    final refresh = prefs.getString('refreshToken');
    final userId = prefs.getInt('userId');
    if (access != null && refresh != null && userId != null) {
      final api = ref.read(apiClientProvider);
      api.setTokens(access, refresh);
      state = AuthState(isLoggedIn: true, userId: userId, accessToken: access, refreshToken: refresh);
      try {
        final resp = await api.get('/api/v1/auth/profile');
        final user = User.fromJson(resp.data['data']);
        state = AuthState(isLoggedIn: true, userId: userId, accessToken: access, refreshToken: refresh, user: user);
      } catch (_) {}
    }
  }

  Future<void> sendCode(String phone) async {
    final api = ref.read(apiClientProvider);
    await api.post('/api/v1/auth/send-code', data: {'phone': phone});
  }

  Future<void> login(String phone, String code) async {
    final api = ref.read(apiClientProvider);
    final resp = await api.post('/api/v1/auth/login', data: {'phone': phone, 'code': code});
    final data = resp.data['data'];
    api.setTokens(data['accessToken'], data['refreshToken']);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', data['accessToken']);
    await prefs.setString('refreshToken', data['refreshToken']);
    await prefs.setInt('userId', data['userId']);

    state = AuthState(
      isLoggedIn: true,
      userId: data['userId'],
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final api = ref.read(apiClientProvider);
    api.setTokens('', '');
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
