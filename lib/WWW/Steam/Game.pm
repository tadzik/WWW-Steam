use mop;

class WWW::Steam::Game {
    has $!appid is ro;
    has $!name is ro;
    has $!playtime_forever is ro;

    method Str {
        return $!name
    }
}
