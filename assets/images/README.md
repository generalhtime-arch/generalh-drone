# 実写画像の配置仕様

各 `figure.media-slot` の `data-image-path`・`data-image-width`・`data-image-height` を画像台帳として扱います。実写が未配置の箇所では、実景と誤認されない抽象グラフィックまたは色付き枠をフォールバックとして使います。

## 共通ルール

- 写真は WebP を基本とします。AVIF を追加する場合は、WebP より前の `source` 要素として追加します。
- `width` と `height` は下表のピクセル値を `img` 要素にも必ず指定します。CSS の `aspect-ratio` と併せ、画像読み込み前のレイアウトずれ（CLS）を抑えます。
- すべての写真は `object-fit: cover` で枠を満たします。人物が写る場合は、顔や操縦中の手元が中央付近から外れない構図にします。
- ファーストビューだけは `loading="eager" fetchpriority="high" decoding="async"` を使います。その他のページ内写真は `loading="lazy" decoding="async"` を使います。
- `picture` の `srcset` では画面幅に合う WebP を選択します。写真が入った際は `figure` に `has-image` クラスを追加します。
- 実写を表示する `img` には、写真の内容を具体的に示す `alt` を設定します。空の画像枠は、従来どおり親の `aria-label` で意味を伝えます。

## 画像台帳

|用途・スロット|推奨ファイル名|表示比率|推奨書き出しサイズ|alt / aria-label の方向性|
|---|---|---:|---:|---|
|ファーストビュー `hero`|`assets/images/hero/drone-training-main.webp`|スマホ 4:3 / PC 1:1|1280 × 720px|体育館内でインストラクターの指導を受けながらドローンを操縦する受講者|
|基本講習 `basic`|`assets/images/courses/basic-training.webp`|8:5|1280 × 800px|ドローンの機体を使って基礎を学ぶ座学講習|
|応用講習A `advanced`|`assets/images/courses/advanced-training.webp`|8:5|1280 × 720px|屋内会場でドローンを操縦する受講者と指導者|
|法人向け相談 `corporate`|`assets/images/courses/corporate-training.webp`|8:5|1280 × 800px|法人向けドローン研修・活用相談を表す抽象グラフィック|
|座学 `lecture`|`assets/images/training/classroom.webp`|4:3|960 × 720px|受講者にドローンの基礎知識を説明する講師|
|シミュレータ `simulator`|`assets/images/training/simulator.webp`|4:3|960 × 720px|ドローンシミュレータで基本操作を練習する受講者|
|実機講習 `practical`|`assets/images/training/flight-practice.webp`|4:3|960 × 720px|屋内会場でドローンの実機を操縦する受講者と指導者|
|受講イメージ大 `training`|`assets/images/training/flight-practice.webp`|8:5|960 × 720px|屋内会場でドローンの実機を操縦する受講者と指導者|
|受講イメージ小 `lecture-detail`|`assets/images/training/classroom.webp`|1:1|960 × 720px|受講者にドローンの基礎知識を説明する講師|
|受講イメージ小 `practical-detail`|`assets/images/training/flight-practice.webp`|1:1|960 × 720px|屋内会場でドローンの実機を操縦する受講者と指導者|
|会場・アクセス `access`|`assets/images/access/school-exterior.webp`|トップ 4:5 / 下層 4:3|1280 × 960px|会場・アクセスのご案内を表す抽象イラスト|

`first-time`、`pricing`、`contact`、`company` の枠は、上表の基本講習・会場・講習風景の写真を再利用するか、同じ比率の追加写真を用意して差し替えます。実際の写真内容に合わせ、重複した同じ写真を多用しないようにします。

## 写真を入れるときのマークアップ

空の `<picture class="media-picture" aria-hidden="true"></picture>` を、以下の形に差し替えます。`width` と `height` は該当スロットの `data-image-width`・`data-image-height` と同じ値にします。

```html
<picture class="media-picture">
  <source type="image/webp"
          srcset="/assets/images/training/classroom-640.webp 640w,
                  /assets/images/training/classroom.webp 960w"
          sizes="(min-width: 720px) 30vw, calc(100vw - 40px)">
  <img src="/assets/images/training/classroom.webp" width="960" height="720"
       alt="受講者にドローンの基礎知識を説明する講師"
       loading="lazy" decoding="async">
</picture>
```

ファーストビューは上記の `img` に `loading="eager" fetchpriority="high"` を付け、`loading="lazy"` は付けません。

## OGP画像

共通OGP画像の配置先は `assets/images/og/default.jpg` です。サイズは 1200 × 630px、公開URLは `https://drone.general-h.com/assets/images/og/default.jpg` です。編集用の元データは同じフォルダーの `default.svg` です。

画像の作成・差し替え後は、ローカルWindows PCで `./tools/enable-og-image.ps1` を実行します。全ページの `og:image` とサイズ情報を同じ値で追加します。

追加される設定は次のとおりです。

```html
<meta property="og:image" content="https://drone.general-h.com/assets/images/og/default.jpg">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:image:alt" content="ドローン教習所東京上野校">
```
