use strict;
use ExtUtils::MakeMaker;

WriteMakefile (
  AUTHOR        => 'Casey West <casey@geeknest.com>',
  NAME          => 'Email::Send',
  ABSTRACT_FROM => 'lib/Email/Send.pm',
  PREREQ_PM     => {
    'Email::Address'        => '1.80', # avoid many 'returns bad addr' bugs
    'Email::Simple'         => '1.92', # previous versions have prereq problems
    'File::Spec'            =>      0, # min ver unknown; core in 5.005
    'Module::Pluggable'     => '2.97', # topic safety
    'Return::Value'         => '1.28', # avoid num/bool explosions on 5.6.1
    'Scalar::Util'          => '1.02', # reason unknown;  core in 5.7.3
    'Symbol'                => '0.00', # min ver unknown; core in 5.002
    'Test::More'            => '0.47', # reason unknown;  core in 5.8.1
  },
  VERSION_FROM  => 'lib/Email/Send.pm',
  (eval { ExtUtils::MakeMaker->VERSION(6.21) } ? (LICENSE => 'perl') : ()),
);
