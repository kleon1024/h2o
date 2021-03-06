// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

package model

import (
	"fmt"
	"strconv"
	"strings"
)

// This is a list of all the current versions including any patches.
// It should be maintained in chronological order with most current
// release at the front of the list.
var versions = []string{
	"0.1.0",
}

var CurrentVersion string = versions[0]
var BuildNumber string
var BuildDate string
var BuildHash string
var BuildHashEnterprise string
var BuildEnterpriseReady string
var versionsWithoutHotFixes []string

func init() {
	versionsWithoutHotFixes = make([]string, 0, len(versions))
	seen := make(map[string]string)

	for _, version := range versions {
		maj, min, _ := SplitVersion(version)
		verStr := fmt.Sprintf("%v.%v.0", maj, min)

		if seen[verStr] == "" {
			versionsWithoutHotFixes = append(versionsWithoutHotFixes, verStr)
			seen[verStr] = verStr
		}
	}
}

func SplitVersion(version string) (int64, int64, int64) {
	parts := strings.Split(version, ".")

	major := int64(0)
	minor := int64(0)
	patch := int64(0)

	if len(parts) > 0 {
		major, _ = strconv.ParseInt(parts[0], 10, 64)
	}

	if len(parts) > 1 {
		minor, _ = strconv.ParseInt(parts[1], 10, 64)
	}

	if len(parts) > 2 {
		patch, _ = strconv.ParseInt(parts[2], 10, 64)
	}

	return major, minor, patch
}

func GetPreviousVersion(version string) string {
	verMajor, verMinor, _ := SplitVersion(version)
	verStr := fmt.Sprintf("%v.%v.0", verMajor, verMinor)

	for index, v := range versionsWithoutHotFixes {
		if v == verStr && len(versionsWithoutHotFixes) > index+1 {
			return versionsWithoutHotFixes[index+1]
		}
	}

	return ""
}

func IsCurrentVersion(versionToCheck string) bool {
	currentMajor, currentMinor, _ := SplitVersion(CurrentVersion)
	toCheckMajor, toCheckMinor, _ := SplitVersion(versionToCheck)

	if toCheckMajor == currentMajor && toCheckMinor == currentMinor {
		return true
	}
	return false
}

func IsPreviousVersionsSupported(versionToCheck string) bool {
	toCheckMajor, toCheckMinor, _ := SplitVersion(versionToCheck)
	versionToCheckStr := fmt.Sprintf("%v.%v.0", toCheckMajor, toCheckMinor)

	// Current Supported
	if versionsWithoutHotFixes[0] == versionToCheckStr {
		return true
	}

	// Current - 1 Supported
	if versionsWithoutHotFixes[1] == versionToCheckStr {
		return true
	}

	// Current - 2 Supported
	if versionsWithoutHotFixes[2] == versionToCheckStr {
		return true
	}

	// Current - 3 Supported
	if versionsWithoutHotFixes[3] == versionToCheckStr {
		return true
	}

	return false
}
