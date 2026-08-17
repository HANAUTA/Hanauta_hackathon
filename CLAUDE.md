# プロジェクト概要

42ハッカソン向けの Hanalog 風動画共有アプリ。Flutter + Supabase で構築する。
参加者（学生）はこのテンプレートをベースに、課題を進めながらアプリを拡張する。

## 技術スタック

- Flutter 3.32 / Dart 3.11
- 状態管理: `flutter_riverpod`
- ルーティング: `go_router`（全ルートは `core/router.dart` に集約）
- バックエンド: Supabase（認証・DB・Storage）
- 環境変数: `flutter_dotenv`（`.env` で管理、Git に上げない）
- カメラ: `camera`（モバイル）/ `web/camera_helper.js`（Web）
- 動画変換: `web/ffmpeg_helper.js`（Web のみ、ffmpeg.wasm）

## 参加者向けドキュメント

学生が参照する主なドキュメント。課題の実装を手伝うときはこれらを前提にする。

- [事前準備ガイド](docs/01_事前準備ガイド.md) … 当日までに用意しておくもの
- [環境構築（当日手順）](docs/02_環境構築.md) … Flutter インストール〜アプリ起動まで
- [必須課題](docs/03_必須課題.md) … 全員が取り組む3つの課題（ログインUI改善 / グループ脱退 / プロフィール画面）
- [自由課題](docs/04_自由課題.md) … 初級〜上級の発展課題。上級は自前 Supabase に likes/comments 等のテーブルを自分で設計して取り組む
- [開発の流れ](docs/05_開発の流れ.md) … ブランチ作成〜push〜マージ〜スマホ配布の1サイクル
- [GitHub Actions 設定手順](docs/06_GitHub_Actions設定手順.md) … スマホ自動配布の設定
- [コーディング規約](docs/07_コーディング規約.md) … フォルダ構成・命名・コメント規則
- [データベース設計](docs/08_データベース設計.md) … 既存テーブルの構造
- [Antigravity CLI 利用ガイド](docs/09_Antigravity_CLI利用ガイド.md) … 無料AIツール（Antigravity CLI）の使い方

---

# 触ってはいけないファイル

以下は動作の根幹に関わるため、課題の実装では**変更しないこと**。

| 対象 | 理由 |
|------|------|
| `lib/core/supabase_client.dart` | Supabase の初期化処理。壊すと全機能が動かなくなる |
| `lib/core/video_processor*.dart` | Web/モバイルの動画変換。プラットフォーム分岐が複雑 |
| `lib/core/cached_video*.dart` | 動画キャッシュ。プラットフォーム分岐あり |
| `lib/core/app_platform.dart` | プラットフォーム判定。動画の回転補正に関わる |
| `lib/features/post/camera_screen.dart` | カメラ撮影画面。Web/モバイル両対応で繊細 |
| `lib/features/post/recorded_video_view.dart` | 動画再生の回転補正。プラットフォーム依存のロジック |
| `web/camera_helper.js` | Web カメラのパーミッション制御 |
| `web/ffmpeg_helper.js` | ffmpeg.wasm による動画変換。JS 側のステッカー焼き付け処理 |
| `web/ffmpeg/` | ffmpeg.wasm のバイナリ群 |
| `.github/workflows/deploy.yml` | Web ビルド・GitHub Pages 自動デプロイの CI 設定 |
| `main.dart` | アプリのエントリーポイント。初期化順序が重要 |

> 上記以外の `lib/features/` や `lib/models/` は自由に編集・追加してOK。

---

# 新しい機能を追加するときのパターン

## 画面を追加する場合

1. `lib/features/<機能名>/` にフォルダを作る
2. `<機能名>_screen.dart`（画面）と、必要なら `<機能名>_provider.dart`（データ取得）を置く
3. `lib/core/router.dart` にルートを追加する
4. 画面遷移は `context.go()` / `context.push()` を使う（`Navigator.push` は使わない）

## Supabase からデータを読み書きする場合

- `lib/core/supabase_client.dart` の `supabase` インスタンスを import して直接呼ぶ
- 共有リポジトリ層やサービスクラスは**作らない**（Provider 内に直接書く）
- 既存の `group_provider.dart` や `post_provider.dart` を参考にする

```dart
// 例: グループ一覧を取得
final rows = await supabase
    .from('groups')
    .select()
    .order('created_at', ascending: false);
```

## 新しいテーブルを使う場合（上級課題）

- テーブル定義は生徒が自分の Supabase で SQL を書いて作る
- アプリ側は `lib/models/` にデータモデルを追加し、Provider でクエリする

---

# コーディング時の必須ルール

コードを書くときは必ず以下を守ること。詳細は [docs/07_コーディング規約.md](docs/07_コーディング規約.md) を参照。

## フォルダ構成

```
lib/
├── main.dart
├── core/          # Supabase初期化・ルーティング（※触らない）
├── features/      # 機能単位でフォルダを切る（ここに追加していく）
│   ├── auth/
│   ├── home/
│   ├── group/
│   └── post/
└── models/        # 共通データモデル
```

## コメント規則

- **ファイル先頭**: 必ず1〜2行、そのファイルの責務を日本語で書く
- **クラス・Provider**: 任意、1行で役割を日本語で書く
- **メソッド内**: 基本なし。WHYが分からない箇所のみ
- **行単位のコメント**: 書かない

```dart
// グループ詳細画面。時間・日付移動による投稿フィルタリングUI。
class GroupDetailScreen extends ConsumerWidget {
```

## 状態管理・ルーティング

- 状態管理: **Riverpod**（`flutter_riverpod`）
- ルーティング: **go_router**、全ルートは `core/router.dart` に集約
- 画面内で直接 `Navigator.push` は使わない

## Git・環境変数

- **`git commit` や `git push` は絶対に自分からやらない。** ユーザーに明示的に頼まれたときだけ実行する
- コミットメッセージ: 日本語
- 環境変数は `.env`（`flutter_dotenv` で読み込む）、Gitに上げない

## 命名規則

- ファイル名: `snake_case.dart`
- クラス名: `PascalCase`
- 変数・関数: `camelCase`
- Provider: `camelCase` + `Provider`（例: `groupProvider`）
