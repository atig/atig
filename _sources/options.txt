クライアントオプション
==================================

概要
------------------------------
realnameのユーザ名の後ろにいろいろと書くことで、各オプションを有効にできます。

例えば次のようにすると、tidオプションとonlyオプションが有効になります。 ::

    twitter {
        host: localhost
        port: 19876
        name: mzp tid only
    }

:doc:`commands` のoptコマンドを用いると、実行中に変更できます。

発言関係
------------------------------
tid
  各発言にtidを表示します。tidは特定の発言へreplyする場合などに利用します。

  :doc:`commands` も参照してください。
sid
  各発言にsidを表示します。sidはtidと同様に利用できます。

  sidは ``ユーザ名``:\ ``id`` という書式にです。そのため、
  ユーザ名の補完機能のあるクライアントではtidより入力が容易です。

フォロワー関係
------------------------------
only
  指定すると片思い表示機能を有効にします。有効にしていると、自分が一方的
  にフォローしている人に ``+o`` がつきます。たいていのクライアントだと
  ``@`` がつきます。

発言関連
------------------------------
stream
  `UserStream`_ を有効にします。
  実行中の変更には対応していません。
footer=\ ``footer``
  発言の末尾に、 ``footer`` を追加します。
  ただし ``footer`` がfalseの場合は、追加しません。
old_style_reply
  @nickで始まる発言が、@nick の最新の発言へのreplyとなるモードに切り替えます。

.. _UserStream: https://dev.twitter.com/docs/streaming-apis/streams/user

URL短縮関係
------------------------------

発言中の長いURLを自動で短縮します。どの短縮URLサービスを用いて短縮する
か、どの程度の長さのURLを短縮するか、などが設定できます。

bitlify
  |len|\ 字以上のURLを http://bit.ly\ によって短縮します。
bitlify=\ ``size``
  ``size``\ 字以上のURLを http://bit.ly\ によって短縮します。
bitlify=\ ``username``:\ ``api_key``
  |len|\ 字以上のURLを http://bit.ly のAPIによって短縮します。
bitlify=\ ``username``:\ ``api_key``:\ ``size``
  ``size``\ 字以上のURLを http://bit.ly のAPIによって短縮します。
  APIを利用して短縮すると、ユーザページに短縮したURLが記録されたりします。
  詳しくは、 http://bit.ly のSign up for bit.lyを読んでください。

.. |len| replace:: 20

システム関係
------------------------------
api_base=\ ``api_base``
  Twitterのエントリポイントを指定します。実行中の変更には対応していません。指定しない場合は、https://api.twitter.com/1/が用いられます。
.. stream_api_base=\ ``api_base``
   Stream APIのエントリポイントを指定します。実行中の変更には対応していません。指定しない場合は、http://stream.twitter.com/1/'が用いられます。
   stream_timeout=\ ``timeout``
   Stream APIの接続は一定時間ごとに再接続を行ないます。その時間間隔を指定します。0を指定した場合は、再接続を行ないません。
