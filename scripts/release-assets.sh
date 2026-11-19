#!/bin/bash
# release-assets.sh - build this repository's GitHub release assets for a tag.
#
# CONTRACT (the release hook of the SW release buttons; see
# Overhead-Intelligence/.github-private, sw/README.md):
#   argv[1]  the tag being released, e.g. v1.0.0
#   cwd      the repository root, checked out at the release commit, with the
#            annotated tag present locally (not pushed yet); VERSION equals the
#            tag without the leading v. Submodules are NOT checked out.
#   host     a clean GitHub-hosted ubuntu-24.04 runner: sudo apt-get works,
#            no Arm toolchain and no ArduPilot Python packages are preinstalled;
#            GH_TOKEN can read this repository
#   stdout   one path per line of a file to attach to the release, nothing else
#   stderr   progress
#   exit 0   success. Non-zero and the release is NOT created: a published
#            GitHub release is immutable, so a release missing its firmware
#            cannot be repaired afterwards. Fail loudly and early instead.
#
# "SW 3. Release" runs this before creating the release; "SW 2. Prepare release"
# runs it as a preview on the release pull request's commit, so a hook that
# would fail shows up on the pull request rather than at release time.
#
# Why this repository needs one: the flashable .apj IS the deliverable. Nothing
# downstream builds this firmware, so a release with no image attached sends a
# pilot to a page that carries no firmware.
#
# What it does: checks that the tag, VERSION and the checkout agree; installs
# the Arm toolchain ArduPilot pins and the Python packages waf needs; builds
# ArduPlane for each board in BOARDS from this commit, stamped with
# AP_CUSTOM_FIRMWARE_STRING; and prints the images, a manifest and a checksum
# file.
#
# The firmware reports both identities without either being written twice here:
# AP_CUSTOM_FIRMWARE_STRING replaces the firmware string and ArduPilot keeps the
# original alongside it, so the banner and the dataflash log read
#   OI-1.0.0 (abcd1234) [ArduPlane V4.7.2]
#
# NOTE for anyone adding this file back after it is removed: ArduPilot's
# .gitignore ignores /scripts/, so a plain `git add scripts/release-assets.sh`
# does nothing and the release then fails with "No such file". Use `git add -f`.
# A tracked file is never ignored, so this only bites on the first add.

set -euo pipefail

# Boards to build. Adding one is a one-word change; each produces its own
# images and its own lines in the manifest.
BOARDS=(CubeOrangePlus)
VEHICLE_TARGET="plane"
VEHICLE_BIN="arduplane"

# The Arm toolchain ArduPilot pins
# (Tools/environment_install/install-prereqs-ubuntu.sh).
ARM_ROOT="gcc-arm-none-eabi-10-2020-q4-major"
ARM_TARBALL="${ARM_ROOT}-x86_64-linux.tar.bz2"
ARM_URL="https://firmware.ardupilot.org/Tools/STM32-tools/${ARM_TARBALL}"

say()  { echo "release-assets.sh: $*" >&2; }
fail() { echo "release-assets.sh: ERROR: $*" >&2; exit 1; }

cd "$(dirname "$0")/.."
REPO_ROOT="$PWD"
OUT="$REPO_ROOT/release-assets"

# ---------------------------------------------------------------- checks

