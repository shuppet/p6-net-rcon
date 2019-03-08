unit class Net::RCON;

use experimental :pack;

enum SERVERDATA (
        RESPONSE_VALUE => 0,
        AUTH_RESPONSE => 2,
        EXECCOMMAND => 2,
        AUTH => 3,
);

sub connect(:$host, :$port, :$password) is export {

    my %arguments = host => $host // "localhost",
                    port => $port // 27015,
    ;

    my $connection = IO::Socket::INET.new(|%arguments);

    authenticate(:$connection, :$password);
}

sub authenticate(:$connection, :$password) {

    my $packet-type = SERVERDATA::AUTH;
    my $message = $password;

    send(:$connection, :$packet-type, :$message);
}

sub send(:$connection, :$packet-type, :$message) {

    my $payload = pack("VV", 1, $packet-type) ~ $message ~ pack("xx");
    $payload = pack("V", $payload.bytes) ~ $payload;

    $connection.write($payload);
}

sub recieve() {
    
}
