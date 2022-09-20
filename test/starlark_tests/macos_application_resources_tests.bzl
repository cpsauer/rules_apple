# Copyright 2020 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""macos_application resources Starlark tests."""

load(
    "//test/starlark_tests/rules:common_verification_tests.bzl",
    "archive_contents_test",
)

def macos_application_resources_test_suite(name):
    """Test suite for macos_application resources.

    Args:
      name: the base name to be used in things created by this macro
    """

    # Tests that various nonlocalized resource types are bundled correctly with
    # the application (at the top-level, rather than inside an .lproj directory).
    archive_contents_test(
        name = "{}_non_localized_processed_resources_test".format(name),
        build_type = "device",
        compilation_mode = "opt",
        contains = [
            "$RESOURCE_ROOT/mapping_model.cdm",
            "$RESOURCE_ROOT/sample.png",
            "$RESOURCE_ROOT/unversioned_datamodel.mom",
            "$RESOURCE_ROOT/versioned_datamodel.momd/v1.mom",
            "$RESOURCE_ROOT/versioned_datamodel.momd/v2.mom",
            "$RESOURCE_ROOT/versioned_datamodel.momd/VersionInfo.plist",
        ],
        is_binary_plist = [
            "$RESOURCE_ROOT/nonlocalized.plist",
            "$RESOURCE_ROOT/nonlocalized.strings",
        ],
        target_under_test = "//test/starlark_tests/targets_under_test/macos:app",
        tags = [name],
    )

    # Tests that empty strings files can be processed.
    archive_contents_test(
        name = "{}_empty_strings_files_test".format(name),
        build_type = "device",
        compilation_mode = "opt",
        is_binary_plist = [
            "$RESOURCE_ROOT/empty.strings",
        ],
        target_under_test = "//test/starlark_tests/targets_under_test/macos:app",
        tags = [name],
    )

    # Tests that various localized resource types are bundled correctly with the
    # application (preserving their parent .lproj directory).
    archive_contents_test(
        name = "{}_localized_processed_resources_test".format(name),
        build_type = "device",
        compilation_mode = "opt",
        is_binary_plist = [
            "$RESOURCE_ROOT/it.lproj/localized.strings",
            "$RESOURCE_ROOT/it.lproj/localized.plist",
        ],
        target_under_test = "//test/starlark_tests/targets_under_test/macos:app",
        tags = [name],
    )

    # Tests that apple_bundle_import files are bundled correctly with the
    # application.
    archive_contents_test(
        name = "{}_apple_bundle_test".format(name),
        build_type = "device",
        compilation_mode = "opt",
        is_binary_plist = [
            "$RESOURCE_ROOT/basic.bundle/should_be_binary.strings",
            "$RESOURCE_ROOT/basic.bundle/should_be_binary.plist",
        ],
        contains = [
            "$RESOURCE_ROOT/basic.bundle/basic_bundle.txt",
            "$RESOURCE_ROOT/basic.bundle/nested/should_be_nested.strings",
        ],
        target_under_test = "//test/starlark_tests/targets_under_test/macos:app",
        tags = [name],
    )

    # Tests that apple_bundle_import files are bundled correctly with the
    # application if the files have an owner-relative path that begins with
    # something other than the bundle name (for example, "foo/Bar.bundle/..."
    # instead of "Bar.bundle/..."). The path inside the bundle should start from the
    # .bundle segment, not earlier.
    archive_contents_test(
        name = "{}_nested_apple_bundle_test".format(name),
        build_type = "device",
        compilation_mode = "opt",
        is_binary_plist = [
            "$RESOURCE_ROOT/nested.bundle/should_be_binary.strings",
        ],
        contains = [
            "$RESOURCE_ROOT/nested.bundle/nested/should_be_nested.strings",
        ],
        not_contains = [
            "$RESOURCE_ROOT/nested_bundle/nested.bundle/should_be_binary.strings",
            "$RESOURCE_ROOT/nested_bundle/nested.bundle/nested/should_be_nested.strings",
        ],
        target_under_test = "//test/starlark_tests/targets_under_test/macos:app",
        tags = [name],
    )

    # Tests that apple_resource_bundle resources are compiled and bundled correctly
    # with the application. This test uses a bundle library with many types of
    # resources, both localized and nonlocalized, and also a nested bundle.
    archive_contents_test(
        name = "{}_apple_resource_bundle_test".format(name),
        build_type = "device",
        compilation_mode = "opt",
        plist_test_file = "$RESOURCE_ROOT/bundle_library_apple.bundle/Info.plist",
        plist_test_values = {
            "CFBundleIdentifier": "org.bazel.bundle-library-apple",
            "CFBundleName": "bundle_library_apple.bundle",
            "CFBundlePackageType": "BNDL",
            "TargetName": "bundle_library_apple",
        },
        contains = [
            "$RESOURCE_ROOT/bundle_library_apple.bundle/basic.bundle/basic_bundle.txt",
            "$RESOURCE_ROOT/bundle_library_apple.bundle/it.lproj/localized.strings",
            "$RESOURCE_ROOT/bundle_library_apple.bundle/it.lproj/localized.txt",
            "$RESOURCE_ROOT/bundle_library_apple.bundle/mapping_model.cdm",
            "$RESOURCE_ROOT/bundle_library_apple.bundle/nonlocalized_resource.txt",
            "$RESOURCE_ROOT/bundle_library_apple.bundle/unversioned_datamodel.mom",
            "$RESOURCE_ROOT/bundle_library_apple.bundle/versioned_datamodel.momd/v1.mom",
            "$RESOURCE_ROOT/bundle_library_apple.bundle/versioned_datamodel.momd/v2.mom",
            "$RESOURCE_ROOT/bundle_library_apple.bundle/versioned_datamodel.momd/VersionInfo.plist",
            "$RESOURCE_ROOT/bundle_library_apple.bundle/structured/nested.txt",
        ],
        is_binary_plist = [
            "$RESOURCE_ROOT/bundle_library_apple.bundle/structured/generated.strings",
            "$RESOURCE_ROOT/bundle_library_apple.bundle/structured/should_be_binary.plist",
            "$RESOURCE_ROOT/bundle_library_apple.bundle/structured/should_be_binary.strings",
        ],
        target_under_test = "//test/starlark_tests/targets_under_test/macos:app",
        tags = [name],
    )

    # Tests that resources generated by a genrule, which produces a separate copy
    # for each split configuration, are properly deduped before being processed.
    archive_contents_test(
        name = "{}_deduplicate_generated_resources_test".format(name),
        build_type = "device",
        plist_test_file = "$RESOURCE_ROOT/bundle_library_apple.bundle/generated.strings",
        plist_test_values = {
            "generated_string": "I like turtles!",
        },
        target_under_test = "//test/starlark_tests/targets_under_test/macos:app",
        tags = [name],
    )

    # Tests strings and plists aren't compiled in fastbuild.
    archive_contents_test(
        name = "{}_fastbuild_compilation_mode_on_strings_and_plist_files_test".format(name),
        build_type = "device",
        compilation_mode = "fastbuild",
        is_not_binary_plist = [
            "$RESOURCE_ROOT/nonlocalized.strings",
            "$RESOURCE_ROOT/nonlocalized.plist",
        ],
        target_under_test = "//test/starlark_tests/targets_under_test/macos:app",
        tags = [name],
    )

    # Tests strings and plists aren't compiled in dbg.
    archive_contents_test(
        name = "{}_dbg_compilation_mode_on_strings_and_plist_files_test".format(name),
        build_type = "device",
        compilation_mode = "dbg",
        is_not_binary_plist = [
            "$RESOURCE_ROOT/nonlocalized.strings",
            "$RESOURCE_ROOT/nonlocalized.plist",
        ],
        target_under_test = "//test/starlark_tests/targets_under_test/macos:app",
        tags = [name],
    )

    # Tests strings and plists are compiled in opt.
    archive_contents_test(
        name = "{}_opt_compilation_mode_on_strings_and_plist_files_test".format(name),
        build_type = "device",
        compilation_mode = "opt",
        is_binary_plist = [
            "$RESOURCE_ROOT/nonlocalized.strings",
            "$RESOURCE_ROOT/nonlocalized.plist",
        ],
        target_under_test = "//test/starlark_tests/targets_under_test/macos:app",
        tags = [name],
    )

    native.test_suite(
        name = name,
        tags = [name],
    )
