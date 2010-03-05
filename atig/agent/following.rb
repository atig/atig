#! /opt/local/bin/ruby -w
            friends = t.get("statuses/friends/#{@db.me.id}", :users)
          end

          friends.each do|friend|
            friend[:only] = !followers.include?(friend.id)
          end

          @db.transaction{|d|
            d.followings.update friends
          }
        end
      end
    end
  end
end
