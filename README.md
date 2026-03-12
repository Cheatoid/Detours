# Microsoft Research Detours Package  (this fork is modified to build as DLL)

Detours is a software package for monitoring and instrumenting API calls on Windows. Detours
has been used by many ISVs and  is also  used by product teams at Microsoft. Detours is now available under
a standard open source  license ([MIT](https://github.com/microsoft/Detours/blob/master/LICENSE.md)).  This simplifies licensing for programmers using Detours
and allows the community to support Detours using open source tools and processes.

Detours is compatible with the Windows NT family of
operating systems: Windows NT, Windows XP, Windows Server 2003, Windows 7,
Windows 8, Windows 10, and Windows 11.  It cannot be used by Windows Store apps
because Detours requires APIs not available to those applications.
This repo contains the source code for version 4.0.1 of Detours.

For technical documentation on Detours, see the [Detours Wiki](https://github.com/microsoft/Detours/wiki).
For directions on how to build and run samples, see the
samples [README.txt](https://github.com/Microsoft/Detours/blob/master/samples/README.TXT) file.

## Quick Build Guide for Windows (Beginner-Friendly)

### Prerequisites

1. **Visual Studio 2026** (or later) with C++ workload installed
   - Download from: https://visualstudio.microsoft.com/downloads/
   - During installation, select "Desktop development with C++"

2. **CMake** (3.15 or later)
   - Download from: https://cmake.org/download/
   - During installation, choose "Add CMake to the system PATH"

### Building the Library

**Option 1: One-Click Build (Recommended for Beginners)**

Simply double-click `build_cmake.cmd` in File Explorer, or run from Command Prompt:

```cmd
build_cmake.cmd
```

This will automatically:
- Build both 32-bit (x86) and 64-bit (x64) DLLs
- Place outputs in `bin.X86` and `bin.X64` folders

**Option 2: Manual CMake Build**

For x64 (64-bit):
```cmd
cmake -B build -G "Visual Studio 18 2026" -A x64
cmake --build build --config Release
```

For x86 (32-bit):
```cmd
cmake -B build -G "Visual Studio 18 2026" -A Win32
cmake --build build --config Release
```

### Build Output

After building, you'll find:

| Architecture | DLL | Static/Import Library | Debug Symbols |
|-------------|-----|----------------|---------------|
| 32-bit (x86) | `bin.X86\Detours.X86.dll` | `lib.X86\Detours.X86.lib` | `bin.X86\Detours.X86.pdb` |
| 64-bit (x64) | `bin.X64\Detours.X64.dll` | `lib.X64\Detours.X64.lib` | `bin.X64\Detours.X64.pdb` |

### Using in Your Project

1. Copy `detours.h` from the `src` folder to your project
2. Link against `Detours.X86.lib` or `Detours.X64.lib` depending on your target architecture
3. Place the corresponding DLL alongside your executable

Example CMake integration:
```cmake
# Link Detours library
target_link_libraries(your_target PRIVATE path/to/lib.X64/Detours.X64.lib)

# Include header
target_include_directories(your_target PRIVATE path/to/src)
```

## Contributing

The [`Detours`](https://github.com/microsoft/detours) repository is where development is done.
Here are some ways you can participate in the project:

* [Answer questions](https://github.com/microsoft/detours/issues) about using Detours.
* [Improve the Wiki](https://github.com/microsoft/detours/wiki).
* [Submit bugs](https://github.com/microsoft/detours/issues) and help us verify fixes and changes as they are checked in.
* Review [source code changes](https://github.com/microsoft/detours/pulls).

Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that
you have the right to, and actually do, grant us the rights to use your contribution.
For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Issues, questions, and feedback

* Open an issue on [GitHub Issues](https://github.com/Microsoft/detours/issues).

## Mailing list for announcements

The detours-announce mailing list is a low-traffic email list for important announcements
about the project, such as the availability of new versions of Detours.  To join it, send
an email to listserv@lists.research.microsoft.com with a
message body containing only the text SUBSCRIBE DETOURS-ANNOUNCE.
To leave it, send an email to listserv@lists.research.microsoft.com with a
message body containing only the text UNSUBSCRIBE DETOURS-ANNOUNCE.


## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the [MIT](LICENSE.md) License.
