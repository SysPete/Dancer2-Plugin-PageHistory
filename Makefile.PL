use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Dancer::Plugin::PageHistory',
    AUTHOR       => q{Peter Mottram (SysPete) <peter@sysnix.com>},
    VERSION_FROM => 'lib/Dancer/Plugin/PageHistory.pm',
    ABSTRACT => 'Collect interesting pages a user has visited in the session',
    LICENSE  => 'perl',
    PL_FILES => {},
    MIN_PERL_VERSION   => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Class::Load' => 0,
        'Test::More'  => 0,
        'Test::Roo'   => 0,
      },
    PREREQ_PM => {
        'Dancer'           => 1.3098,
        'Moo'              => '1.004005',
        'namespace::clean' => 0,
        'Sub::Quote'       => 0,
        'Type::Tiny'       => 0,
      },
    dist      => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean      => { FILES => 'Dancer-Plugin-PageHistory-*' },
    META_MERGE => {
        resources => {
            repository =>
              'https://github.com/SysPete/Dancer-Plugin-PageHistory',
            bugtracker =>
              'https://github.com/SysPete/Dancer-Plugin-PageHistory/issues',
            IRC => 'irc://irc.freenode.net/#interchange',
        },
    },
);
