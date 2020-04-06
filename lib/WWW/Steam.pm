package WWW::Steam;
use Moo;
use experimental 'signatures';
# api subs documented on https://developer.valvesoftware.com/wiki/Steam_Web_API
use JSON;
use LWP::Simple;
use WWW::Steam::Game;

has api_key => (is => 'ro', required => 1);
has api_url => (is => 'ro', default => sub { 'http://api.steampowered.com' });

sub GetUserID($self, $username) {
    # talk about evil
    my $xml = get "http://steamcommunity.com/id/$username?xml=1";
    $xml =~ m{<steamID64>(\d+)</steamID64>};
    return $1;
}

sub GetNewsForApp {
    ...
}

sub GetGlobalAchievementPercentagesForApp {
    ...
}

sub GetPlayerSummaries {
    ...
}

sub GetFriendList {
    ...
}

sub GetPlayerAchievements {
    ...
}

sub GetUserStatsForGame {
    ...
}

sub GetOwnedGames($self, $steamid) {
    return map { WWW::Steam::Game->new(appid => $_->{appid}, name => $_->{name},
        playtime_forever => $_->{playtime_forever}) }
    @{$self->api_call('IPlayerService', 'GetOwnedGames', 'v0001',
    steamid => $steamid)->{response}{games}};
}

sub GetRecentlyPlayedGames {
    ...
}

sub IsPlayingSharedGame {
    ...
}

sub api_call($self, $iname, $mname, $version, @args) {
    my $url = sprintf('%s/%s/%s/%s/?', $self->api_url, $iname, $mname, $version);
    my %rest = (
        key => $self->api_key,
        include_appinfo => 1,
        @args,
    );
    for my $k (keys %rest) {
        $url .= ("&$k=" . $rest{$k});
    }
    my $result = get($url);
    return decode_json $result;
}

1;
