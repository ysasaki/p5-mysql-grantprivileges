# NAME

MySQL::GrantPrivileges - Generates GRANT statements by loading data from mysqld.

# SYNOPSIS

    use MySQL::GrantPrivileges;

    my $priv = Mysql::GrantPrivileges->new(
        host     => '127.0.0.1',
        port     => '3306',
        user     => 'root',
        password => 'secret',
    );

    # outputs SQL
    print $priv->to_string;

# DESCRIPTION

MySQL::GrantPrivileges is a generator of GRANT statements by loading data from
mysqld. This module accesses mysql.user and mysql.db to generate statements.

This distribution includes a script named [grant-privileges.pl](http://search.cpan.org/perldoc?grant-privileges.pl). So you can
use this script to generate GRANT statements.

# LICENSE

Copyright (C) 2013 Yoshihiro Sasaki

This is free software licensed under

    The BSD 2-Clause License

The full text of the license can be found in the LICENSE file included with
this distribution.

# AUTHOR

Yoshihiro Sasaki <ysasaki@cpan.org>
