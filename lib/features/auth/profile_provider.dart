// プロフィール画面のデータ取得・更新を担当するProvider群。
// ログイン中ユーザーの users 行を取得し、表示名の更新を行う。

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase_client.dart';
import '../../models/app_user.dart';

// ログイン中ユーザーのプロフィールを取得する。
// autoDispose: 画面を開くたびに最新を取得する（古いキャッシュを残さない）。
final myProfileProvider = FutureProvider.autoDispose<AppUser>((ref) async {
  final user = supabase.auth.currentUser;
  if (user == null) {
    throw Exception('ログインしていません');
  }

  final row = await supabase
      .from('users')
      .select('id, name, created_at')
      .eq('id', user.id)
      .single();

  return AppUser.fromJson(row);
});

// プロフィール（名前）を users テーブルで更新する。id は Auth のユーザーID。
// updated_at はDB側のトリガが自動更新するため、ここでは触らない。
Future<void> updateProfileName({
  required String userId,
  required String name,
}) async {
  await supabase.from('users').update({'name': name}).eq('id', userId);
}
