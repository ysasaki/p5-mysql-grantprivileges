use utf8;
use strict;
use warnings;
use Test::More;
use MySQL::GrantPrivileges;

dsn_ok( undef,          undef,  'dbi:mysql:host=127.0.0.1;port=3306' );
dsn_ok( '127.0.0.1',    '3306', 'dbi:mysql:host=127.0.0.1;port=3306' );
dsn_ok( '192.168.0.10', '3307', 'dbi:mysql:host=192.168.0.10;port=3307' );

done_testing;

sub dsn_ok {
    my ( $host, $port, $dsn ) = @_;

    my %opts;
    $opts{host} = $host if $host;
    $opts{port} = $port if $port;

    my $priv = MySQL::GrantPrivileges->new(%opts);

    is $priv->dsn, $dsn,
        sprintf( "%s:%s => $dsn", $host || 'undef', $port || 'undef' );
}
