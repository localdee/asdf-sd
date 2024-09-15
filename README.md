<div align="center">

# asdf-sd [![Build](https://github.com/localdee/asdf-sd/actions/workflows/build.yml/badge.svg)](https://github.com/localdee/asdf-sd/actions/workflows/build.yml) [![Lint](https://github.com/localdee/asdf-sd/actions/workflows/lint.yml/badge.svg)](https://github.com/localdee/asdf-sd/actions/workflows/lint.yml)

[sd](https://github.com/chmln/sd) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Install

Plugin:

```shell
asdf plugin add locald-sd https://github.com/localdee/asdf-sd.git
```

locald-sd:

```shell
# Show all installable versions
asdf list-all locald-sd

# Install specific version
asdf install locald-sd latest

# Set a version globally (on your ~/.tool-versions file)
asdf global locald-sd latest

# Now sd commands are available
sd --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/localdee/asdf-sd/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Rigger.dev](https://github.com/localdee/)
