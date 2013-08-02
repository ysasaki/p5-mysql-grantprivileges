package MySQL::GrantPrivileges;

use 5.008005;
use Moo;
use DBI;

our $VERSION = "0.01";

has 'user' => (
    is      => 'ro',
    default => 'root'
);

has 'password' => (
    is      => 'ro',
    default => '',
);

has 'host' => (
    is      => 'ro',
    default => '127.0.0.1',
);

has 'port' => (
    is      => 'ro',
    default => '3306',
);

has 'dsn' => ( is => 'lazy' );

has 'dbh' => ( is => 'lazy', predicate => 1 );

has 'privileges' => ( is => 'lazy' );

# _build_*

sub _build_dsn {
    my $self = shift;
    return sprintf 'dbi:mysql:host=%s;port=%s', $self->host, $self->port;
}

sub _build_dbh {
    my $self = shift;
    my $dbh
        = DBI->connect( $self->dsn, $self->user, $self->password,
        { RaiseError => 1, AutoCommit => 1 } )
        or Carp::croak( "Cannot connect database: " . DBI->errstr );

    return $dbh;
}

# List of column names that don't match with privilege names.
# http://dev.mysql.com/doc/refman/5.6/en/privileges-provided.html
my %EXCEPTION_COLUMNS = (
    'grant_priv'            => 'GRANT OPTION',
    'create_tmp_table_priv' => 'CREATE TEMPORARY TABLES',
    'proxies_priv'          => 'PROXY',
    'repl_client_priv'      => 'REPLICATION CLIENT',
    'repl_slave_priv'       => 'REPLICATION SLAVE',
    'show_db_priv'          => 'SHOW DATABASES',
);

sub _build_privileges {
    my $self = shift;
    my $dbh  = $self->dbh;

    my $privileges = {};
    for (qw(user db)) {
        my $fetched
            = $dbh->selectall_arrayref(
            sprintf( "SELECT * FROM mysql.%s", $_ ),
            { Slice => {} } );

        if ( $dbh->err and ( my $errstr = $dbh->errstr ) ) {
            $dbh->disconnect;
            die "Cannot fetch privileges from database: $errstr";
        }

        my @filtered;
        for my $datum (@$fetched) {
            my $row = {};

            for (qw(host db user password)) {
                $row->{$_} = $datum->{ ucfirst($_) }
                    if defined $datum->{ ucfirst($_) };
            }

            $row->{privileges} = [];
            for my $key ( grep /^\w+_priv$/, keys %$datum ) {
                if ( $datum->{$key} eq 'Y' ) {
                    my $priv;
                    if ( $EXCEPTION_COLUMNS{ lc $key } ) {
                        $priv = $EXCEPTION_COLUMNS{ lc $key };
                    }
                    else {
                        ($priv) = $key =~ m/^(\w+)_priv$/;
                        $priv =~ s/_/ /g;
                    }
                    push @{ $row->{privileges} }, uc $priv;
                }
            }
            push @filtered, $row;
        }

        $privileges->{$_} = \@filtered;
    }

    return $privileges;
}

# method

sub to_string {
    my $self       = shift;
    my $privileges = $self->privileges;

    my @line;
    for my $type (qw(user db)) {

        for my $row ( @{ $privileges->{$type} } ) {

            my $privs
                = scalar @{ $row->{privileges} }
                ? join ', ', @{ $row->{privileges} }
                : 'USAGE';

            my $db_and_tbl = '*.*';
            if ( $row->{db} ) {
                $db_and_tbl = sprintf '`%s`.*', $row->{db};
            }

            my $sql = sprintf( "GRANT %s ON %s TO '%s'\@'%s'",
                $privs, $db_and_tbl, $row->{user}, $row->{host} );

            if ( $row->{password} ) {
                $sql .= sprintf " IDENTIFIED BY PASSWORD '%s'",
                    $row->{password};
            }

            $sql .= ';';

            push @line, $sql;
        }
    }

    return join "\n", @line;
}

sub DEMOLISH {
    my $self = shift;
    $self->dbh->disconnect if $self->has_dbh;
}

1;
__END__

=encoding utf-8

=head1 NAME

MySQL::GrantPrivileges - Generates GRANT statements by loading data from mysqld.

=head1 SYNOPSIS

    use MySQL::GrantPrivileges;

    my $priv = Mysql::GrantPrivileges->new(
        host     => '127.0.0.1',
        port     => '3306',
        user     => 'root',
        password => 'secret',
    );

    # outputs SQL
    print $priv->to_string;

=head1 DESCRIPTION

MySQL::GrantPrivileges is a generator of GRANT statements by loading data from
mysqld. This module accesses mysql.user and mysql.db to generate statements.

This distribution includes a script named L<grant-privileges.pl>. So you can
use this script to generate GRANT statements.

=head1 LICENSE

Copyright (C) 2013 Yoshihiro Sasaki

This is free software licensed under

    The BSD 2-Clause License

The full text of the license can be found in the LICENSE file included with
this distribution.

=head1 AUTHOR

Yoshihiro Sasaki E<lt>ysasaki@cpan.orgE<gt>

=cut

