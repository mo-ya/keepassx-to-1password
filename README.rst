========================================
 KeePassX から 1Password への変換ツール
========================================

概要
====

`KeePassX <https://www.keepassx.org/>`__ から `1Password <https://1password.com/>`__ に乗り換えるにあたり、データ移行を行うために作ったスクリプト

注意事項
========

- KeepassX でサブグループを作っている場合、サブグループ内の情報は変換できません。

  - 単に自分が使っていなかったために未実装となります

- これ作ったのは 2014 年頃でしたが、いつの間にか 1Password で正式に変換ツールが提供されたようです。そちらをお使いになった方がいいでしょう。

  - `Convert to 1Password Utility <https://discussions.agilebits.com/discussion/30286/mrcs-convert-to-1password-utility/p1>`__
  - 上記ツールの紹介記事 → `KeePassXなどから1Passwordへのインポート - Qiita <http://qiita.com/snowin/items/5ec055f7c3b1656b9211>`__

動作環境
=================================

- MacOS X 10.11.6

- KeePassX 0.4.3

- 1Password 6.5.2

- Ruby 2.3.0

  - もう少し古い Ruby でもたぶん動作するはず

keepassx-to-1password.rb の使い方
=================================

#. keepassx-to-1password.rb をダウンロードしておきます。

   - 以降では、~/bin/ 以下に配置したものとします。

#. KeepassX を起動し、[ファイル] → [エクスポート] → [KeePassX XML ファイル] で XML ファイルをエクスポートします。

   - 当然平文で出力されますのでクラウドに同期されるようなディレクトリにはくれぐれも出力されませんよう

#. 出力した XML ファイル (仮に keepass.xml とします) を引数とし、 以下のように keepassx-to-1password.rb を実行します。 ::

     $ ruby ~/bin/keepassx-to-1password.rb keepass.xml -o keepass.csv

#. 作成された keepass.csv ファイル内に KeePassX で管理していた情報が CSV として出力されていれば OK です。

#. グループ名が個々の項目の末尾に ": <グループ名>" として付与されるようになってます

   - タグを使うのがまっとうな気がするのですが、当時はなぜかそのように実装したようです。
