# generalh-drone

公式サイトのソースコード

## キャッシュ更新

CSSとJavaScriptはクエリ文字列方式でバージョン管理しています。更新して本番へ反映する際は、HTML内の `v=20260907-2` を同じ新しい値へ更新してください。Cloudflareはクエリ文字列をキャッシュキーに含める標準設定で運用します。

## OGP画像

実写素材を用意するまでは `og:image` を設定しません。用意後は共通画像を `assets/images/og/default.jpg` に配置し、1200×630pxの実画像を使用してください。各HTMLのOGP設定へ、絶対URL `https://drone.general-h.com/assets/images/og/default.jpg` を追加します。

## 本番404

`public_html` の直下へ `.htaccess` と `404.html` を配置します。`.htaccess` の `ErrorDocument 404 /404.html` により、存在しないURLでも独自404画面を表示し、HTTPステータス404を維持します。公開後は実URLで応答ヘッダーを確認してください。
