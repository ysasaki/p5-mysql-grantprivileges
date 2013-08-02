use utf8;
use strict;
use warnings;
use Test::More;
use MySQL::GrantPrivileges;

my $priv = new_ok 'MySQL::GrantPrivileges', [];

can_ok $priv, $_ for qw(
    user
    password
    host
    port
    dsn
    dbh
    privileges

    to_string
);

done_testing;

