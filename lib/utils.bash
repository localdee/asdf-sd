#!/usr/bin/env bash
# shellcheck disable=SC1091

set -euo pipefail

# TODO: Ensure this is the correct GitHub homepage where releases can be downloaded for sd.
GH_REPO="https://github.com/chmln/sd"
TOOL_NAME="sd"
TOOL_TEST="sd --version"

# get the directory of the current script
utils_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# source the custom script if it exists
source "${utils_dir}/plugin.bash"

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
	url="$(get_download_url "$TOOL_NAME" "$GH_REPO" "$version" "$platform" "$arch" "$processor")"

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
