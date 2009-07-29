use strict;
use warnings;
use inc::Module::Install;
use ExtUtils::Depends;

name 'signatures';
all_from 'lib/signatures.pm';

requires 'B::Hooks::OP::Check' => '0.17';
requires 'B::Hooks::OP::PPAddr';
requires 'B::Hooks::Parser' => '0.07';
requires 'B::Hooks::EndOfScope' => '0.08';

build_requires 'B::Hooks::OP::Check' => '0.17';
build_requires 'B::Hooks::OP::PPAddr';
build_requires 'B::Hooks::Parser' => '0.07';

# minimum version that works on Win32+gcc
configure_requires 'ExtUtils::Depends' => '0.302';
configure_requires 'B::Hooks::OP::Check' => '0.18';
# minimum version that depends on ExtUtils::Depends 0.302
configure_requires 'B::Hooks::OP::PPAddr' => '0.03';
# minimum version that depends on ExtUtils::Depends 0.302
configure_requires 'B::Hooks::Parser' => '0.07';

my $pkg = ExtUtils::Depends->new('signatures', 'B::Hooks::OP::Check', 'B::Hooks::OP::PPAddr', 'B::Hooks::Parser');
$pkg->add_xs('signatures.xs');
$pkg->add_pm('lib/signatures.pm' => '$(INST_LIB)/signatures.pm');

makemaker_args($pkg->get_makefile_vars);

extra_tests();

repository 'git://github.com/rafl/signatures.git';
bugtracker 'http://rt.cpan.org/Public/Dist/Display.html?Name=signatures';

WriteAll;
