# Delphix Appliance Platform

## Quickstart

### Building

Run this command on "dlpxdc.co" to create the VM used to do the build:

    $ dc clone-latest --size COMPUTE_LARGE bootstrap-20-04 $USER-bootstrap

Log into that VM using the "ubuntu" user, and run these commands:

    $ git clone https://github.com/delphix/delphix-platform.git
    $ cd delphix-platform
    $ sudo apt-get update && sudo apt-get install python3-docker
    $ ansible-playbook bootstrap/playbook.yml
    $ ./scripts/docker-run.sh make packages

## Contributing

All contributors are required to sign the Delphix Contributor Agreement prior
to contributing code to an open source repository. This process is handled
automatically by [cla-assistant](https://cla-assistant.io/). Simply open a pull
request and a bot will automatically check to see if you have signed the latest
agreement. If not, you will be prompted to do so as part of the pull request
process.

This project operates under the [Delphix Code of
Conduct](https://delphix.github.io/code-of-conduct.html). By participating in
this project you agree to abide by its terms.

## Statement of Support

This software is provided as-is, without warranty of any kind or commercial
support through Delphix. See the associated license for additional details.
Questions, issues, feature requests, and contributions should be directed to
the community as outlined in the [Delphix Community
Guidelines](https://delphix.github.io/community-guidelines.html).

## License

This is code is licensed under the Apache License 2.0. Full license is
available [here](./LICENSE).
