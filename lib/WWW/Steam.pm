class WWW::Steam::Game {
    has $.appid;
    has $.name;
    has $.playtime_forever;
}

class WWW::Steam {
    # api methods documented on https://developer.valvesoftware.com/wiki/Steam_Web_API
    use JSON::Tiny;

    has $.api_key;
    has $.api_url = 'api.steampowered.com';

    method fetch($path, $host) {
        my $s = IO::Socket::INET.new(:host($host), :port(80));
        print "Connecting to $host, requesting $path";
        $s.send("GET $path HTTP/1.1\r\n");
        $s.send("User-Agent: perl6handcraftedshit\r\n");
        $s.send("Host: $host\r\n");
        $s.send("Accept: */*\r\n");
        $s.send("\r\n");
        my ($buf, $g) = '';
        while $g = $s.get {
            print '.';
            $buf ~= $g;
        }
        say " Got it";

        return $buf.split(/\r?\n\r?\n/, 2)[1];

        CATCH {
            die "Could not download $path {$_.message}"
        }
    }

    method get($path, $host = $!api_url) {
        for 1..3 {
            return self.fetch($path, $host);
            CATCH {
                note "Something blew up, retrying....";
                next;
            }
        }
        die "Unable to get $path, sorry :("
    }

    method GetUserID($username) {
        # talk about evil
        my $xml = self.get: "/id/$username?xml=1", 'steamcommunity.com';
        $xml ~~ m{'<steamID64>' (\d+) '</steamID64>'};
        return ~$0;
    }

    method GetNewsForApp {
        ...
    }

    method GetGlobalAchievementPercentagesForApp {
        ...
    }

    method GetPlayerSummaries {
        ...
    }

    method GetFriendList {
        ...
    }

    method GetPlayerAchievements {
        ...
    }

    method GetUserStatsForGame {
        ...
    }

    method GetOwnedGames($steamid) {
        self.api_call('IPlayerService', 'GetOwnedGames', 'v0001',
                      :$steamid)<response><games>.map: {
            WWW::Steam::Game.new(appid => $_<appid>, name => $_<name>,
                                 playtime_forever => $_<playtime_forever>)
        };
    }

    method GetRecentlyPlayedGames {
        ...
    }

    method IsPlayingSharedGame {
        ...
    }

    method api_call($iname, $mname, $version, *%args) {
        my $path = sprintf('/%s/%s/%s/?', $iname, $mname, $version);
        my %rest =
            key => $!api_key,
            include_appinfo => 1,
            %args;
        for %rest.keys -> $k {
            $path ~= ("&$k=" ~ %rest{$k});
        }
        my $result = self.get($path);
        return from-json $result;
    }
}
