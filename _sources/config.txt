設定
==============================

概要
------------------------------
 - atig.rbは起動時に `~/.atig/config` を読み込みます。
 - `~/.atig/config` はRubyのコードが記述可能です。
 - `Atig::Gateway::Session.<some_field>` を変更すると、atig.rbの動作をカスタマイズできます。

利用可能なコマンドの変更
------------------------------
`Atig::Gateway::Session.commands` を変更すれば、利用可能な :doc:`commands` を変更できます::

  Atig::Gateway::Session.commands = [
                                     Atig::Command::Retweet,
                                     Atig::Command::Reply,
				     ..
                                    ]

標準で次のコマンドが用意されています。

Atig::Command::Retweet
  ``/me retweet ...`` を提供するクラス
Atig::Command::Reply
  ``/me reply ...`` を提供するクラス
Atig::Command::User
  ``/me user ...`` を提供するクラス
Atig::Command::Favorite
  ``/me fav, unfav ...`` を提供するクラス
Atig::Command::Uptime
  ``/me uptime ...`` を提供するクラス
Atig::Command::Destroy
  ``/me destory ...`` を提供するクラス
Atig::Command::Status
  通常の発言時に使われる内部コマンド
Atig::Command::Thread
  ``/me thread ...`` を提供するクラス
Atig::Command::Time
  ``/me time ...`` を提供するクラス
Atig::Command::Version
  ``/me verison ...`` を提供するクラス
Atig::Command::UserInfo
  ``/me userinfo ...`` を提供するクラス
Atig::Command::Whois
  ``/whois ...`` を提供するクラス
Atig::Command::Option
  ``/me opt ...`` を提供するクラス
Atig::Command::Limit
  ``/me limit`` を提供するクラス
Atig::Command::Search
  ``/me search`` を提供するクラス
Atig::Command::Refresh
  ``/me refresh`` を提供するクラス
                                   Atig::Command::Spam,

取得するAPIの変更
------------------------------
`Atig::Gateway::Session.agents` を変更すると、発言やFollowingを取得するのに利用するAPIを変更できます。::

  Atig::Gateway::Session.agents  = [
                                     Atig::Agent::List,
                                     Atig::Agent::Following,
				     ...
                                    ]

標準で次のAgentが用意されています。

Atig::Agent::OwnList
  自分のリストのfollowingを取得します。FullListと同時に指定できません。
Atig::Agent::FullList
  自分のリストと自分がフォローしているリストのfollowingを取得します。OwnListと同時に指定できません。
Atig::Agent::Following
  自分のfollowingを取得します。
Atig::Agent::ListStatus
  リスト内の発言を取得します。フォローせずに、Listでだけfollowしている人の発言を取得するために必要です。
Atig::Agent::Mention
  自分への言及(mention)を取得します。
Atig::Agent::Dm
  自分へのダイレクトメッセージを取得します。
Atig::Agent::Timeline
  自分のタイムラインを取得します。
Atig::Agent::Cleanup
  定期的にキャッシュのうち、古い内容を削除します。

取得した発言の加工方法の変更
------------------------------
`Atig::Gateway::Session.ifilters` を変更すると、取得した発言の加工方法を変更できます。::

  Atig::Gateway::Session.ifilters = [
                                     Atig::IFilter::Utf7,
                                     Atig::IFilter::Sanitize,
                                     ...
                                    ]

標準で次のIFilterが用意されています。

Atig::IFilter::Utf7
  utf7をデコードします。
Atig::IFilter::Sanitize
  &gt; などを置き換えます。
Atig::IFilter::ExpandUrl
  短縮URLを展開します。
Atig::IFilter::Strip.new([``footer1``, ``footer2``, ...])
  指定したフッタを除去します。
Atig::IFilter::Retweet
  公式RTの先頭に♺ をつけます。
Atig::IFilter::RetweetTime
  公式RTの末尾に元発言の日時を表示します。
Atig::IFilter::Tid
  発言の末尾に、tidをつけます。 :doc:`options` も参照してください。
Atig::IFilter::Sid
  発言の末尾に、sidをつけます。 :doc:`options` も参照してください。

自分の発言の加工
------------------------------
`Atig::Gateway::Session.ofilters` を変更すると、自分の発言の加工方法を変更できます。::

Atig::Gateway::Session.ofilters = [
                                   Atig::OFilter::EscapeUrl,
                                   Atig::OFilter::ShortUrl,
                                   Atig::OFilter::Geo,
                                   Atig::OFilter::Footer,
                                  ]

標準で次のOFilterが用意されています。

Atig::OFilter::EscapeUrl
  URLエスケープを行ないます。
Atig::OFilter::ShortUrl
  URLを短縮します。 :doc:`options` も参照してください。
Atig::OFilter::Geo
  位置情報を付加します。 :doc:`options` も参照してください。
Atig::OFilter::Footer
  フッターを付加します。 :doc:`options` も参照してください。

チャンネルの変更
------------------------------
`Atig::Gateway::Session.channels` を変更すると、作成するチャンネルを変更できます。::

  Atig::Gateway::Session.channels = [
                                     Atig::Channel::Timeline,
                                     Atig::Channel::Mention,
                                     Atig::Channel::Dm,
                                     Atig::Channel::List,
                                     Atig::Channel::Retweet
                                    ]

標準で次のChannelが用意されています。

Atig::Channel::Timeline
  フォローしている人全員の発言を表示する `#twitter` を作成します。
Atig::Channel::Mention
  自分への言及を表示する `#mention` を作成します。
Atig::Channel::Retweet
  自分のフォローしている人の公式RTを表示する `#retweet` を作成します。
Atig::Channel::Dm
  DMの受信時にチャンネルを作成します。
Atig::Channel::List
  リストごとにチャンネルを作成します。
