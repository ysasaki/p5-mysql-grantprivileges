#!perl

use utf8;
use strict;
use warnings;
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
use Pod::Usage;
use MySQL::GrantPrivileges;

GetOptions(
    \my %opts,
    'user|u=s',
    'password|p=s',
    'host|h=s',
    'port|P=i',
    'help',
) or pod2usage(1);

pod2usage(0) if $opts{help};

my $priv = MySQL::GrantPrivileges->new(%opts);
print $priv->to_string, "\n";


__END__

=encoding utf-8

=head1 NAME

grant-privileges.pl - Generates GRANT statments by loading data from mysqld

=head1 SYNOPSIS

grant-privileges.pl [--user USER] [--password PASSWORD] [--host HOST]
                    [--port PORT] [--help]

    --user | -u
        Usename to connect mysqld. default value is 'root'.

    --password | -p
        Password to connect mysqld. default value is ''.

    --host | -h
        Hostname to connect mysqld. default value is '127.0.0.1'.

    --port | -P
        Port number to connect mysqld. default value is '3306'.

    --help
        Show this messages.

=head1 LICENSE

Copyright (C) 2013 Yoshihiro Sasaki

This is free software licensed under

    The BSD 2-Clause License

The full text of the license can be found in the LICENSE file included with
this distribution.

=head1 AUTHOR

Yoshihiro Sasaki E<lt>ysasaki@cpan.orgE<gt>

=cut
