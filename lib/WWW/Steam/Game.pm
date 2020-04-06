package WWW::Steam::Game;
use Moo;

has appid => (is => 'ro');
has name => (is => 'ro');
has playtime_forever => (is => 'ro');

1;
