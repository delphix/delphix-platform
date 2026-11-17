# Testing this repo

This doc is for an automated bugfix pipeline (or any engineer) that needs to know, from this
repo alone, how to test a change here and how to use this repo to test a change elsewhere. It is
a testing guide, separate from this repo's existing human-oriented docs ([`README.md`](../README.md)'s
own Quickstart/Building section, linked below rather than duplicated).

**Maintaining this doc**: this file covers unit testing (the lint/type-check jobs below), CI
runs (what exists and how to start each one), and deploying a change to a test VM. Source of
truth lives in the files this doc cites directly (`.github/workflows/main.yml`, `Makefile`, this
repo's own branch protection, and the `git-utils` tooling named below). Update this doc when a
job, check, or deploy command here is added, removed, renamed, or changes behavior, or when a
new gotcha is found or an old one fixed. There is also a `docs/testing.md` comment next to the
job list in `.github/workflows/main.yml` and next to the platform-build definitions in the
`Makefile`, so a change there is nudged to come back here too.

**Last checked against**: commit `1650ff8` (2026-10-19).

Keeping this doc current depends on the inline comments in this repo's own workflow file and
`Makefile` (see "Maintaining this doc" above) being followed in practice, plus one automated
check: `check-docs-coverage` (see "CI runs" below) fails a PR if a job is added to
`.github/workflows/main.yml` with no backtick-quoted reference to its exact name anywhere in this
file.

## Unit testing

This repo has no unit-test suite in the usual sense — it ships static configuration, systemd
units, and Debian packaging, not application code with its own test harness. Its actual
"testing" machinery is a fixed set of lint/format/type-check jobs
(`.github/workflows/main.yml`), run automatically on every push and PR with no path filter, all
against this repo's one Python script, `files/common/usr/bin/delphix-startup-screen`, plus every
shell script in the repo:

- **`check-shellcheck`** — `shellcheck $(shfmt -f .)` (the same `delphix/actions` composite
  action's own entrypoint; `shfmt -f .` is what discovers every shell script in the repo, by
  shebang or `.sh` extension, recursively).
- **`check-shfmt`** — `shfmt -d .` (diff-mode format check, same discovery as above).
- **`check-pylint`** — installs `netifaces` (the target script imports it directly) before
  running `pylint -d invalid-name,E0611 files/common/usr/bin/delphix-startup-screen`.
- **`check-yapf`** — `yapf --diff --style google files/common/usr/bin/delphix-startup-screen`.
- **`check-mypy`** — `mypy --ignore-missing-imports files/common/usr/bin/delphix-startup-screen`.

Run any of these locally with the exact same command shown above (install `shellcheck`/`shfmt`/
`pylint`/`yapf`/`mypy` first; `shfmt` is pinned to `v3.0.2` in the upstream action, though a
newer local version is unlikely to disagree on this repo's own small script set). **For
`check-pylint` specifically, also `pip install netifaces` first** — `delphix-startup-screen`
imports it directly, and without it installed `pylint -d invalid-name,E0611` reports `E0401`
(`import-error`), which that disable list does not suppress.

**Gotcha**: the `Makefile` declares a `.PHONY: check` target, but never defines one — running
`make check` prints `Nothing to be done for 'check'.` and does nothing. It is not a hidden
test/lint entrypoint; the real checks are the GitHub Actions jobs above.

## Deploying a change to a test VM

- **`git linux-pkg build -m <build-machine> -t <target-machine>`** (from
  [`git-utils`](https://github.com/delphix/git-utils)) builds this repo's package on
  `<build-machine>` and, because `-t` is given, also installs it on `<target-machine>`. Run from
  this repo's own checkout — it sets the package/`-g`/`-b` flags itself. `-m` must be a VM
  created from the `bootstrap-18-04` DCoA group. Only committed work is built — `-f` only
  suppresses the uncommitted-changes warning (it does **not** commit anything); pass `-F` instead
  to actually commit tracked changes first. Commit your change yourself before running otherwise.
- This only updates files/units already installed on an already-running appliance — it does not
  produce a fresh, bootable image. For that, use `git ab-pre-push` below.

## CI runs: what exists and how to start it

| Run | Trigger | Required to merge? | What it does |
|---|---|---|---|
| General GitHub PrePush Jira Checks | Automatic, every push/PR | Yes (required status check on `develop`) | Validates the PR references a real Jira ticket |
| General GitHub PrePush Style Checks | Automatic, every push/PR | Yes (required status check on `develop`) | Commit/style conventions |
| `check-shellcheck` / `check-shfmt` / `check-pylint` / `check-yapf` / `check-mypy` (`.github/workflows/main.yml`) | Automatic, every push and PR, no path filter | No | See "Unit testing" above |
| `check-docs-coverage` (`.github/workflows/main.yml`) | Automatic, every push and PR, no path filter | No | Fails if a job name in this same workflow file has no backtick-quoted reference anywhere in this doc |
| `jenkinsci/build-package` (`linux-pkg-build-package`) | Automatic, every push/PR | No | Builds this repo's package via `linux-pkg` |
| `jenkinsci/appliance-build-orchestrator` | Automatic, every push/PR | No | Fires the same underlying `appliance-build-orchestrator-pre-push` Jenkins job `git ab-pre-push` fires manually, via its "Run Test Job" stage. Check this check's own Jenkins build result to see what it actually built and tested for this specific push |
| `Mend Code Security Check` / `Mend License Check` / `Mend Security Check` | Automatic, every PR (configured via this repo's own `.whitesource` file) | No | Dependency/license/SAST scanning. Each check's own conclusion (`neutral` when it determines there's nothing in scope to scan for that PR, `success`/`failure` otherwise) depends on what the PR actually changes — check each one's own GitHub check result rather than assuming a fixed outcome. None are required to merge |
| `git ab-pre-push` | Manual (`git-utils`) | N/A | Builds and boots a full appliance image containing this repo's change on demand — see below |

**`check-docs-coverage` is advisory, not a merge gate** — it's not a required status check (see
the table above), so a failing run doesn't block merging, only nudges a PR to update this doc.
It also only checks that a job's exact name appears somewhere in this file as a backtick-quoted
substring (`grep -F`), not that the surrounding text actually describes that job correctly — a
stale, unrelated mention of the same name elsewhere in the doc satisfies it just as well as a real
description would.

**Automatic appliance-boot coverage is not guaranteed on every PR.** `jenkinsci/appliance-build-orchestrator`
fires the same underlying job `git ab-pre-push` does (see the table above) — check that check's own
Jenkins build for its actual result before assuming a specific scenario was exercised. A passing
`ab-pre-push` run may also already be recorded in a PR's own Testing Done table — either way,
confirm the result was actually produced against the PR's **current** head commit before treating
it as covering it: a result tied to an earlier commit says nothing about anything pushed since.
Fire a fresh run by hand when neither gives current-head coverage:

```bash
git ab-pre-push --no-tests
```

run from this repo's own checkout; `--platforms`/`--variants` both default to `None` in
`git-utils` itself, so the actual platform/variant set built comes from the
`appliance-build-orchestrator-pre-push` Jenkins job's own defaults, not a hardcoded value in
`git ab-pre-push`. Add `-p "<platforms>"` to build other platforms explicitly (this repo ships
per-platform packages for `aws azure esx gcp hyperv kvm oci`) and drop `--no-tests` to also run
the job's own test suites — note that non-ZFS tests only run when at least one requested platform
is `aws` or `esx` (ZFS tests also support `azure`); requesting only an unsupported platform
disables non-ZFS testing with a `WARNING: Non ZFS tests will not be run` message. See
`git-utils`'s own [repository](https://github.com/delphix/git-utils) (run `git ab-pre-push --help`
for the current flag reference until a dedicated doc exists there) for the full flag reference,
the companion-PR recipe (`--extra-repo`, for bundling this repo's change into the same image as a
`dlpx-app-gate`/`zfs`/other package-repo change), and gotchas.

**Automated-pipeline gotcha**: a bugfix pipeline bundling this repo's change into a
combined-image build (via `git ab-pre-push --extra-repo`) resolves this repo through a
URL-to-package lookup: a recognized remote URL prints `Detected linux-pkg package: <name>` and
proceeds; an unrecognized one raises `SystemExit("Unsupported extra repository detected: <url>")`
and aborts the build. See `git-utils`'s own `_get_params_for_extra_repo()`
(`src/git_utils/lib/appliance_build_job.py`) for which repos are special-cased and how the lookup
actually works — that's `git-utils`'s own implementation detail, not this repo's, and can change
independently of anything here.

## Related existing docs

This doc links to, rather than duplicates, this repo's existing human-oriented docs:

- [`README.md`](../README.md)'s own "Quickstart" / "Building" section — SSH key setup, creating
  a build VM, and `make packages`/`make package-<platform>`.

See that file for the exact commands it already documents in full; this doc doesn't repeat them.
