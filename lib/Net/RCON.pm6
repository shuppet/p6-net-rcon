unit package Net::RCON;

use experimental :pack;

enum SERVERDATA is export (
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
    return $connection;
}

sub authenticate(:$connection, :$password) {
    my $packet-type = SERVERDATA::AUTH;
    my $message = $password;

    _raw_send(:$connection, :$packet-type, :$message);
    my $response = receive($connection, SERVERDATA::AUTH_RESPONSE);

    unless $response.defined {
        die "Could not authenticate against the RCON server.";
    }
}

sub send(:$connection, :$packet-type, :$message) is export {
    _raw_send(:$connection, :$packet-type, :$message);
    my $response = receive($connection, SERVERDATA::RESPONSE_VALUE);
    unless $response.defined {
        die "Received a bad response from the RCON server.";
    }

    return $response;
}

sub _raw_send(:$connection, :$packet-type, :$message) {
    my $payload = pack("VV", 1, $packet-type) ~ $message.encode ~ pack("xx");
    $payload = pack("V", $payload.bytes) ~ $payload;

    $connection.write($payload);
}

sub receive($connection, $expected-type) {
    my $response = $connection.recv(4096, :bin);
    my ($response-size, $response-id, $packet-type, $response-body) = $response.unpack("VVVa*");

    if ($response-id == 1 && $packet-type == $expected-type && $response-size >= 10 && $response-size <= 4096) {
        return $response-body;
    }

    return;
}
