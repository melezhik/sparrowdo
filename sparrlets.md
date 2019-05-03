# Sparrlets


Sparrlets are Git based Sparrowdo scenarios.


# How it works?

1. Create a sparrowdo scenario

```
    $ nano sparrowfile

      my $name  = config<name>;
      bash "echo Hi $name, I am Sparrlet"

    $ nano config.pl6

      {
        name => "Stranger"
      }

```
    
2. Commit your code to Git 

```
    $ git init .
    $ git add sparrowfile config.pl6
    $ git commit -a -m 'My Sparrlet Scenario'
```

3. Push you code to remote repository

```
    $ git remote add origin https://github.com/melezhik/sparrlet-example.git
    $ git push origin master
```

4. Run sparrlet with sparrowdo client 

```
    $ sparrowdo --git=https://github.com/melezhik/sparrlet-example.git
```

# Sparrlet configuration

  
Create config.pl6 file in $CWD directory and it will be copied into sparrlet environment during execution.

This is how you override default sparrlets settings:

```
    $ nano config.pl6

    {
      name => "Alexey"
    }

```

```
    $ sparrowdo --git=https://github.com/melezhik/sparrlet-example.git

```

# Caveats

* You need to install edge version of Sparrowdo ( `zef install https://github.com/melezhik/sparrowdo.git` ) to start playing with sparrlets

* Sparrlets are alpha feature, don't blame me if something goes awry :)), but I promise to response to GH issues :))
