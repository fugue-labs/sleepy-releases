#!/bin/sh
# install.sh — sleepy client installer
#
# Sleepy is a hosted evolutionary code-optimization service driven over
# MCP — connect your client to https://sleepy.run/mcp and your own model
# evolves verified-faster code. This script installs the companion
# client tooling for hosted runs (worker, watch, status, export, sync):
# it detects OS and architecture, downloads the matching binary from
# the GitHub Releases page, verifies its SHA-256 checksum, and installs
# it to a directory on the user's PATH.
#
# This script is intentionally readable. Review it before running:
#
#     curl -fsSL https://sleepy.run/install.sh -o install.sh
#     less install.sh
#     sh install.sh
#
# Environment variables:
#
#     SLEEPY_VERSION   version to install (default: 0.5.4)
#     SLEEPY_REPO      GitHub repo in OWNER/NAME form (default: fugue-labs/sleepy-releases)
#     SLEEPY_BASE_URL  override the download base URL (default: derived from
#                      SLEEPY_REPO and SLEEPY_VERSION). Useful for mirrors or
#                      for testing. The final artifacts are fetched from
#                      "$SLEEPY_BASE_URL/<archive>.tar.gz" and
#                      "$SLEEPY_BASE_URL/checksums.txt".
#     SLEEPY_PREFIX    install prefix (default: /usr/local or $HOME/.local)
#                      binary is written to $SLEEPY_PREFIX/bin/sleepy
#
# Exits non-zero on any failure with a plain-language message.

# We do NOT rely on `set -e`. Every command that can fail is checked
# explicitly so that error messages are friendly and the cleanup trap
# always runs. `set -u` is on so that typos in variable names become
# loud failures instead of silent empty strings.
set -u

# -- configuration ----------------------------------------------------------

SLEEPY_VERSION="${SLEEPY_VERSION:-0.5.4}"
SLEEPY_REPO="${SLEEPY_REPO:-fugue-labs/sleepy-releases}"
SLEEPY_PREFIX="${SLEEPY_PREFIX:-}"
SLEEPY_BASE_URL="${SLEEPY_BASE_URL:-https://github.com/${SLEEPY_REPO}/releases/download/v${SLEEPY_VERSION}}"

# -- logging ----------------------------------------------------------------

info() { printf '==> %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

# -- cleanup trap -----------------------------------------------------------

TMPDIR_INSTALL=""
cleanup() {
    if [ -n "${TMPDIR_INSTALL}" ] && [ -d "${TMPDIR_INSTALL}" ]; then
        rm -rf "${TMPDIR_INSTALL}"
    fi
}
trap cleanup EXIT
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM
trap 'cleanup; exit 129' HUP

# -- OS / arch detection ----------------------------------------------------

uname_s=$(uname -s 2>/dev/null || echo unknown)
uname_m=$(uname -m 2>/dev/null || echo unknown)

case "${uname_s}" in
    Linux)
        os="Linux"
        ;;
    Darwin)
        os="Darwin"
        ;;
    CYGWIN*|MINGW*|MSYS*|Windows_NT)
        die "Windows is not supported by this installer.
  Download the ZIP directly from:
  https://github.com/${SLEEPY_REPO}/releases"
        ;;
    *)
        die "unsupported operating system: ${uname_s}"
        ;;
esac

case "${uname_m}" in
    x86_64|amd64)
        arch="x86_64"
        ;;
    arm64|aarch64)
        arch="arm64"
        ;;
    *)
        die "unsupported architecture: ${uname_m}
  sleepy publishes binaries for x86_64 and arm64 only."
        ;;
esac

# -- pick a downloader ------------------------------------------------------

if command -v curl >/dev/null 2>&1; then
    DL_TOOL="curl"
elif command -v wget >/dev/null 2>&1; then
    DL_TOOL="wget"
else
    die "neither curl nor wget is installed; one is required"
fi

download() {
    # download <url> <out-path>
    _url=$1
    _out=$2
    case "${DL_TOOL}" in
        curl) curl -fsSL -o "${_out}" "${_url}" ;;
        wget) wget -q -O "${_out}" "${_url}" ;;
    esac
}

# -- pick a sha256 tool -----------------------------------------------------

if command -v sha256sum >/dev/null 2>&1; then
    SHA_TOOL="sha256sum"
elif command -v shasum >/dev/null 2>&1; then
    SHA_TOOL="shasum"
else
    die "no sha-256 tool found (need sha256sum or shasum)"
fi

sha256_of() {
    # sha256_of <file> -> prints hex digest on stdout
    case "${SHA_TOOL}" in
        sha256sum) sha256sum "$1" | awk '{ print $1 }' ;;
        shasum)    shasum -a 256 "$1" | awk '{ print $1 }' ;;
    esac
}

# -- scratch directory ------------------------------------------------------

TMPDIR_INSTALL=$(mktemp -d 2>/dev/null) || \
    TMPDIR_INSTALL=$(mktemp -d -t sleepy-install)
