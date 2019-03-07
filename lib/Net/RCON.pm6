unit class Net::RCON;

use IO::Socket::INET;
use experimental :pack;

constant {
    SERVERDATA_RESPONSE_VALUE => 0,
    SERVERDATA_AUTH_RESPONSE  => 2,
    SERVERDATA_EXECCOMMAND    => 2,
    SERVERDATA_AUTH           => 3
};

sub connect(:$hostname, :$port, :$password) {

    my %arguments = host => $hostname || "localhost",
                    port => $port || 27015,
                    id => 0,
    ;

    my $socket = IO::Socket::INET.new(:%arguments<hostname>, :%arguments<port>);
    my $connection = $socket.accept;

    authenticate(:$connection, :$password);
}

sub authenticate(:$connection, :$password) {

    my $type = SERVERDATA_AUTH;
    my $data = $password;

    send(:$connection, :$type, :$data);
}

sub send(:$connection, :$type, :$data) {

    my $payload = pack("VV", 1, $type) ~ $data ~ pack("xx");
    $payload = pack("V", $payload.bytes) ~ $payload;

    $connection.write($payload);
}

sub recieve() {
    
}
