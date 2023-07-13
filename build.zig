const std = @import("std");
const GitRepoStep = @import("GitRepoStep.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const tests = b.option(bool, "Tests", "Build tests [default: false]") orelse false;

    const lib = b.addStaticLibrary(.{
        .name = "observable_unique_ptr",
        .target = target,
        .optimize = optimize,
    });
    lib.addIncludePath("include");
    // zig-pkg bypass for header-only
    lib.addCSourceFile("tests/empty.cc", cxxFlags);

    if (target.getAbi() == .msvc)
        lib.linkLibC()
    else
        lib.linkLibCpp();
    lib.installHeadersDirectory("include", "");
    lib.step.dependOn(&snitchDep(b).step);
    lib.addIncludePath("dep/snitch.git/include");
    b.installArtifact(lib);

    if (tests) {
        buildTest(b, .{
            .path = "tests/size_benchmark.cpp",
            .lib = lib,
        });
        buildTest(b, .{
            .path = "tests/speed_benchmark.cpp",
            .lib = lib,
        });
        buildTest(b, .{
            .path = "tests/runtime_tests_lifetime.cpp",
            .lib = lib,
        });
    }
}

const cxxFlags: []const []const u8 = &.{
    "-Wall",
    "-Wextra",
    "-Werror",
    "-std=c++20",
    "-fexperimental-library",
};

fn snitchDep(b: *std.Build) *GitRepoStep {
    const lib = GitRepoStep.create(b, .{
        .url = "https://github.com/cschreib/snitch.git",
        .branch = "main",
        .sha = "e5572469acf9ee6981f464907455abc04031bc95",
        .fetch_enabled = true,
    });
    return lib;
}

fn buildTest(b: *std.Build, info: BuildInfo) void {
    const config = b.addConfigHeader(.{
        .style = .blank,
        .include_path = "snitch/snitch_config.hpp",
    }, .{
        .SNITCH_VERSION = "1.1.0",
        .SNITCH_FULL_VERSION = "1.1.0.d040b89",
        .SNITCH_VERSION_MAJOR = 1,
        .SNITCH_VERSION_MINOR = 1,
        .SNITCH_VERSION_PATCH = 0,
        .SNITCH_MAX_TEST_CASES = 5000,
        .SNITCH_MAX_NESTED_SECTIONS = 8,
        .SNITCH_MAX_EXPR_LENGTH = 1024,
        .SNITCH_MAX_MESSAGE_LENGTH = 1024,
        .SNITCH_MAX_TEST_NAME_LENGTH = 1024,
        .SNITCH_MAX_TAG_LENGTH = 256,
        .SNITCH_MAX_CAPTURES = 8,
        .SNITCH_MAX_CAPTURE_LENGTH = 256,
        .SNITCH_MAX_UNIQUE_TAGS = 1024,
        .SNITCH_MAX_COMMAND_LINE_ARGS = 1024,

        .SNITCH_DEFINE_MAIN = 1,
        .SNITCH_WITH_EXCEPTIONS = 1,
        .SNITCH_WITH_TIMINGS = 1,
        .SNITCH_WITH_SHORTHAND_MACROS = 1,
        .SNITCH_CONSTEXPR_FLOAT_USE_BITCAST = 1,
        .SNITCH_DEFAULT_WITH_COLOR = 1,
        .SNITCH_DECOMPOSE_SUCCESSFUL_ASSERTIONS = 1,
    });
    const test_exe = b.addExecutable(.{
        .name = info.filename(),
        .optimize = info.lib.optimize,
        .target = info.lib.target,
    });
    test_exe.addConfigHeader(config);
    for (info.lib.include_dirs.items) |include| {
        test_exe.include_dirs.append(include) catch {};
    }
    test_exe.addIncludePath("tests");
    if (std.mem.startsWith(u8, info.path, "tests/runtime")) {
        test_exe.addCSourceFiles(&.{
            "tests/memory_tracker.cpp",
            "tests/tests_common.cpp",
            "tests/runtime_tests_owner_misc.cpp",
            "tests/runtime_tests_owner_construction.cpp",
            "tests/runtime_tests_owner_assignment_move.cpp",
            "tests/runtime_tests_owner_comparison.cpp",
            "tests/runtime_tests_owner_cast_move.cpp",
            info.path,
            "tests/runtime_tests_make_observable.cpp",
            "tests/runtime_tests_observer_misc.cpp",
            "tests/runtime_tests_observer_construction.cpp",
            "tests/runtime_tests_observer_construction_from_owner.cpp",
            "tests/runtime_tests_observer_construction_copy.cpp",
            "tests/runtime_tests_observer_construction_move.cpp",
            "tests/runtime_tests_observer_assignment_from_owner.cpp",
            "tests/runtime_tests_observer_assignment_copy.cpp",
            "tests/runtime_tests_observer_assignment_move.cpp",
            "tests/runtime_tests_observer_comparison.cpp",
            "tests/runtime_tests_observer_cast_copy.cpp",
            "tests/runtime_tests_observer_cast_move.cpp",
            "tests/runtime_tests_observer_from_this.cpp",
            "dep/snitch.git/src/snitch.cpp",
        }, cxxFlags);
    } else if (std.mem.startsWith(u8, info.path, "tests/speed")) {
        test_exe.addCSourceFiles(&.{
            "tests/tests_common.cpp",
            info.path,
            "tests/speed_benchmark_utility.cpp",
            "tests/speed_benchmark_utility2.cpp",
        }, cxxFlags);
    } else if (std.mem.startsWith(u8, info.path, "tests/size")) {
        test_exe.addCSourceFiles(&.{
            "tests/memory_tracker.cpp",
            info.path,
        }, cxxFlags);
    } // else {
    //     test_exe.addCSourceFiles(&.{
    //         "tests/memory_tracker.cpp",
    //     }, cxxFlags);
    // }
    test_exe.linkLibrary(info.lib);
    if (test_exe.target.getAbi() == .msvc) {
        test_exe.defineCMacro("OUP_COMPILER_MSVC", null);
        test_exe.linkLibC();
    } else test_exe.linkLibCpp();
    b.installArtifact(test_exe);

    const run_cmd = b.addRunArtifact(test_exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step(
        b.fmt("{s}", .{info.filename()}),
        b.fmt("Run the {s} test", .{info.filename()}),
    );
    run_step.dependOn(&run_cmd.step);
}

const BuildInfo = struct {
    lib: *std.Build.Step.Compile,
    path: []const u8,

    fn filename(self: BuildInfo) []const u8 {
        var split = std.mem.split(u8, std.fs.path.basename(self.path), ".");
        return split.first();
    }
};
