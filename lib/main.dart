import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'core/models/package_model.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/packages_provider.dart';
import 'shared/theme/app_theme.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/packages/screens/country_picker_screen.dart';
import 'features/packages/screens/packages_screen.dart';
import 'features/packages/screens/package_detail_screen.dart';
import 'features/checkout/screens/checkout_screen.dart';
import 'features/my_esims/screens/my_esims_screen.dart';
import 'features/esim_check/screens/esim_check_screen.dart';
import 'features/profile/screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GohoSimApp());
}

// â”€â”€ Router â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
final _router = GoRouter(
  initialLocation: '/home',
  redirect: (context, state) {
    final auth = context.read<AuthProvider>();
    final loc  = state.uri.toString();

    // Masih loading â†’ tunggu (tidak redirect)
    if (auth.state == AuthState.unknown) return null;

    final loggedIn = auth.state == AuthState.authenticated;

    // Halaman terlindung â€” harus login
    final protected = ['/my-esims', '/profile', '/checkout'];
    final needsAuth = protected.any((p) => loc.startsWith(p));
    if (needsAuth && !loggedIn) return '/login?from=${Uri.encodeComponent(loc)}';

    // Sudah login, jangan balik ke login/register
    if (loggedIn && (loc == '/login' || loc == '/register')) return '/home';

    return null;
  },
  routes: [
    GoRoute(path: '/login',    builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/home',     builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/my-esims',    builder: (_, __) => const MyEsimsScreen()),
    GoRoute(path: '/esim-check', builder: (_, __) => const EsimCheckScreen()),
    GoRoute(path: '/profile',  builder: (_, __) => const ProfileScreen()),

    // Pilih negara (opsional: preselect dari query param)
    GoRoute(
      path: '/packages',
      builder: (_, state) => CountryPickerScreen(
        preselectedCode: state.uri.queryParameters['country'],
        preselectedName: state.uri.queryParameters['name'],
      ),
    ),

    // Daftar paket per negara
    GoRoute(
      path: '/packages/:code',
      builder: (_, state) => PackagesScreen(
        countryCode: state.pathParameters['code']!,
        countryName: state.uri.queryParameters['name'] ?? state.pathParameters['code']!,
      ),
    ),

    // Package detail — tidak perlu login
    GoRoute(
      path: '/package-detail',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final pkg   = extra?['package'] as EsimPackage?;
        final name  = extra?['countryName'] as String? ?? '';
        if (pkg == null) return const HomeScreen();
        return PackageDetailScreen(pkg: pkg, countryName: name);
      },
    ),

    // Checkout — package & countryName dikirim via extra
    GoRoute(
      path: '/checkout',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final pkg   = extra?['package'] as EsimPackage?;
        final name  = extra?['countryName'] as String? ?? '';
        if (pkg == null) return const HomeScreen(); // fallback
        return CheckoutScreen(package: pkg, countryName: name);
      },
    ),
  ],
);

// â”€â”€ App root â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class GohoSimApp extends StatelessWidget {
  const GohoSimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => PackagesProvider()),
      ],
      child: MaterialApp.router(
        title: 'GohoSIM',
        theme: AppTheme.light,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
