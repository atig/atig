IRCコマンド
==============================

nickなどの扱い
------------------------------

 - nick: OAuthのプロファイル名、ベーシック認証時のユーザ名
 - real: クライアントオプション。詳細は :doc:`options` を参照してください。
 - pass: ベーシック認証時のパスワード

IRCコマンドとの対応
------------------------------

\/invite ``screen_name`` ``channel``
  ``channel`` がメインチャンネル(通常は#twitter)の場合、ユーザ ``screen_name`` をフォローします。  同時にユーザ一覧の更新も行なうので、「follow ``screen_name`` 」と発言するよりも便利です。

  ``channel`` がリストチャンネルの場合、ユーザ ``screen_name`` をリストに追加します。

\/kick ``screen_name`` ``channel``
  ``channel`` がメインチャンネル(通常は#twitter)の場合、ユーザ ``screen_name`` をリムーブします。

  ``channel`` がリストチャンネルの場合、ユーザ ``screen_name`` をリストから削除します。

\/whois ``screen_name``
  ``screen_name`` の情報を表示します。ID番号、名前、自己紹介、現在地などを表示します。

\/topic ``topic``
  :doc:`commands` の `autofix` へのエイリアスです。
  ``topic`` が前回の発言と類似している場合、古い発言を上書きします。
\/who ``channel``
  ``channel`` の参加者の情報を表示します。ID番号、名前などを表示します。