if [ -z "${TMPDIR_INSTALL}" ] || [ ! -d "${TMPDIR_INSTALL}" ]; then
    die "could not create a temp directory"
fi

# -- download ---------------------------------------------------------------

archive_name="sleepy_${SLEEPY_VERSION}_${os}_${arch}.tar.gz"
archive_url="${SLEEPY_BASE_URL}/${archive_name}"
checksum_url="${SLEEPY_BASE_URL}/checksums.txt"

archive_path="${TMPDIR_INSTALL}/${archive_name}"
checksum_path="${TMPDIR_INSTALL}/checksums.txt"

info "Downloading ${archive_name}"
if ! download "${archive_url}" "${archive_path}"; then
    die "failed to download ${archive_url}
  check your network, the version (SLEEPY_VERSION=${SLEEPY_VERSION}),
  and that the release exists at:
  https://github.com/${SLEEPY_REPO}/releases/tag/v${SLEEPY_VERSION}"
fi

info "Downloading checksums.txt"
if ! download "${checksum_url}" "${checksum_path}"; then
    die "failed to download ${checksum_url}"
fi

# -- verify checksum --------------------------------------------------------

expected=$(awk -v name="${archive_name}" '$2 == name { print $1 }' "${checksum_path}")
if [ -z "${expected}" ]; then
    die "no checksum entry for ${archive_name} in checksums.txt"
fi

actual=$(sha256_of "${archive_path}")
if [ -z "${actual}" ]; then
    die "could not compute sha-256 of downloaded archive"
fi

if [ "${expected}" != "${actual}" ]; then
    die "checksum mismatch for ${archive_name}
  expected: ${expected}
  actual:   ${actual}
  refusing to install a tampered or corrupted archive."
fi
info "Checksum OK"

# -- extract ----------------------------------------------------------------

info "Extracting archive"
if ! ( cd "${TMPDIR_INSTALL}" && tar -xzf "${archive_name}" ); then
    die "failed to extract ${archive_name}"
fi

binary_src="${TMPDIR_INSTALL}/sleepy"
if [ ! -f "${binary_src}" ]; then
    die "extracted archive does not contain a top-level 'sleepy' binary"
fi

chmod +x "${binary_src}" || die "failed to chmod extracted binary"

if [ ! -x "${binary_src}" ]; then
    die "extracted binary is not executable"
fi

# -- choose install directory -----------------------------------------------

pick_install_dir() {
    # Honor explicit SLEEPY_PREFIX first.
    if [ -n "${SLEEPY_PREFIX}" ]; then
        printf '%s/bin' "${SLEEPY_PREFIX}"
        return
    fi

    # Prefer /usr/local/bin if it exists and is directly writable.
    if [ -d /usr/local/bin ] && [ -w /usr/local/bin ]; then
        printf '%s' /usr/local/bin
        return
    fi

    # Fall back to the per-user bin directory.
    printf '%s/.local/bin' "${HOME}"
}

install_dir=$(pick_install_dir)

if [ ! -d "${install_dir}" ]; then
    if ! mkdir -p "${install_dir}"; then
        die "could not create install directory: ${install_dir}"
    fi
fi

dest="${install_dir}/sleepy"

# -- install ----------------------------------------------------------------

# Try a direct copy first. If the destination directory is not writable,
# fall back to sudo when installing to /usr/local/bin and the user has sudo.
if cp "${binary_src}" "${dest}" 2>/dev/null; then
    :
elif [ "${install_dir}" = /usr/local/bin ] && command -v sudo >/dev/null 2>&1; then
    info "Elevated privileges required to write ${dest}; invoking sudo"
    if ! sudo cp "${binary_src}" "${dest}"; then
        die "failed to install to ${dest}"
    fi
else
    die "cannot write to ${install_dir}
  re-run with SLEEPY_PREFIX=\$HOME/.local to install under your home directory."
fi

# chmod is best-effort — cp preserves mode 755 from the archive entry
# but some filesystems strip the executable bit.
chmod +x "${dest}" 2>/dev/null || true

if [ ! -x "${dest}" ]; then
    die "installed binary at ${dest} is not executable"
fi

info "Installed sleepy ${SLEEPY_VERSION} to ${dest}"

# -- PATH hint --------------------------------------------------------------

case ":${PATH}:" in
    *":${install_dir}:"*)
        ;;
    *)
        warn "${install_dir} is not on your PATH"
        warn "add it to your shell profile, for example:"
        warn "  echo 'export PATH=\"${install_dir}:\$PATH\"' >> ~/.profile"
        warn "then restart your shell."
        ;;
esac

# -- next steps -------------------------------------------------------------

cat <<EOF

Next steps:
  open https://sleepy.run/signup
  claude mcp add --transport http sleepy https://sleepy.run/mcp
  sleepy worker --target ./file.go --server https://sleepy.run --eval benchmark:BenchmarkName

Docs: https://github.com/${SLEEPY_REPO}#readme
EOF
