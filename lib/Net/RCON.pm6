unit class Net::RCON;

use experimental :pack;

enum SERVERDATA is export (
        RESPONSE_VALUE => 0,
        AUTH_RESPONSE => 2,
        EXECCOMMAND => 2,
        AUTH => 3,
);

has $.host = 'localhost';
has $.port = 27015;
has $!connection;

method connect($password) is export {
    $!connection = IO::Socket::INET.new(
        :host($.host),
        :port($.port)
    );

    self.authenticate($password);
}

method authenticate($password) {
    my $packet-type = SERVERDATA::AUTH;
    my $message = $password;

    self!raw-send(:$packet-type, :$message);
    my $response = self.receive(SERVERDATA::AUTH_RESPONSE);

    unless $response.defined {
        die "Could not authenticate against the RCON server.";
    }
}

method send(:$packet-type, :$message) {
    self!raw-send(:$packet-type, :$message);
    my $response = self.receive(SERVERDATA::RESPONSE_VALUE);
    unless $response.defined {
        die "Received a bad response from the RCON server.";
    }

    return $response;
}

method !raw-send(:$packet-type, :$message) {
    my $payload = pack("VV", 1, $packet-type) ~ $message.encode ~ pack("xx");
    $payload = pack("V", $payload.bytes) ~ $payload;

    $!connection.write($payload);
}

method receive($expected-type) {
    my $response = $!connection.recv(4096, :bin);
    my ($response-size, $response-id, $packet-type, $response-body) = $response.unpack("VVVa*");

    if ($response-id == 1 && $packet-type == $expected-type && $response-size >= 10 && $response-size <= 4096) {
        return $response-body;
    }

    return;
}
