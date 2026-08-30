# Skim+

A small, automated patch set on top of [Skim](https://skim-app.sourceforge.io/), the macOS PDF reader. Not a fork: each upstream release is fetched from Skim's SVN, the patches in [`patches/`](patches/) are applied, and the result is built and published unmodified otherwise. In the tradition of patch-set distributions like ungoogled-chromium and Betterbird, this exists to carry a few features upstream has declined — nothing more.

**Unaffiliated with the Skim project.** Please do not report bugs in these builds to the Skim maintainers; file them [here](../../issues) instead. This repository is maintained largely by automation (an AI agent watches upstream releases, rebuilds, and files issues when human attention is needed), with a human owner reviewing anything the automation flags.

## Patches

| Patch | What it does | Upstream status |
|---|---|---|
| `0001-true-black-dark-mode-invert.patch` | "Invert colors in dark mode" maps white paper to true black (`#000`) instead of the hard-coded 45/255 gray. For OLED/mini-LED reading at high brightness. | Declined: [#1774](https://sourceforge.net/p/skim-app/feature-requests/1774/), [#1722](https://sourceforge.net/p/skim-app/feature-requests/1722/), [#1776](https://sourceforge.net/p/skim-app/feature-requests/1776/) |
| `0002-tooltip-timing-prefs.patch` | Hidden prefs for tooltip timing: `SKToolTipDelay` (seconds; negative disables tooltips) and `SKToolTipAutoHideTime`. Unset = upstream behavior. | Declined: [#1757](https://sourceforge.net/p/skim-app/feature-requests/1757/), [#1312](https://sourceforge.net/p/skim-app/feature-requests/1312/), [#1325](https://sourceforge.net/p/skim-app/feature-requests/1325/) |
| `0003-invert-dark-mode-menu-toggle.patch` | View-menu item (with checkmark) toggling "Invert Colors in Dark Mode" live — bindable to a keyboard shortcut via System Settings. | Declined: [#1659](https://sourceforge.net/p/skim-app/feature-requests/1659/) |

Tip: with the patch applied, setting Skim's dark background color to pure *white* renders it black too (the background passes through the same invert filter), giving one seamless black field:

```sh
# quit Skim first
swift -e 'import AppKit
let d = UserDefaults(suiteName: "net.sourceforge.skim-app.skim")!
let c = try NSKeyedArchiver.archivedData(withRootObject: NSColor.white, requiringSecureCoding: false)
d.set(c, forKey: "SKDarkBackgroundColor"); d.set(c, forKey: "SKDarkFullScreenBackgroundColor")'
```

## Install

Grab the latest zip from [Releases](../../releases), unzip, drag `Skim.app` to Applications. Builds are Developer ID-signed and notarized by Apple, so they open like any other download. Prefer not to run a stranger's binary at all? Build it yourself:

## Build it yourself

```sh
brew install subversion            # upstream lives in SVN
scripts/fetch-upstream.sh 1.7.15   # export upstream source into ./upstream
scripts/build.sh                   # apply patches, build, verify, zip
```

Requires full Xcode (not just Command Line Tools). The scripts encode the two non-obvious build traps (absolute `SYMROOT`; `DEVELOPER_DIR` when CLT is selected).

## How maintenance works

A [weekly workflow](.github/workflows/upstream.yml) reads Skim's Sparkle appcast. When upstream ships a version this repo hasn't built, the macOS runner fetches the new tag, applies the patches, verifies the patched constant landed in the binary, and publishes a release. If a patch stops applying, the workflow opens an issue instead.

## License

Skim is BSD-licensed; the patches and scripts here are under the same [BSD license](LICENSE) as upstream.
