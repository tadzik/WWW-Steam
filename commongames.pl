use lib 'lib';
use WWW::Steam;
use Term::ANSIColor;

my $key = 'PUT YOUR API KEY HERE';
my $cl = WWW::Steam.new(api_key => $key);

my %users;
for @*ARGS -> $arg {
    if $arg ~~ /\D/ {
        my $steamid = $cl.GetUserID($arg);
        %users{$steamid} = $arg;
    } else {
        %users{$arg} = $arg;
    }
}

my %gamenames;
my %usergames;
my @sets;

for %users.keys -> $steamid {
    my @games = $cl.GetOwnedGames($steamid);
    my $set = SetHash.new;
    for @games -> $g {
        %gamenames{$g.appid} = $g.name;
        %usergames{$steamid}{$g.appid} = $g;
        $set{$g.appid} = True;
    }
    @sets.push: $set;
}

my $commonset = [(&)] @sets;
say colored("Games owned by " ~ %users.values.join(", ") ~ ":", 'bold white');
for $commonset.keys.sort({%gamenames{$^a} cmp %gamenames{$^b}}) -> $appid {
    my @neverplayed;
    for %users.keys -> $k {
        if %usergames{$k}{$appid}.playtime_forever == 0 {
            @neverplayed.push: %users{$k}
        }
    }
    my $comment = '';
    my $colour = 'bold green';
    if @neverplayed {
        $comment = " (never played by: " ~ @neverplayed.join(" ") ~ ")";
        $colour = 'blue';
        if @neverplayed == %users.keys {
            $comment = ' (never played by any of them)';
            $colour = 'red';
        }
    }
    say colored(%gamenames{$appid} ~ $comment, $colour);
}
