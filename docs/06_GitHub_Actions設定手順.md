# GitHub Actions 設定手順（スマホ自動配布）

`main` ブランチに push すると、自動でアプリがビルドされてスマホのブラウザに届く仕組みです。
**グループごとに1回だけ**設定すればOKです。

---

## 全体像

```
main に push → GitHub Actions がビルド → GitHub Pages に公開 → スマホのブラウザで開ける
```

APK をインストールする必要はありません。**ブラウザで開くだけ**で最新版が見られます。

---

## 設定手順

### 1. GitHub Actions を有効にする

このリポジトリは Fork（コピー）で作られているため、**GitHub Actions が最初は無効**になっています
（安全のためのGitHubの仕様です）。

1. リポジトリの上部タブから **「Actions」** を開く
2. 黄色い帯で「Workflows aren't being run on this forked repository」と出るので、
   **「I understand my workflows, go ahead and enable them」** をクリック

### 2. GitHub リポジトリの Secrets を登録する

**設定場所の開き方：**

1. GitHub でチームのリポジトリを開く
2. 上のタブから **「Settings」** をクリック
3. 左メニューの **「Secrets and variables」** → **「Actions」** をクリック
4. **「New repository secret」** ボタンをクリック

**登録する2つの Secret：**

1つずつ「Name」と「Secret」を入力して **「Add secret」** を押す、を2回繰り返します。

| Name（この通りに入力） | Secret（貼り付ける値） |
|---|---|
| `SUPABASE_URL` | `.env` に貼ったのと同じ **Supabase の URL**（`https://xxxxxxxx.supabase.co`） |
| `SUPABASE_ANON_KEY` | `.env` に貼ったのと同じ **anon key**（`eyJhbGciOi...` の長い文字列） |

> ⚠️ **Name は大文字・アンダースコアで、上の表の通りに正確に入力**してください。1文字でも違うとビルドが失敗します。
>
> ⚠️ Secret には**値だけ**を貼ります。`SUPABASE_URL=` のような `=` は要りません。
>
> ⚠️ この設定ができるのは、リポジトリの Owner（＝ステップ2でリポジトリを作った代表者）だけです。
> 他のメンバーの画面に「Settings」が出ない/操作できない場合は、代表者にやってもらってください。

2つ登録し終わったら、Secrets 一覧に2つ並んでいることを確認してください。

### 3. GitHub Pages を有効にする

1. リポジトリの **「Settings」** → 左メニューの **「Pages」** をクリック
2. **「Build and deployment」** の **「Source」** を **「GitHub Actions」** に変更する

これだけです。

### 4. テスト push してビルドを走らせる

グループの誰か1人がやればOKです。

```bash
# main ブランチにいることを確認
git checkout main
git pull

# 何か小さな変更を加える（READMEに1行足すだけでOK）
echo "" >> README.md

# コミットして push
git add README.md
git commit -m "ビルドテスト"
git push
```

push できたら、**GitHub のリポジトリページ** → 上のタブから **「Actions」** をクリック。

```
┌─────────────────────────────────────────┐
│  ✅ ビルドテスト                          │
│     Build & Deploy to GitHub Pages      │
│     🟡 In progress...                   │  ← 黄色い丸 = ビルド中
└─────────────────────────────────────────┘
```

**黄色い丸が回っていればビルド開始！** 完了まで **約2〜3分** かかります。

> ❌ 赤いバツ（失敗）になったら → クリックしてエラーログを確認。
> 一番多い原因は **Secret の Name の打ち間違い**、次に多いのが **Pages の Source 未設定**です。

### 5. URL を確認する

ビルドが完了（緑のチェック ✅）したら、以下のどちらかで URL が分かります。

- Settings → Pages の一番上に表示されている URL
- Actions の実行結果 → `deploy` ジョブを開くと URL が表示される

URL の形式：

```
https://<代表者のGitHubユーザー名>.github.io/<リポジトリ名>/
```

この URL をスマホのブラウザで開けば、最新版のアプリが表示されます🎉
**チームメンバー全員に共有してあげてください。**

---

## スマホでアプリっぽく使う（任意）

ブラウザでURLを開いた状態で、

- **iPhone（Safari）**：共有ボタン → 「ホーム画面に追加」
- **Android（Chrome）**：メニュー（︙）→ 「ホーム画面に追加」／「アプリをインストール」

とすると、ホーム画面にアイコンが増えて、通常のアプリのように起動できます（PWA）。

---

## 以降の使い方

`main` にマージ → push するたびに、同じ流れで自動的にブラウザに反映されます。
詳しい開発フローは [開発の流れ](05_開発の流れ.md) を参照してください。

## 困ったときは

| 症状 | 原因と対処 |
|---|---|
| push しても Actions タブに何も表示されない | 「1. GitHub Actions を有効にする」ができていない。「I understand my workflows, go ahead and enable them」をクリック |
| Actions が赤いバツで止まる | Secret の Name を打ち間違えていないか確認 |
| ビルドは成功したが URL を開いても真っ白 | Settings → Pages の Source が「GitHub Actions」になっているか確認 |
| 前のバージョンのまま反映されない | ブラウザのキャッシュが残っている。スマホなら一度タブを閉じて開き直す、PCなら再読み込み（Cmd/Ctrl + Shift + R） |
| カメラが使えない | URLが `https://` から始まっているか確認（`http://` だとカメラの許可が出ない仕様） |
| 自分だけ Settings が触れない | リポジトリの Owner（代表者）ではない。代表者にやってもらう |
