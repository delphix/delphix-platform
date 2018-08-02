# Delphix Appliance Platform

## Quickstart

### Building

Run this command on "dlpxdc.co" to create the VM used to do the build:

    $ dc clone-latest --size COMPUTE_LARGE bootstrap-18-04 $USER-bootstrap

Log into that VM using the "ubuntu" user, and run these commands:

    $ git clone https://github.com/prakashsurya/delphix-platform.git
    $ cd delphix-platform
    $ ansible-playbook bootstrap/playbook.yml
    $ ./scripts/docker-run.sh make package

## Statement of Support

This software is provided as-is, without warranty of any kind or
commercial support through Delphix. See the associated license for
additional details. Questions, issues, feature requests, and
contributions should be directed to the community as outlined in the
[Delphix Community Guidelines](http://delphix.github.io/community-guidelines.html).
