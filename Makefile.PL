use ExtUtils::MakeMaker;

WriteMakefile (
  AUTHOR        => 'Casey West <casey@geeknest.com>',
  ABSTRACT      => "Simply Sending Email",
  NAME          => 'Email::Send',
  PREREQ_PM     => {
    'Class::Accessor::Fast' => '0.19',
    'Email::Address'    => '1.80',
    'Email::Simple'     => '1.92',
    'File::Spec'        =>      0, # min ver unknown; core in 5.005
    'Module::Pluggable' => '2.97', # topic safety
    'Return::Value'     => '1.28',
    'Scalar::Util'      => '1.02', # reason unknown;  core in 5.7.3
    'Symbol'            => '0.00', # min ver unknown; core in 5.002
    'Test::More'        => '0.47', # reason unknown;  core in 5.8.1
  },
  VERSION_FROM  => 'lib/Email/Send.pm',
);
