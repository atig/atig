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


発言関係
------------------------------
tid
  各発言にtidを表示する。

フォロワー関係
------------------------------
athack
  ???
only
  指定すると片思い表示機能が有効になる。有効にしていると、自分が一方的
  にフォローしている人に ``+o`` がつきます。たいていのクライアントだと
  ``@`` がつきます。

URL短縮関係
------------------------------

発言中の長いURLを自動で短縮します。どの短縮URLサービスを用いて短縮する
か、どの程度の長さのURLを短縮するか、などが設定できます。

bitlify=\ ``size``
  ``size``\ 字以上のURLを http://bit.ly\ によって短縮します。
bitlify
  |len|\ 字以上のURLを http://bit.ly\ によって短縮します。
bitlify=\ ``api_key``:\ ``password``:\ ``size``
  ``size``\ 字以上のURLを http://bit.ly のAPIによって短縮します。
  APIを利用して短縮すると、ユーザページに短縮したURLが記録されたりします。
  詳しくは、 http://bit.ly のSign up for bit.lyを読んでください。
bitlify=\ ``api_key``:\ ``password``
  |len|\ 字以上のURLを http://bit.ly のAPIによって短縮します。
unuify= \ ``size``
  ``size`` 字以上のURLを http://u.nu によって短縮します。
unuify
  |len| 字以上のURLを http://u.nu によって短縮します。

.. |len| replace:: 20
