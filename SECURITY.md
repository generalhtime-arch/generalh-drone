# 公開時のセキュリティ方針

このサイトはフォーム、ログイン、データベースを持たない静的サイトです。個人情報を受け取る予約フォームは現時点で実装していません。

## リポジトリで有効にする対策

`.htaccess` により、Apache が対応している本番環境では次を有効にします。

- ディレクトリ一覧の無効化
- 独自404ページとHTTP 404ステータス
- Content Security Policy（同一オリジンの静的アセットだけを許可）
- クリックジャッキング防止（フレームへの埋め込みを拒否）
- MIMEタイプ推測の無効化
- 不要なブラウザ機能（カメラ、マイク、位置情報、決済など）の無効化
- リファラー情報の最小化

本番サーバーが `mod_headers` を利用できない場合でも、ヘッダー設定部分は安全に読み飛ばされます。その場合は、CORESERVERまたはCloudflare側で同じレスポンスヘッダーを設定します。

## Cloudflareで公開前に確認すること

- SSL/TLSは **Full (strict)** を使用する。
- **Always Use HTTPS** を有効にする。
- WAFの管理ルールを有効にする。
- Bot Fight Mode（利用可能なプランの場合）を有効にする。
- レート制限は、将来予約・問い合わせフォームを公開するタイミングでフォームURLに設定する。
- HSTSはHTTPSで問題なく表示できることを確認してから有効にする。`includeSubDomains` は、すべてのサブドメインがHTTPS対応であることを確認してから選ぶ。

## 将来の予約連携時の注意

`booking-v2.general-h.com` への通常のリンク遷移は、現行のCSPでも可能です。フォーム送信・iframe埋め込み・API通信を追加する場合は、必要な方式だけCSPを更新します。

- 外部フォーム送信: `form-action`
- iframe埋め込み: `frame-src`
- API通信: `connect-src`

広いワイルドカード（例: `https:` や `*`）は追加せず、接続先を完全なオリジンで限定します。

## 本番反映後の確認

ブラウザの開発者ツールまたは `curl -I https://drone.general-h.com/` で、少なくとも `Content-Security-Policy`、`X-Content-Type-Options`、`Referrer-Policy`、`Permissions-Policy` が返ることを確認します。404 URLでは独自ページとHTTP 404を確認します。
