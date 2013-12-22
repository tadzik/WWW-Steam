use 5.018;
use warnings;
use lib 'lib';
use WWW::Steam;
use Set::Object 'set';
use List::Util 'reduce';
use Data::Dumper;
use Term::ANSIColor;

my $key = 'PUT YOUR API KEY HERE';
my $cl = WWW::Steam->new(api_key => $key);

my %users;
for my $arg (@ARGV) {
    if ($arg =~ /\D/) {
        my $steamid = $cl->GetUserID($arg);
        $users{$steamid} = $arg;
    } else {
        $users{$arg} = $arg;
    }
}

my %gamenames;
my %usergames;
my @sets;

for my $steamid (keys %users) {
    my @games = $cl->GetOwnedGames($steamid);
    my $set = set();
    for (@games) {
        $gamenames{$_->appid} = $_->name;
        $usergames{$steamid}{$_->appid} = $_;
        $set->insert($_->appid);
    }
    push @sets, $set;
}

my $commonset = reduce { $a * $b } @sets;
say colored("Games owned by " . join(", ", values %users) . ":", 'bold white');
for my $appid (sort { $gamenames{$a} cmp $gamenames{$b} } $commonset->elements) {
    my @neverplayed;
    for (keys %users) {
        if ($usergames{$_}{$appid}->playtime_forever == 0) {
            push @neverplayed, $users{$_}
        }
    }
    my $comment = '';
    my $colour = 'bold green';
    if (@neverplayed) {
        $comment = " (never played by: " . join(" ", @neverplayed) . ")";
        $colour = 'blue';
        if (@neverplayed == keys %users) {
            $comment = ' (never played by any of them)';
            $colour = 'red';
        }
    }
    say colored($gamenames{$appid} . $comment, $colour);
}
