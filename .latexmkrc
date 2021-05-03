use File::Glob ':bsd_glob';

$ENV{'TZ'} = 'Europe/Moscow';
if (exists &{'ensure_path'}) {
  ensure_path('TEXINPUTS', './moderncv//');
} else {
  $ENV{'TEXINPUTS'} = '.:./moderncv//:';
}
$pdf_mode = 1;
$dvi_mode = $postscript_mode = 0;
$out_dir = 'build';
@default_files = bsd_glob('cv-*.tex');

do './gitinfo2.pm';