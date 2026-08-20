// アナリティクスイベントをSupabaseに記録するユーティリティ。
// ⚠️ 運営用の計測基盤。このファイル自体、および各画面の Analytics.log() 呼び出しは
// 消さないこと（呼び出し元の機能ごと削除するのはOK）。

import 'dart:math';

import 'package:flutter/foundation.dart';

import 'supabase_client.dart';

class Analytics {
  Analytics._();

  // アプリ起動ごとに発行するID。起動直後はログイン前で user_id が取れないため、
  // 起動から終了までのイベントをこのIDで1セッションとして束ねる。
  static final String sessionId = _randomId();

  static Future<void> log(
    String eventName, [
    Map<String, dynamic>? properties,
  ]) async {
    final userId = supabase.auth.currentUser?.id;
    try {
      await supabase.from('analytics_events').insert({
        'user_id': userId,
        'event_name': eventName,
        'properties': {...?properties, 'session_id': sessionId},
      });
    } catch (e) {
      debugPrint('[analytics] 記録失敗: $e');
    }
  }

  static String _randomId() {
    final random = Random();
    return List.generate(
      16,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
  }
}
