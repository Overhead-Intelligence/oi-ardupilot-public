# oi-ardupilot-public

Overhead Intelligence's fork of [ArduPilot](https://github.com/ArduPilot/ardupilot). It is a
real GitHub fork, so pull requests can be opened from it to upstream; that is the point of it
being a fork and public.

Everything upstream documents still applies. This file covers only what is different here.

## Branches

| Branch | What it is | Who writes to it |
|---|---|---|
| `master` | Mirror of upstream `master`. The base for any branch intended as an upstream pull request. | Fast-forward from upstream only |
| `development` | Integration branch. Everything lands here by pull request. | Everyone, through pull requests |
| `vX.Y` | One per minor version, cut from `development` by the release bot. Tested and fixed here, then released. | Pull requests; the release bot |
| `main` | Always the newest release. | The release bot only |

Topic branches are `<type>/<kebab-case-scope>` with type `feat`, `fix`, `docs`, `chore`, `ci` or
`refactor`. Branch from the remote tip of the base, never merge or rebase a shared branch to
catch it up.

A change meant for upstream branches off `master`, not off `development`, so its pull request
carries only that change.

### Moving to a newer upstream release

`development` is rebased onto the next upstream stable tag when the fleet moves to it, and a new
version is started from there. `main` is no longer rebased onto upstream tags: once a release has
been made, `main` is the newest release and only the release bot moves it.

## Versions

Version numbers here are this fork's own and are **independent of ArduPilot's**. `v1.0.0` is
OI's first release, whatever upstream release it is built on.

Both identities reach the pilot without either being written twice. The release build sets
`AP_CUSTOM_FIRMWARE_STRING` to `OI-<version>`, and ArduPilot keeps the original string beside it,
so the banner and the dataflash log read:

```
OI-1.0.0 (abcd1234) [ArduPlane V4.7.2]
```

The upstream release a version is built on is also recorded in that version's `CHANGELOG.md`
section.

## Releases

Releases are made by three buttons in the **Actions** tab, run by the release bot: *SW 1. Start
version* on `development`, then *SW 2. Prepare release* and *SW 3. Release* on the version
branch. The mechanics are in `Overhead-Intelligence/.github-private`, `sw/README.md` — read that
file rather than recalling it. The button files here (`.github/workflows/sw-*.yml`) only call the
shared workflows.

Never create or push a tag, create a release by hand, push to `main`, create or delete a version
branch, or set `VERSION` or a CHANGELOG date by hand. If the buttons cannot do what is needed,
say so.

**A pull request does not edit `CHANGELOG.md`.** It adds its entry as a new file in
`changelog.d/`, named after its branch — see `changelog.d/README.md`. SW 2 assembles them into
the release section.

### Release files

`scripts/release-assets.sh` is the hook the buttons call. SW 2 runs it as a preview on the
release pull request and SW 3 runs it again before anything is tagged, so a release can never
exist without its firmware. It builds ArduPlane for each board in its `BOARDS` list — currently
`CubeOrangePlus` — and attaches the `.apj`, the raw `.bin`, the with-bootloader `.hex`, a build
manifest and `SHA256SUMS.txt`. Adding a board is a one-word change to `BOARDS`.

The hook runs on a clean `ubuntu-24.04` runner with no toolchain and no submodules, so it
installs the Arm toolchain ArduPilot pins and waf's Python packages itself.

### The `.gitignore` trap

Upstream's `.gitignore` has `*.d` (GCC dependency files) and `/scripts/` (for Lua scripts dropped
in by developers). Both swallow paths the release flow needs: `*.d` matches the **directory**
`changelog.d`, and `/scripts/` hides the release hook. Git cannot re-include a file whose parent
directory is excluded, so the block at the end of `.gitignore` un-excludes each directory and
restores the original intent underneath it.

If that block is ever lost, `git add changelog.d/<entry>.md` in a pull request silently does
nothing, the entry never reaches the release notes, and nobody is told. Check it before
concluding that an entry "did not save".

### The first release

GitHub lists a button in a repository's Actions tab only when its file is on the default branch,
and `main` only moves when a release is made. So the **first** version's three steps are run from
the [`.github-private` Actions tab](https://github.com/Overhead-Intelligence/.github-private/actions)
instead, naming this repository and the branch. That release brings the button files onto `main`,
and from then on the buttons are in this repository's own Actions tab.
