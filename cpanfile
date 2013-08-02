requires 'perl', '5.008001';

requires 'Moo',        '1.003000';
requires 'DBI',        '1.628';
requires 'DBD::mysql', '4.023';

on 'test' => sub {
    requires 'Test::More',     '0.98';
    requires 'Test::Requires', '0.07';
};

on 'develop' => sub {
    requires 'Test::mysqld',          '0.17';
    requires 'Test::TypeConstraints', '0.07';
};
