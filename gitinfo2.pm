# Copyright 2018 Raphaël P. Barazzutti
#
# GitInfo2LatexMk - v0.2.1
# Inspired by Brent Longborough's update-git.sh (part of gitinfo2 LaTeX package)
#
# The original update-git.sh is supposed to be "hooked" to some git events (such that
# Post-{commit,checkout,merge}).
# Although this approach is elegant, I find a bit too intrusive and complicated
# to maintain.
#
# This Perl variant makes sense for latexmk users. The only requirement is to add
# the following line into the .latexmkrc file that lays in the root of your
# LaTeX project (create it, if absent).
#
# do './gitinfo2.pm';
#
# That's it! Now it'd work!

sub gitinfo2 {

  my $RELEASE_MATCHER = "[0-9]*.*";

  if (%GI2TM_OPTIONS) {
    if (exists $GI2TM_OPTIONS{"RELEASE_MATCHER"}) {
        $RELEASE_MATCHER = $GI2TM_OPTIONS{"RELEASE_MATCHER"};
    }
  }

  local $/ = "\n";

  # Get the path to the gitHeadInfo.gin
  chomp(my $GIN = `git rev-parse --git-path gitHeadInfo.gin`);

  # Get the first tag found in the history from the current HEAD
  chomp(my $FIRSTTAG = `git describe --tags --always --dirty='-*' 2>/dev/null`);

  # Get the first tag in history that looks like a Release
  chomp(my $RELTAG = `git describe --tags --long --always --dirty='-*' --match '$RELEASE_MATCHER'  2>/dev/null`);

  # Hoover up the metadata
  chomp(my $METADATA = `git --no-pager log -1 --date=short --decorate=short --pretty=format:"\\usepackage[shash={%h}, lhash={%H}, authname={%an}, authemail={%ae}, authsdate={%ad}, authidate={%ai}, authudate={%at}, commname={%cn}, commemail={%ce}, commsdate={%cd}, commidate={%ci}, commudate={%ct}, refnames={%d}, firsttagdescribe={$FIRSTTAG}, reltag={$RELTAG}]{gitexinfo}" HEAD 2>/dev/null`);

  # Read previous metadata
  chomp(my $METADATA_OLD = do {
    local $/;
    my $status = open(my $fh, '<', $GIN);
    $status ? <$fh> : "";
  });

  if ($METADATA ne $METADATA_OLD) {
    print("Status changed, request recompilation\n");
    open(my $fh, '>', $GIN) or die $!;
    print $fh ($METADATA . "\n");
    close($fh);
    $go_mode = 1;
  }
}

gitinfo2();
