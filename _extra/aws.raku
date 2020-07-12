say tags().perl;

if tags()<frontend> {

  package-install "nginx";

  service-enable "nginx";

  service-start "nginx";

  http-ok("localhost");
  
} elsif tags()<database> {

  package-install "mysql-server";

  service-enable "mysql";

  service-start "mysql";

  my %state = task-run "files/tasks/set-mysql";

  say %state.perl;

  if %state<restart> {

    service-restart "mysql";

  }

}
