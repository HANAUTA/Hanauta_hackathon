// グループのデータモデル。Supabaseのgroupsテーブルと対応。

class Group {
  const Group({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.ownerId, //GroupDetailScreenの削除ボタンを「グループのオーナーだけに表示する」ための判定に使う
    required this.createdAt,
  });

  final String id;
  final String name;
  final String inviteCode;
  final String ownerId; //削除ボタン
  final DateTime createdAt;

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      inviteCode: json['invite_code'] as String,
      ownerId: json['owner_id'] as String, //削除ボタン
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'invite_code': inviteCode,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
