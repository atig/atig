.. atig documentation master file, created by
   sphinx-quickstart on Mon Mar 15 15:36:01 2010.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

atig.rb : Another Twitter Irc Gateway
==================================
atig.rbはTwitterとIRCを結ぶゲートウェイです。

スクリーンショット
------------------------------

.. image:: _static/limechat_s.png

ダウンロード
------------------------------

 - 開発版 `Github Repository`_.

.. _GitHub Repository: http://github.com/mzp/atig

特徴
------------------------------

必要なのはIRCクライアントだけ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 - IRCクライアントさえあれば、どこからでもTwitterできます。
 - CUI中毒やEmacs中毒の方でも安心してお使いいただけます。

Listsにも対応してます
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 - Listsはチャンネルになります

大抵のOSで動きます
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 - Rubyで書いてあるので大抵のOSで動作します

IRC用のソフトが流用できます。
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 - 既存のIRC用のソフトを流用することができます。
 - 例えば、IRCプロキシであるTiarraと連携させることで、24時間Twitterのログがとることが可能です



.. 構造化された設計
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    ~ tig.rbよりいいよ

その他のドキュメント
------------------------------
.. toctree::
   :maxdepth: 2

   quickstart
   feature
   irc
   commandline_options
   options
   commands
   config

Indices and tables
==================

* :ref:`genindex`
* :ref:`search`


.. |heart| replace:: ♥
