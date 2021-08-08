package sqlstore

import (
	"h2o/model"
	"h2o/shared/mlog"
	"os"
	"time"

	"github.com/blang/semver"
	"github.com/pkg/errors"
)

const (
	CurrentSchemaVersion   = Version010
	Version010             = "0.1.0"
	OldestSupportedVersion = Version010
)

const (
	ExitVersionSave                 = 1003
	ExitThemeMigration              = 1004
	ExitTeamInviteIDMigrationFailed = 1006
)

// upgradeDatabase attempts to migrate the schema to the latest supported version.
// The value of model.CurrentVersion is accepted as a parameter for unit testing, but it is not
// used to stop migrations at that version.
func upgradeDatabase(sqlStore *SqlStore, currentModelVersionString string) error {
	currentModelVersion, err := semver.Parse(currentModelVersionString)
	if err != nil {
		return errors.Wrapf(err, "failed to parse current model version %s", currentModelVersionString)
	}

	nextUnsupportedMajorVersion := semver.Version{
		Major: currentModelVersion.Major + 1,
	}

	oldestSupportedVersion, err := semver.Parse(OldestSupportedVersion)
	if err != nil {
		return errors.Wrapf(err, "failed to parse oldest supported version %s", OldestSupportedVersion)
	}

	var currentSchemaVersion *semver.Version
	currentSchemaVersionString := sqlStore.GetCurrentSchemaVersion()
	if currentSchemaVersionString != "" {
		currentSchemaVersion, err = semver.New(currentSchemaVersionString)
		if err != nil {
			return errors.Wrapf(err, "failed to parse database schema version %s", currentSchemaVersionString)
		}
	}

	// Assume a fresh database if no schema version has been recorded.
	if currentSchemaVersion == nil {
		if err := sqlStore.System().SaveOrUpdate(&model.System{Name: "Version", Value: currentModelVersion.String()}); err != nil {
			return errors.Wrap(err, "failed to initialize schema version for fresh database")
		}

		currentSchemaVersion = &currentModelVersion
		mlog.Info("The database schema version has been set", mlog.String("version", currentSchemaVersion.String()))
		return nil
	}

	// Upgrades prior to the oldest supported version are not supported.
	if currentSchemaVersion.LT(oldestSupportedVersion) {
		return errors.Errorf("Database schema version %s is no longer supported. This Mattermost server supports automatic upgrades from schema version %s through schema version %s. Please manually upgrade to at least version %s before continuing.", *currentSchemaVersion, oldestSupportedVersion, currentModelVersion, oldestSupportedVersion)
	}

	// Allow forwards compatibility only within the same major version.
	if currentSchemaVersion.GTE(nextUnsupportedMajorVersion) {
		return errors.Errorf("Database schema version %s is not supported. This Mattermost server supports only >=%s, <%s. Please upgrade to at least version %s before continuing.", *currentSchemaVersion, currentModelVersion, nextUnsupportedMajorVersion, nextUnsupportedMajorVersion)
	} else if currentSchemaVersion.GT(currentModelVersion) {
		mlog.Warn("The database schema version and model versions do not match", mlog.String("schema_version", currentSchemaVersion.String()), mlog.String("model_version", currentModelVersion.String()))
	}

	// Otherwise, apply any necessary migrations. Note that these methods currently invoke
	// os.Exit instead of returning an error.
	// upgradeDatabaseToVersion010(sqlStore)
	return nil
}

func saveSchemaVersion(sqlStore *SqlStore, version string) {
	if err := sqlStore.System().SaveOrUpdate(&model.System{Name: "Version", Value: version}); err != nil {
		mlog.Critical(err.Error())
		time.Sleep(time.Second)
		os.Exit(ExitVersionSave)
	}

	mlog.Warn("The database schema version has been upgraded", mlog.String("version", version))
}

func shouldPerformUpgrade(sqlStore *SqlStore, currentSchemaVersion string, expectedSchemaVersion string) bool {
	storedSchemaVersion := sqlStore.GetCurrentSchemaVersion()

	storedVersion, err := semver.Parse(storedSchemaVersion)
	if err != nil {
		mlog.Error("Error parsing stored schema version", mlog.Err(err))
		return false
	}

	currentVersion, err := semver.Parse(currentSchemaVersion)
	if err != nil {
		mlog.Error("Error parsing current schema version", mlog.Err(err))
		return false
	}

	if storedVersion.Major == currentVersion.Major && storedVersion.Minor == currentVersion.Minor {
		mlog.Warn("Attempting to upgrade the database schema version",
			mlog.String("stored_version", storedSchemaVersion), mlog.String("current_version", currentSchemaVersion), mlog.String("new_version", expectedSchemaVersion))
		return true
	}

	return false
}

func themeMigrationFailed(err error) {
	mlog.Critical("Failed to migrate User.ThemeProps to Preferences table", mlog.Err(err))
	time.Sleep(time.Second)
	os.Exit(ExitThemeMigration)
}