TAG="${1:?usage: release-assets.sh <tag>}"
[[ "$TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "the tag must be vX.Y.Z (got '$TAG')"
VER="${TAG#v}"

[ -f VERSION ] || fail "no VERSION file at the repository root"
file_ver="$(tr -d ' \t\r\n' < VERSION)"
[ "$file_ver" = "$VER" ] || fail "VERSION says $file_ver but the tag is $TAG"

# The image must be built from the tagged commit, unmodified, so that the
# release's firmware is that release's code.
tag_commit="$(git rev-parse -q --verify "refs/tags/$TAG^{commit}")" ||
    fail "tag $TAG is not present in this checkout"
head_commit="$(git rev-parse HEAD)"
[ "$tag_commit" = "$head_commit" ] ||
    fail "$TAG is on ${tag_commit:0:7} but the checkout is at ${head_commit:0:7}"
git diff --quiet --ignore-submodules=dirty HEAD -- ||
    fail "the checkout has uncommitted changes to tracked files; the image would not be $TAG's code"

AP_BASE="$(sed -n 's/^#define THISFIRMWARE "\(.*\)"$/\1/p' ArduPlane/version.h)"
[ -n "$AP_BASE" ] || fail "could not read THISFIRMWARE from ArduPlane/version.h"
FWSTR="OI-${VER}"
say "building $TAG ($FWSTR) on $AP_BASE at ${head_commit:0:8}"

# ---------------------------------------------------------------- toolchain

if ! command -v arm-none-eabi-gcc >/dev/null 2>&1; then
    say "installing the pinned Arm toolchain ($ARM_ROOT)"
    mkdir -p "$HOME/opt"
    curl -fsSL --retry 3 --retry-delay 5 -o "$HOME/opt/$ARM_TARBALL" "$ARM_URL" ||
        fail "could not download $ARM_URL"
    tar xjf "$HOME/opt/$ARM_TARBALL" -C "$HOME/opt" || fail "could not unpack $ARM_TARBALL"
    rm -f "$HOME/opt/$ARM_TARBALL"
    export PATH="$HOME/opt/$ARM_ROOT/bin:$PATH"
fi
command -v arm-none-eabi-gcc >/dev/null 2>&1 || fail "arm-none-eabi-gcc is still not on PATH"
ARM_VER="$(arm-none-eabi-gcc -dumpversion)"
say "arm-none-eabi-gcc $ARM_VER"

# Ubuntu 24.04 refuses pip into the system interpreter (PEP 668), so waf's
# Python packages go in a virtualenv whose bin/ leads PATH; ./waf then runs
# under that interpreter (its shebang is /usr/bin/env python3).
#
# The import name is "em", not "empy": the empy distribution provides a module
# called em, which is what waf imports. Testing for "import empy" looks right,
# always fails, and makes a correct install read as a broken one.
if ! python3 -c "import em" >/dev/null 2>&1; then
    say "installing waf's Python packages in a virtualenv"
    python3 -m venv "$HOME/ap-venv" || fail "could not create the virtualenv"
    "$HOME/ap-venv/bin/python" -m pip install --quiet --upgrade pip ||
        fail "could not upgrade pip in the virtualenv"
    "$HOME/ap-venv/bin/python" -m pip install --quiet \
        "empy==3.3.4" pymavlink future lxml pexpect intelhex ||
        fail "could not install waf's Python packages"
    export PATH="$HOME/ap-venv/bin:$PATH"
fi
python3 -c "import em, pymavlink" >/dev/null 2>&1 ||
    fail "empy (module em) and pymavlink are still not importable by $(command -v python3)"

# Full (not shallow) submodules: a shallow fetch cannot always reach the exact
# commit a submodule is pinned to, and a release build is the wrong place to
# find that out.
say "checking out submodules"
git submodule update --init --recursive --jobs 4 >&2 || fail "submodule checkout failed"

# ---------------------------------------------------------------- build

HWDEF="$(mktemp -t oi-hwdef-XXXXXX.dat)"
trap 'rm -f "$HWDEF"' EXIT
printf 'define AP_CUSTOM_FIRMWARE_STRING "%s"\n' "$FWSTR" > "$HWDEF"

rm -rf "$OUT"
mkdir -p "$OUT"
MANIFEST="$OUT/build-manifest.txt"
{
    echo "Overhead Intelligence ArduPlane firmware"
    echo "tag:              $TAG"
    echo "commit:           $head_commit"
    echo "upstream base:    $AP_BASE"
    echo "firmware string:  $FWSTR"
    echo "built:            $(date -u +%Y-%m-%dT%H:%MZ)"
    echo "toolchain:        arm-none-eabi-gcc $ARM_VER"
    echo
} > "$MANIFEST"

for BOARD in "${BOARDS[@]}"; do
    say "configuring $BOARD"
    ./waf configure --board "$BOARD" --extra-hwdef="$HWDEF" >&2 ||
        fail "waf configure failed for $BOARD"
    say "building $VEHICLE_TARGET for $BOARD"
    ./waf "$VEHICLE_TARGET" >&2 || fail "waf $VEHICLE_TARGET failed for $BOARD"

    bindir="build/$BOARD/bin"
    base="${VEHICLE_BIN}-${BOARD}-${TAG}"
    for src_dst in "${VEHICLE_BIN}.apj:${base}.apj" \
                   "${VEHICLE_BIN}.bin:${base}.bin" \
                   "${VEHICLE_BIN}_with_bl.hex:${base}_with_bl.hex"; do
        src="$bindir/${src_dst%%:*}"
        dst="$OUT/${src_dst##*:}"
        [ -s "$src" ] || fail "$src is missing or empty after a successful build"
        cp "$src" "$dst"
    done

    flash="$(wc -c < "$bindir/${VEHICLE_BIN}.bin" | tr -d ' ')"
    {
        echo "$BOARD"
        echo "  flash (${VEHICLE_BIN}.bin):  $flash bytes"
        echo "  ${base}.apj            flash from a ground station"
        echo "  ${base}.bin            raw image"
        echo "  ${base}_with_bl.hex    image with bootloader, for a bare board over DFU"
        echo
    } >> "$MANIFEST"
    say "$BOARD built, $flash bytes of flash"
done

# ---------------------------------------------------------------- output

cd "$OUT"
sha256sum ./*.apj ./*.bin ./*_with_bl.hex build-manifest.txt | sed 's| \./| |' > SHA256SUMS.txt

for f in *; do
    printf '%s\n' "$OUT/$f"
done
say "attaching $(ls -1 | wc -l | tr -d ' ') files"
