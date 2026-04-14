---
name: release
description: Build and publish a new GitHub release for TaktTime
disable-model-invocation: true
argument-hint: [version e.g. 1.2]
---

# Release TaktTime

Build a release .app bundle and publish it as a GitHub release on GitHub.

## Version

The version to release is: $ARGUMENTS

If no version was provided, determine it by looking at the latest GitHub release (`gh release list --limit 1`) and incrementing the minor version.

## Steps

1. Run `swift build -c release`
2. Assemble the .app bundle:
   - `mkdir -p TaktTime.app/Contents/MacOS TaktTime.app/Contents/Resources`
   - Copy `.build/release/TaktTime` to `TaktTime.app/Contents/MacOS/`
   - Generate icon: `iconutil -c icns AppIcon.iconset -o TaktTime.app/Contents/Resources/AppIcon.icns`
3. Zip: `zip -r TaktTime.zip TaktTime.app`
4. Determine release notes from commits since the last tag: `git log <last-tag>..HEAD --oneline`
5. Create the GitHub release: `gh release create v<version> TaktTime.zip --title "TaktTime v<version>" --notes "<release notes>"`
6. Print the release URL when done.
