# makepkg-cg

makepkg-cg is a wrapper around makepkg that uses Control Groups via
systemd.resource-control to manage resource usage during package building. It
helps Arch users to build packages while keeping resource usage within
reasonable limits.

## Features

1.  Limit CPU usage to a defined percentage of total available CPU resources
2.  Limit RAM usage to a defined percentage of total available memory
3.  Set I/O priority and CPU scheduling policy
4.  Configurable resource limits through a user configuration file

## Requirements

1.  systemd
2.  bash

## Installation

Follow the instructions in the dist/arch/PKGBUILD file to build and install the
makepkg-cg package.

### Configuring `session.slice`

It is recommended to also increase the priority of `session.slice` to see the
most benefit to system stability:

```diff
diff --git a/usr/lib/systemd/user/session.slice b/usr/lib/systemd/user/session.slice
index aa12b7d..1a96695 100644
--- a/usr/lib/systemd/user/session.slice
+++ b/usr/lib/systemd/user/session.slice
@@ -12,4 +12,5 @@ Description=User Core Session Slice
 Documentation=man:systemd.special(7)
 
 [Slice]
-CPUWeight=100
+CPUWeight=1000
+IOWeight=1000
```

## Configuration

makepkg-cg provides a default configuration file located at doc/makepkg-cg.conf.
You can customize the resource limits by creating a new configuration file at
`$HOME/.config/makepkg-cg.conf`.

The configuration options include:

1.  `CPU_PERCENT`: CPU usage quota (percentage, will be multiplied by nproc)
2.  `RAM_PERCENT`: RAM usage considered high above (percentage)
3.  `RAM_MAX`: RAM usage maximum (percentage)
4.  `IO_LEVEL`: I/O priority level (0-7, lower values have higher priority)
5.  `IO_CLASS`: I/O class
6.  `CPU_POLICY`: CPU scheduling policy

Example configuration:

```bash
#!/bin/bash
# makepkg-cg configuration file

CPU_PERCENT=75
RAM_PERCENT=75
RAM_MAX=90
IO_LEVEL=7
IO_CLASS=idle
CPU_POLICY=idle
```

## Usage

Once installed, use makepkg-cg in place of makepkg when building packages. The
command accepts the same arguments as makepkg. Resource limits will be applied
based on the configuration file.

```bash
makepkg-cg <makepkg_arguments>
```

## Contributing

Feel free to contribute to the project by opening pull requests or reporting
issues on the project's GitHub repository.

Note: The eBPF support is currently **non-functional**. That's as good a place
to start as any.

## License

```
Copyright 2023 Fredrick R. Brennan

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this software or any of the provided source code files except in compliance
with the License.  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied.  See the License for the
specific language governing permissions and limitations under the License.
```

**By contributing you release your contribution under the terms of the license.**
