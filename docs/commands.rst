CTCP ACTION
==================================

概要
------------------------------

CTCP ACTIONによって、特定の発言への返信などが行なえます。

CTCP ACTIONの送り方はクライアントによって異なりますが、LimeChatやirssi
では ``/me`` です。 例えば、replyコマンド送信する場合は ``/me reply a`` のようになります。

発言関係
------------------------------
reply ``tid`` ``comment`` (別名: mention/rp)
  ``tid`` の発言に対して返信します。
retweet ``tid`` ``comment`` (別名: rt ort)
  ``tid`` の発言をリツイートする。
  コメントが省略された場合は、公式リツイートになります。
destroy ``tid`` (別名: remove/rm)
  ``tid`` の発言を削除する。 ``tid`` の発言が自分のものでない場合はエラーになります。
fav ``tid``
  ``tid`` の発言をお気に入りに追加します。
unfav ``tid``
  ``tid`` の発言をお気に入りから削除します。
thread ``tid`` [``count``]
  in_reply_toを辿って、最大 ``count`` 件の会話を表示します。
  ``count`` が省略された場合は10件になります。 ``count`` は20件以上を指定しても無視されます。

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

システム関係
------------------------------
uptime
  atig.rbの連続起動時間を表示します。
