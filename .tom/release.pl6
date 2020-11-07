# run `mi6 --keep release`
task-run "module release", "raku-utils-mi6", %(
  args => [
    ["yes"], 
    %( next-version => "=0.1.11" ),
    "release",
  ]
);
