#!/usr/bin/env perl

use File::Glob ':bsd_glob';

if (exists &{'ensure_path'}) {
  ensure_path('TEXINPUTS', './third_party/moderncv//');
} else {
  $ENV{'TEXINPUTS'} = '.:./third_party/moderncv//:';
}
$ENV{'TZ'} = 'Europe/Moscow';
$pdf_mode = 1;
$dvi_mode = $postscript_mode = 0;
$out_dir = 'build';
@default_files = bsd_glob('cv-*.tex');

do './third_party/gitinfo2.pm';
