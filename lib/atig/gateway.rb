require 'atig/gateway/session'

Atig::Gateway::Session.agents   = [
                                   Atig::Agent::FullList,
                                   Atig::Agent::Following,
                                   Atig::Agent::ListStatus,
                                   Atig::Agent::Mention,
                                   Atig::Agent::Dm,
                                   Atig::Agent::Timeline,
                                   Atig::Agent::Cleanup,
                                   Atig::Agent::UserStream,
                                   Atig::Agent::Noretweets,
                                  ]

Atig::Gateway::Session.ifilters = [
                                   Atig::IFilter::Retweet,
                                   Atig::IFilter::RetweetTime,
                                   Atig::IFilter::Sanitize,
                                   Atig::IFilter::ExpandUrl,
                                   Atig::IFilter::Strip.new(%w{ *tw* *Sh*}),
                                   Atig::IFilter::Tid,
                                   Atig::IFilter::Sid
                                  ]

Atig::Gateway::Session.ofilters = [
                                   Atig::OFilter::EscapeUrl,
                                   Atig::OFilter::ShortUrl,
                                   Atig::OFilter::Geo,
                                   Atig::OFilter::Footer,
                                  ]

Atig::Gateway::Session.commands = [
                                   Atig::Command::Retweet,
                                   Atig::Command::Reply,
                                   Atig::Command::User,
                                   Atig::Command::Favorite,
                                   Atig::Command::Uptime,
                                   Atig::Command::Destroy,
                                   Atig::Command::Status,
                                   Atig::Command::Thread,
                                   Atig::Command::Time,
                                   Atig::Command::Version,
                                   Atig::Command::UserInfo,
                                   Atig::Command::Whois,
                                   Atig::Command::Option,
                                   Atig::Command::Location,
                                   Atig::Command::Name,
                                   Atig::Command::Autofix,
                                   Atig::Command::Limit,
                                   Atig::Command::Search,
                                   Atig::Command::Refresh,
                                   Atig::Command::Spam,
                                   Atig::Command::Dm,
                                  ]

Atig::Gateway::Session.channels = [
                                   Atig::Channel::Timeline,
                                   Atig::Channel::Mention,
                                   Atig::Channel::Dm,
                                   Atig::Channel::List,
                                   Atig::Channel::Retweet,
                                  ]
