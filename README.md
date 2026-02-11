# Delphix Appliance Platform

## Quickstart

### Building

#### Prerequisites: SSH Key Setup

Before cloning a build VM, ensure your SSH keys are loaded in ssh-agent so they
are automatically installed on the VM for passwordless access:

    $ ssh-add -l                    # Check if keys are loaded
    $ ssh-add ~/.ssh/id_ed25519     # Load your key if not already loaded

The `dc clone-latest` command will automatically install your public key from
ssh-agent onto the VM. If no key is available, you'll see a warning and the
VM won't be accessible via SSH key authentication.

**Manual SSH Key Setup (if automatic setup fails):**

If you cloned the VM before loading your keys, or the automatic setup didn't
work, you can manually configure passwordless SSH. First, log in with standard
password:

    $ ssh delphix@$USER-bootstrap.dlpxdc.co

Then add your public key to authorized_keys:

    $ mkdir -p ~/.ssh && chmod 700 ~/.ssh
    $ echo "YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
    $ chmod 600 ~/.ssh/authorized_keys

To get your public key, run this on your local machine:

    $ cat ~/.ssh/id_ed25519.pub     # or id_rsa.pub

#### Create Build VM and Install Build Dependencies

Run this command on "dlpxdc.co" to create the VM used to do the build:

    $ dc clone-latest --size COMPUTE_LARGE dlpx-internal-buildserver-develop $USER-bootstrap

Log into that VM using the "delphix" user, and run these commands:

    $ git clone https://github.com/delphix/delphix-platform.git
    $ cd delphix-platform
    $ sudo apt-get update
    $ sudo make build-deps

#### Build All Packages

    $ sudo make packages

#### Build Specific Platforms

To build for a specific platform instead of all platforms:

    $ sudo make package-aws      # AWS only
    $ sudo make package-azure    # Azure only
    $ sudo make package-esx      # ESX only

Available platforms: aws, azure, esx, gcp, hyperv, kvm, oci

Build artifacts are placed in the `artifacts/` directory.

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
