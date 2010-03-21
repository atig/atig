IRCコマンドとの対応
==============================

\/invite ``screen_name`` ``channel``
  ``channel`` がメインチャンネル(通常は#twitter)の場合、ユーザ ``screen_name`` をフォローします。  同時にユーザ一覧の更新も行なうので、「follow ``screen_name`` 」と発言するよりも便利です。

  ``channel`` がリストチャンネルの場合、ユーザ ``screen_name`` をリストに追加します。

\/kick ``screen_name`` ``channel``
  ``channel`` がメインチャンネル(通常は#twitter)の場合、ユーザ ``screen_name`` をリムーブします。

  ``channel`` がリストチャンネルの場合、ユーザ ``screen_name`` をリストから削除します。

\/whois ``screen_name``
  ``screen_name`` の情報を表示します。ID番号、名前、自己紹介、現在地などを表示します。
