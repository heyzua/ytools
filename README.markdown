# YTools

These are a couple of YAML-based tools for working with configuration files.

### YPath

The first tool, ypath, be used to pull values from a YAML configuration and print
them to STDOUT.  It's quite useful if you need to use the YAML as a configuration
and only pull out individual values for your other scripts to use.

Say you have a YAML configuration file like:

    project:
        name: C.proj
        dependencies:
            - A.proj
            - B.proj

You could then pull out the project name 'C.proj' by running

    ytools -p /project/name YAML_FILE

You could even list all of the dependencies by running

    ytools -p /project/dependencies YAML_FILE

which would print
 
    A.proj
    B.proj

### YTemplates

The second tool, ytemplates, be used to generate configuration files
that use YAML files as the backing object binding.  A simple use case might
be that you need a configuration file generated for an environment, and you
can break out the environment-specific values into different YAML files.
In this case, you could create a file for each environment, one for production

    environment: production
    database:
        host: production.host.com
        username: produser
        password: imsecret

and another for testing

    environment: testing
    database:
        host: internal-testing.host.com
        username: testuser
        password: imsecret

With those files, you could then create an ERB template to pull in the relevant
values like:

    <settings environment="<%= environment =>">
        <database>
            <host><%= database.host %></host>
            <username><%= database.username %></username>
            <password><%= database.password %></username>
        </database>
    </settings>

Using <pre>ytemplates</pre>, you could then generate a different environment
file from each yaml file, but only have to manage one actual configuration file.
Obviously, this becomes much more useful when the number of environments grows
and the number of changes in the configuration files goes down relative to file's
size.

## Downloading

You can download the gem using

    gem install ytools

