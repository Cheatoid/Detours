# ##############################################################################
#
#  CMakeLists.txt for Microsoft Detours Library
#
#  Microsoft Research Detours Package, Version 4.0.1
#
#  Copyright (c) Microsoft Corporation. All rights reserved.
#
# ##############################################################################

cmake_minimum_required(VERSION 3.15)

project(Detours
    VERSION 4.0.1
    DESCRIPTION "Microsoft Detours - Binary instrumentation library for Windows"
    LANGUAGES CXX
)

# ##############################################################################
# Options
# ##############################################################################

option(BUILD_SHARED_LIBS "Build shared library (DLL)" ON)
option(DETOURS_BUILD_STATIC_LIB "Also build static library" OFF)
option(DETOURS_INSTALL "Generate installation targets" OFF)

# ##############################################################################
# Configuration
# ##############################################################################

set(DETOURS_VERSION_STRING "4.0.1")

# Determine target architecture
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(DETOURS_BITS 64)
else()
    set(DETOURS_BITS 32)
endif()

# Identify processor architecture
if(MSVC)
    if(CMAKE_GENERATOR_PLATFORM MATCHES "ARM64EC")
        set(DETOURS_TARGET_PROCESSOR "ARM64EC")
    elseif(CMAKE_GENERATOR_PLATFORM MATCHES "ARM64" OR CMAKE_SYSTEM_PROCESSOR MATCHES "ARM64")
        set(DETOURS_TARGET_PROCESSOR "ARM64")
    elseif(CMAKE_GENERATOR_PLATFORM MATCHES "ARM" OR CMAKE_SYSTEM_PROCESSOR MATCHES "ARM")
        set(DETOURS_TARGET_PROCESSOR "ARM")
    elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(DETOURS_TARGET_PROCESSOR "X64")
    else()
        set(DETOURS_TARGET_PROCESSOR "X86")
    endif()
else()
    # For non-MSVC compilers, use system processor
    set(DETOURS_TARGET_PROCESSOR "${CMAKE_SYSTEM_PROCESSOR}")
endif()

message(STATUS "Detours: Building for ${DETOURS_TARGET_PROCESSOR} (${DETOURS_BITS}-bit)")

# ##############################################################################
# Source Files
# ##############################################################################

set(DETOURS_SOURCES
    src/detours.cpp
    src/modules.cpp
    src/disasm.cpp
    src/image.cpp
    src/creatwth.cpp
    src/disolx86.cpp
    src/disolx64.cpp
    src/disolarm.cpp
    src/disolarm64.cpp
    src/disolia64.cpp
)

set(DETOURS_HEADERS
    src/detours.h
    src/detver.h
)

# ##############################################################################
# Shared Library (DLL)
# ##############################################################################

add_library(detours SHARED ${DETOURS_SOURCES} ${DETOURS_HEADERS})

target_include_directories(detours
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
        $<INSTALL_INTERFACE:include>
)

# Define compile definitions
target_compile_definitions(detours
    PRIVATE
        WIN32_LEAN_AND_MEAN
        _WIN32_WINNT=0x0501
        DETOURS_BITS=${DETOURS_BITS}
)

# Set output names with architecture suffix
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(DETOURS_OUTPUT_NAME "Detours.X64")
else()
    set(DETOURS_OUTPUT_NAME "Detours.X86")
endif()

set_target_properties(detours PROPERTIES
    OUTPUT_NAME "${DETOURS_OUTPUT_NAME}"
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    PDB_NAME "${DETOURS_OUTPUT_NAME}"
    COMPILE_PDB_NAME "${DETOURS_OUTPUT_NAME}"
)

# ##############################################################################
# Compiler-specific Settings
# ##############################################################################

