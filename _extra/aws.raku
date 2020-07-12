if tags()<frontend> {

  package-install "nginx";

  service-enable "nginx";

  service-start "nginx";

  http-ok("localhost");
  
} elsif tags()<database> {

  package-install "mysql-server";

  service-enable "mysql";

  service-start "mysql";

}
