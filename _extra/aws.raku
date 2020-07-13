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

  my %state = task-run "set mysql", "set-mysql", %(
    user => "test",
    database => "test",
    allow_host => tags()<backend_ip>,
  );

  say %state.perl;

  if %state<restart> {

    service-restart "mysql";

  }

} elsif tags()<backend> {

  package-install "mysql-client";

  bash "mysql -h {tags<database_ip>} -u test test -e 'select 100'", %(

    description => "check database connection"

  )

}
