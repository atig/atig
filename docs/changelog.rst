更新履歴
==============

v0.3.4(2012-01-30)
------------------------------
http://github.com/mzp/atig/tree/v0.3.4

バグ修正
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 - Ruby 1.8 で動かない問題を修正しました

 v0.3.3(2012-01-24)
------------------------------
http://github.com/mzp/atig/tree/v0.3.3

機能追加
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 - gem コマンドでインストールできるようにしました

機能修正
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 - Ruby 1.9 に対応しました
 - SQLite3-1.3.5 に対応しました
 - bundler に対応しました
 - HTTP アクセス時の media-range から Quality 指定を削除しました
 - bit.ly の API 変更に追従しました

バグ修正
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 - 非公式RTが実行できない不具合を修正

 v0.3.2(2010-10-10)
------------------------------
http://github.com/mzp/atig/tree/v0.3.2

機能追加
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 - :doc:`config`: `Atig::IFilter::RetweetTime` を追加しました

機能修正
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 - DBのデータ削除の周期を減らしました
 - DMチャンネルでのDMの送信に対応しました
 - :doc:`commands`: `limit` にリセットされる日付を表示するようにした (thx. `hirose31`_ )
 - :doc:`config`: 自動展開するURLにhtn.to, goo.glを追加

.. _hirose31: http://twitter.com/hirose31

v0.3.1(2010-07-26)
------------------------------
http://github.com/mzp/atig/tree/v0.3.1

機能追加
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 - :doc:`commands`: `refresh` を追加しました
 - :doc:`commands`: `spam` を追加しました
 - :doc:`agent` : 他人のリストをフォローできるようになりました

機能修正
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 - キャッシュを/tmp/atigに置くように変更しました。
 - 定期的にキャッシュ中の古い内容を削除するように変更しました。

バグ修正
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 - アンフォローしたユーザがキャッシュ中に残るバグを修正


v0.3.0(2010-06-12)
------------------------------
http://github.com/mzp/atig/tree/v0.3.0

機能追加
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 - :doc:`commands`: `search` を追加しました。(thx. `xeres`_ )

.. _xeres: http://blog.xeres.jp/2010/06/04/atig_rb-tweet-search/

機能修正
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 - キャッシュとして用いているSQLiteのDBにインデックスを貼るようにしました。(thx. `L_star`_ )
 - 定期的にGCを起動し、メモリ消費量を抑えるようにしました。
 - 誤ったBit.lyのAPIキーを指定した際のエラーメッセージを分かりやすくしました。( `Issues 1`_ )

.. _L_Star: http://d.hatena.ne.jp/mzp/20100407#c
.. _Issues 1: http://github.com/mzp/atig/issues/closed#issue/1

バグ修正
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



v0.2.1(2010-04-17)
------------------------------
http://github.com/mzp/atig/tree/v0.2.1

機能追加
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 - :doc:`commands`: `autofix`, `location` を追加しました。
 - :doc:`irc`: `/topic` が `/me autofix` のエイリアスになりました。
 - 最新の発言を削除した場合、トピック(topic)をひとつ前に戻すようにした

v0.2(2010-04-11)
------------------------------
http://github.com/mzp/atig/tree/v0.2

機能追加
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 - :doc:`options`: `sid` を追加した。
 - :doc:`config`: `Atig::IFilter::Sid` を追加した。
 - :doc:`options`: `old_style_reply` を追加した。
 - :doc:`commands`: `reply`, `retweet`, `destory`, `fav`, `unfav`, `thread` でスクリーンネームやsidを利用できるようにした。

バグ修正
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 - followingの取得時にSSL Verified Errorが発生する不具合を修正

v0.1
------------------------------

http://github.com/mzp/atig/tree/v0.1

- 最初のリリース