if(MSVC)
    # Match original Makefile settings (adapted for DLL)
    target_compile_options(detours PRIVATE
        /W4           # Warning level 4
        /WX           # Warnings as errors
        /we4777       # Treat specific warnings as errors
        /we4800       # Treat specific warnings as errors
        /Zi           # Debug information
        /Gy           # Function-level linking
        /Gm-          # Disable minimal rebuild
    )

    # Maximum performance optimizations for Release builds
    target_compile_options(detours PRIVATE
        $<$<CONFIG:Release>:
            /O2         # Maximum speed optimization
            /Oi         # Enable intrinsic functions
            /Ot         # Favor fast code
            /GL         # Whole program optimization
            /GF         # String pooling
            /GS-        # Disable security checks for performance
        >
    )

    # Link-time code generation for Release
    set_target_properties(detours PROPERTIES
        LINK_FLAGS_RELEASE "/LTCG /OPT:REF /OPT:ICF"
    )

    # Use DLL CRT linkage for shared library
    set_property(TARGET detours PROPERTY
        MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")

    # Link with kernel32 and user32
    target_link_libraries(detours PRIVATE kernel32 user32)
else()
    # GCC/Clang settings for potential alternative compilers
    target_compile_options(detours PRIVATE
        -Wall
        -Wextra
        -Werror
    )
endif()

# ##############################################################################
# Static Library (Optional)
# ##############################################################################

if(DETOURS_BUILD_STATIC_LIB)
    add_library(detours_static STATIC ${DETOURS_SOURCES} ${DETOURS_HEADERS})

    target_include_directories(detours_static
        PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
            $<INSTALL_INTERFACE:include>
    )

    target_compile_definitions(detours_static
        PRIVATE
            WIN32_LEAN_AND_MEAN
            _WIN32_WINNT=0x0501
            DETOURS_BITS=${DETOURS_BITS}
    )

    set_target_properties(detours_static PROPERTIES
        OUTPUT_NAME "detours-static"
        ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    )

    if(MSVC)
        target_compile_options(detours_static PRIVATE
            /W4
            /WX
            /we4777
            /we4800
            /Zi
            /Gy
            /Gm-
            /Zl
        )

        # Maximum performance optimizations for Release builds
        target_compile_options(detours_static PRIVATE
            $<$<CONFIG:Release>:
                /O2         # Maximum speed optimization
                /Oi         # Enable intrinsic functions
                /Ot         # Favor fast code
                /GL         # Whole program optimization
                /GF         # String pooling
                /GS-        # Disable security checks for performance
            >
        )

        # Link-time code generation for Release
        set_target_properties(detours_static PROPERTIES
            STATIC_LIBRARY_FLAGS_RELEASE "/LTCG"
        )

        set_property(TARGET detours_static PROPERTY
            MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
        target_link_libraries(detours_static PRIVATE kernel32 user32)
    else()
        target_compile_options(detours_static PRIVATE
            -Wall
            -Wextra
            -Werror
        )
    endif()
endif()

# ##############################################################################
# Installation
# ##############################################################################

include(GNUInstallDirs)

if(DETOURS_INSTALL)
    install(TARGETS detours
        EXPORT detours-targets
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )

    install(FILES ${DETOURS_HEADERS}
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )

    if(DETOURS_BUILD_STATIC_LIB)
        install(TARGETS detours_static
            EXPORT detours-targets
            ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        )
    endif()

    # Export targets
    install(EXPORT detours-targets
        FILE detours-targets.cmake
        NAMESPACE Detours::
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/detours
    )

    # Package configuration
    include(CMakePackageConfigHelpers)

    configure_package_config_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/DetoursConfig.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/DetoursConfig.cmake"
        INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/detours
    )

    write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/DetoursConfigVersion.cmake"
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY SameMajorVersion
    )

    install(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/DetoursConfig.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/DetoursConfigVersion.cmake"
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/detours
    )
endif()

# ##############################################################################
# Summary
# ##############################################################################

message(STATUS "")
message(STATUS "Detours Configuration Summary:")
message(STATUS "  Version:            ${DETOURS_VERSION_STRING}")
message(STATUS "  Target Processor:   ${DETOURS_TARGET_PROCESSOR}")
message(STATUS "  Bits:               ${DETOURS_BITS}")
message(STATUS "  Build Type:         ${CMAKE_BUILD_TYPE}")
message(STATUS "  Shared Library:     ${BUILD_SHARED_LIBS}")
message(STATUS "  Static Library:     ${DETOURS_BUILD_STATIC_LIB}")
message(STATUS "  Installation:       ${DETOURS_INSTALL}")
message(STATUS "")

# ##############################################################################
# End of File
# ##############################################################################