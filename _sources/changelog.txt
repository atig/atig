更新履歴
==============

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

