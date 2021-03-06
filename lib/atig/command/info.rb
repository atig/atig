# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module Command
    module Info
      def user(db, api, name, &f)
        if user = db.followings.find_by_screen_name(name) then
          f.call user
        else
          api.delay(0) do|t|
            user = t.get "users/show",:screen_name=>name
            f.call user
          end
        end
      end

      def status(db, api, id, &f)
        if status = db.statuses.find_by_status_id(id) then
          f.call status
        else
          api.delay(0) do|t|
            status = t.get "statuses/show/#{id}"
            db.statuses.transaction do|d|
              d.add status: status, user: status.user, source: :thread
              f.call d.find_by_status_id(id)
            end
          end
        end
      end

      def find_status(db, tid_or_screen_name)
        find = lambda do|x|
          xs = db.statuses.find_by_screen_name(x, limit:1)
          unless xs.empty? then
            xs.first
          else
            nil
          end
        end

        (db.statuses.find_by_tid(tid_or_screen_name) ||
         db.statuses.find_by_sid(tid_or_screen_name) ||
         find.call(tid_or_screen_name) ||
         find.call(tid_or_screen_name.sub(/\A@/,'')))
      end

      module_function :user,:status, :find_status
    end
  end
end
