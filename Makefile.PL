use ExtUtils::MakeMaker;

WriteMakefile (
  AUTHOR        => 'Casey West <casey@geeknest.com>',
  ABSTRACT      => "Simply Sending Email",
  NAME          => 'Email::Send',
  PREREQ_PM     => {
    'Class::Accessor::Fast' => '0.19',
    'Email::Address'    => '1.80',
    'Email::Simple'     => '1.92',
    'File::Spec'        =>      0, # min ver unknown
    'Module::Pluggable' => '2.97', # topic safety
    'Return::Value'     => '1.28',
    'Scalar::Util'      => '1.02',
    'Test::More'        => '0.47',
  },
  VERSION_FROM  => 'lib/Email/Send.pm',
);
