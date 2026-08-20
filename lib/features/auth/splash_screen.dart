// スプラッシュ画面。起動時にログイン状態とプロフィール登録状況を確認し、
// 未ログイン→/login、プロフィール未登録→/profile/setup、登録済み→/home へ振り分ける。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/supabase_client.dart';
import 'auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decideNext());
  }

  Future<void> _decideNext() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) context.go('/login');
      return;
    }
    final registered = await hasProfile(user.id);
    if (!mounted) return;
    context.go(registered ? '/home' : '/profile/setup');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
