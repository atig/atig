CTCP ACTION
==================================

概要
------------------------------

CTCP ACTIONによって、特定の発言への返信などが行なえます。

CTCP ACTIONの送り方はクライアントによって異なりますが、LimeChatやirssi
では ``/me`` です。 例えば、replyコマンド送信する場合は ``/me reply a`` のようになります。

発言関係
------------------------------
発言の指定方法について
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

以下で ``tweet`` と書かれている部分では、次の書式が利用できます。

- `a`: 一致するtidを持つ発言を指します。
- `nick:a`:  一致するsidを持つ発言を指します。
- `nick`:  @nickの最新の発言を指します。
- `@nick`: @nickの最新の発言を指します。

コマンド
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reply ``tweet`` ``comment`` (別名: mention, re, rp)
  ``tweet`` に対して返信します。
retweet ``tweet`` [``comment``] (別名: rt, ort)
  ``tweet`` をリツイートします。
  コメントが省略された場合は、公式リツイートになります。
destroy ``tweet`` (別名: remove, rm)
  ``tweet`` を削除する。 ``tweet`` の発言が自分のものでない場合はエラーになります。
fav ``tweet``
  ``tweet`` をお気に入りに追加します。
unfav ``tweet``
  ``tweet`` をお気に入りから削除します。
thread ``tweet`` [``count``]
  ``tweet`` のin_reply_toを辿って、最大 ``count`` 件の会話を表示します。
  ``count`` が省略された場合は10件になります。 ``count`` は20件以上を指定しても無視されます。
autofix ``comment`` (別名: topic)
  最新の発言が ``comment`` と類似している場合はその発言を削除し、 ``comment`` を発言として投稿します。
autofix! ``tweet`` (別名: topic!)
  最新の発言を削除し、 ``comment`` を発言として投稿します。
search [ ``option`` ] ``text`` (別名: s)
  ``text`` を含む発言を検索します。
  オプションは ``:lang=<国コード>`` のみサポートしています。``/me s :lang=ja hoge`` だと日本人のツイートのみを検索します。


ユーザ関係
------------------------------
userinfo ``screen_name`` (別名: bio)
  ``screen_name`` のユーザのプロフィールを表示します。
version ``screen_name``
  ``screen_name`` のクライアントの情報を表示します。最新の発言に用いたクライアント名を表示します。
time ``screen_name``
  ``screen_name`` のタイムゾーン情報を表示します。
user ``screen_name`` [``count``] (別名: u)
  ``screen_name`` のユーザの最新の発言 ``count`` 件を表示します。
  ``count`` が省略された場合は20件になります。 ``count`` は
  200件以上を指定しても無視されます。
spam ``screen_name``
  ``screen_name`` のユーザをスパムアカウントとして通報します。

プロフィール関連
------------------------------
location ``place`` (別名: in, location)
  自分の現在地を ``place`` に更新します。
name ``name``
  自分の名前を ``name`` に更新します。

システム関係
------------------------------
uptime
  atig.rbの連続起動時間を表示します。
limit (別名: limits, rls)
  残りのAPIへのアクセス可能回数を表示します。
opt  (別名: opts, option, options)
  設定された :doc:`options` 一覧を表示します。
opt ``name`` (別名: opts, option, options)
  名前 ``name`` の :doc:`options` が持つ値を表示します。
opt ``name`` ``value`` (別名: opts, option, options)
  名前 ``name`` の :doc:`options` が持つ値を ``value`` に更新します。
refresh
  フォローしているユーザ一覧を再読み込みさせます。
