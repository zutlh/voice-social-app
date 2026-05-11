import 'package:go_router/go_router.dart';
import '../pages/login/login_page.dart';
import '../pages/home/home_page.dart';
import '../pages/room/room_page.dart';
import '../pages/wallet/wallet_page.dart';
import '../pages/profile/profile_page.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
    GoRoute(path: '/home', builder: (_, _) => const HomePage()),
    GoRoute(path: '/room/:id', builder: (_, state) => RoomPage(roomId: int.parse(state.pathParameters['id']!))),
    GoRoute(path: '/wallet', builder: (_, _) => const WalletPage()),
    GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
  ],
);
