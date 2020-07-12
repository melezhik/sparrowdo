package-install "python3";
package-install "python3-pip";

#task-run "speedtest","speedtest-cli";
task-run "disk check", "df-check", %(
  threshold => 19
);
