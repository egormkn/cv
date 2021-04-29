$ENV{'TZ'}='Europe/Moscow';
if (exists &{'ensure_path'}) {
  ensure_path('TEXINPUTS', './moderncv//');
} else {
  $ENV{'TEXINPUTS'} = '.:./moderncv//:';
}
