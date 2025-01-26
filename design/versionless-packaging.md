# Versionless Packaging

*Say what you need, not what you are.*

🛈️ This section is opinionated.

Specifying a version within a project file to denote the version of a package is widely supported by popular package managers. However, for anything beyond very simple packages, this is a largely redundant and potentially confusing mechanism.

It is redundant because the version would not only need to be defined in the codebase. It would need to be understood within the CI system and the repository would generally tag the codebase with a version number anyway, and now there are two version numbers that are not necessarily the same.

It's redundant because, while versioning is a human-directed way to visualise at a glance the level of change, it is purely a function of the commits since the last version released from that branch. The increasing popularity of a [Conventional Commits](https://www.conventionalcommits.org) style of commit messages allows the version number determination to be entirely automated, and be much more reliably reflected given how easy it is to forget what was changed between a commit and it's eventual release.

It's confusing because it opens the door to adding semver pre-release information, such as 1.0.0-beta. It might be clear to the author that more changes are required, but fundamentally, the maturity of a codebase is not determined by the codebase itself, or a particular commit id. It's determined by where it is within a software development lifecycle. All releases are release candidates. A team may have finished testing and ready for release to UAT or production. If the version number needs to be updated in the code, a production deployment cannot be done until the code has been updated purely for the version number, requiring a new commit id, and invalidating all steps up to that point, perhaps requiring redundant deployments a much more confusing audit trail.

In a monorepo, this file-based approach seems convenient but the maintenance of many version numbers requires another level of maintenance that is largely unnecessary.

In the spirit of encouraging the right thing rather than the wrong thing, we'll start assuming there is no version number within the codebase. Instead, the version of a release will be determined by the tags - which may be populated manually as a low-maintenance approach, or be determined by the CI system that understands the context of a release, perhaps computed from the commit messages.
