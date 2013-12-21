use mop;

class WWW::Steam {
    # api methods documented on https://developer.valvesoftware.com/wiki/Steam_Web_API
    use JSON;
    use LWP::Simple;

    has $!api_key;
    has $!api_url = 'http://api.steampowered.com';

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
        return @{$self->api_call('IPlayerService', 'GetOwnedGames', 'v0001', steamid => $steamid)->{response}{games}};
    }

    method GetRecentlyPlayedGames {
        ...
    }

    method IsPlayingSharedGame {
        ...
    }

    method api_call($iname, $mname, $version, @args) {
        my $url = sprintf('%s/%s/%s/%s/?', $!api_url, $iname, $mname, $version);
        my %rest = (
            key => $!api_key,
            include_appinfo => 1,
            @args,
        );
        for my $k (keys %rest) {
            $url .= ("&$k=" . $rest{$k});
        }
        print "$url\n";
        my $result = get($url);
        return decode_json $result;
    }
}
