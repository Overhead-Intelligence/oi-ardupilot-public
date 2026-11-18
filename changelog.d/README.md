# Changelog entries

A pull request does not edit `CHANGELOG.md`. It adds its entry here, as a new file named after
its branch: `fix/lidar-udp-sink` adds `changelog.d/fix-lidar-udp-sink.md`. Two pull requests
then never change the same lines, so merging one cannot put another in conflict.

The file holds the entry as it should read in the release notes, under one or more of
`### Added`, `### Changed`, `### Fixed`, `### Removed`, `### Notes`:

```markdown
### Fixed

- **What was wrong, in the reader's words.** What it does now.
```

Do not edit another pull request's file, and add nothing under `## [Unreleased]` in
`CHANGELOG.md`.

"SW 2. Prepare release" moves the text of every file here into the new version's section of
`CHANGELOG.md` and deletes the files, so the release pull request shows the release notes in
one piece. The rules are in `Overhead-Intelligence/.github-private`, `sw/README.md`
("CHANGELOG entries").
