#!/usr/bin/env bash

set -euo pipefail

# TODO: Ensure this is the correct GitHub homepage where releases can be downloaded for sd.
GH_REPO="https://github.com/chmln/sd"
TOOL_NAME="sd"
TOOL_TEST="sd --version"

# CUSTOMIZE
get_download_url() {
	local version
	version="$1"
	local platform
	platform="$2"
	local arch
	arch="$3"
	local processor
	processor="$4"

	local build
	case "${platform}" in
	darwin)
		if [[ "${arch}" == "x86_64" ]]; then
			build='x86_64-apple-darwin'
		else
			build='aarch64-apple-darwin'
		fi
		;;
	linux)
		if [[ "${arch}" == "x86_64" ]]; then
			build='x86_64-unknown-linux-gnu'
		else
			build='aarch64-unknown-linux-musl'
		fi
		;;
	esac

	# https://github.com/chmln/sd/releases/download/v1.0.0/sd-v1.0.0-aarch64-apple-darwin.tar.gz
	echo -n "$GH_REPO/releases/download/v${version}/${TOOL_NAME}-v${version}-${build}.tar.gz"
}

# CUSTOMIZE
list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//' |
		grep -v rc |
		grep -v nightly
	# NOTE: You might want to adapt this sed to remove non-version strings from tags
}

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if sd is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_all_versions() {
	# TODO: Adapt this. By default we simply list the tag names from GitHub releases.
	# Change this function if sd has other means of determining installable versions.
	list_github_tags
}

# MOD - update
download_release() {
	local version
	version="$1"
	local filename
	filename="$2"
	local platform
	platform="$(get_raw_platform)"
	local arch
	arch="$(get_raw_arch)"
	local processor
	processor="$(get_raw_processor)"

	local url
	url="$(get_download_url "$version" "$platform" "$arch" "$processor")"

	echo "* Downloading $TOOL_NAME release $version..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

		# TODO: Assert sd executable exists.
		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}

# MOD - new
get_raw_platform() {
	# MAC: darwin
	# LINUX: linux
	uname | tr '[:upper:]' '[:lower:]'
}

get_raw_arch() {
	# MAC: arm64
	# LINUX: aarch64
	# LINUX: x86_64
	uname -m | tr '[:upper:]' '[:lower:]'
}

get_raw_kernel() {
	# MAC: darwin
	# LINUX: linux
	uname -s | tr '[:upper:]' '[:lower:]'
}

get_raw_processor() {
	# MAC: arm
	# LINUX: x86_64
	# LINUX: unknown
	uname | tr '[:upper:]' '[:lower:]'
}
