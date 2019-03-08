unit class Net::RCON;

use experimental :pack;

enum SERVERDATA (
        RESPONSE_VALUE => 0,
        AUTH_RESPONSE => 2,
        EXECCOMMAND => 2,
        AUTH => 3,
);

sub connect(:$hostname, :$port, :$password) {

    my %arguments = host => $hostname // "localhost",
                    port => $port // 27015,
                    id => 0,
    ;

    my $socket = IO::Socket::INET.new(:%arguments<hostname>, :%arguments<port>);
    my $connection = $socket.accept;

    authenticate(:$connection, :$password);
}

sub authenticate(:$connection, :$password) {

    my $packet-type = SERVERDATA::AUTH;
    my $data = $password;

    send(:$connection, :$packet-type, :$data);
}

sub send(:$connection, :$packet-type, :$data) {

    my $payload = pack("VV", 1, $packet-type) ~ $data ~ pack("xx");
    $payload = pack("V", $payload.bytes) ~ $payload;

    $connection.write($payload);
}

sub recieve() {
    
}
