use utf8;
use strict;
use warnings;
use Test::More;
use MySQL::GrantPrivileges;

my $privileges = {
    'db' => [
        {   'host'       => '%',
            'db'         => 'test',
            'privileges' => [ 'CREATE', 'CREATE ROUTINE' ],
            'user'       => ''
        },
        {   'host'       => 'localhost',
            'db'         => 'test\_%',
            'privileges' => [ 'CREATE', ],
            'user'       => 'foo'
        }
    ],
    'user' => [
        {   'host'       => 'localhost',
            'password'   => '*33B85B51CD95EFDCB4F4E0E7523AD47F6CD99502',
            'privileges' => [ 'CREATE', ],
            'user'       => 'root'
        },
        {   'host'       => 'localhost',
            'password'   => '',
            'privileges' => ['CREATE'],
            'user'       => 'foo'
        },
        {   'host'       => 'localhost',
            'password'   => '',
            'privileges' => [],
            'user'       => ''
        }
    ]
};

my $priv = MySQL::GrantPrivileges->new( privileges => $privileges );
is_deeply $priv->privileges, $privileges, 'privileges ok';

my $sql = <<'EOM';
GRANT CREATE ON *.* TO 'root'@'localhost' IDENTIFIED BY PASSWORD '*33B85B51CD95EFDCB4F4E0E7523AD47F6CD99502';
GRANT CREATE ON *.* TO 'foo'@'localhost';
GRANT USAGE ON *.* TO ''@'localhost';
GRANT CREATE, CREATE ROUTINE ON `test`.* TO ''@'%';
GRANT CREATE ON `test\_%`.* TO 'foo'@'localhost';
EOM
chomp $sql;

is $priv->to_string, $sql, 'SQL OK';

done_testing;

