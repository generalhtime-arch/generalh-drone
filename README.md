# generalh-drone

公式サイトのソースコード

## キャッシュ更新

CSSとJavaScriptはクエリ文字列方式でバージョン管理しています。CSSまたはJavaScriptを更新して本番へ反映する際は、該当ファイルを読み込むHTMLの `v=` の値を新しい値へ更新してください。Cloudflareはクエリ文字列をキャッシュキーに含める標準設定で運用します。

## OGP画像

共通OGP画像は `assets/images/og/default.jpg`（1200×630px）です。現在は校名と講習内容を示す案内用カードを使用し、全ページの `og:image` に `https://drone.general-h.com/assets/images/og/default.jpg` を設定しています。差し替え後は `./tools/enable-og-image.ps1` を実行してください。

## 本番404

`public_html` の直下へ `.htaccess` と `404.html` を配置します。`.htaccess` の `ErrorDocument 404 /404.html` により、存在しないURLでも独自404画面を表示し、HTTPステータス404を維持します。公開後は実URLで応答ヘッダーを確認してください。

## 社内検査中の noindex

社内検査中は `.htaccess` が `X-Robots-Tag: noindex` を返します。お客様向けの本公開前に、この設定を削除して検索エンジンの登録を許可してください。

## 公開の流れ

1. GitHub上で `feature/initial-site` の差分を確認する。
2. 承認後に、GitHub上でmainへマージする。
3. CORESERVERの `/home/generalh/domains/drone.general-h.com/public_html` でmainを `git pull --ff-only` する。
4. 本番URLでトップ、主要下層ページ、404、電話リンクを確認する。
5. [SECURITY.md](SECURITY.md) の「本番反映後の確認」を実行する。

予約システムは別プロジェクトで準備中です。`booking-v2.general-h.com/drone/` が本番公開されるまで、このサイト側の予約フォーム・予約リンクは追加しません。
