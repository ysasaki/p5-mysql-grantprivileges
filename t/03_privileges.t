use utf8;
use strict;
use warnings;
use Test::More;
use Test::Requires;
use MySQL::GrantPrivileges;

test_requires 'Test::mysqld';
test_requires 'Test::TypeConstraints';

my $mysqld = Test::mysqld->new( my_cnf => { 'skip-networking' => '', } )
    or plan skip_all => "Fail to start mysqld";

my $priv = MySQL::GrantPrivileges->new( dsn => $mysqld->dsn );

my $privileges = $priv->privileges;

subtest 'checking a privileges structure' => sub {
    type_isa( $privileges,         'HashRef' );
    type_isa( $privileges->{user}, 'ArrayRef[HashRef]' );
    type_isa( $privileges->{db},   'ArrayRef[HashRef]' );
};

if ( scalar @{ $privileges->{user} } > 0 ) {
    my $row = $privileges->{user}->[0];

    subtest 'checking a user structure' => sub {
        type_isa( $row,               'HashRef' );
        type_isa( $row->{host},       'Str' );
        type_isa( $row->{user},       'Str' );
        type_isa( $row->{password},   'Str' );
        type_isa( $row->{privileges}, 'ArrayRef[Str]' );
    };
}

if ( scalar @{ $privileges->{db} } > 0 ) {
    my $row = $privileges->{db}->[0];

    subtest 'checking a db structure' => sub {
        type_isa( $row,               'HashRef' );
        type_isa( $row->{host},       'Str' );
        type_isa( $row->{db},         'Str' );
        type_isa( $row->{user},       'Str' );
        type_isa( $row->{privileges}, 'ArrayRef[Str]' );
    };
}

note explain $privileges;

done_testing;
