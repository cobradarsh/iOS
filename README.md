# KeepAwake

A rootless iOS tweak that **keeps the screen awake while a chosen app is in the foreground** — overriding auto-lock and dimming, including in Low Power Mode. When you leave the app, normal auto-lock behavior returns.

Pick which apps this applies to in **Settings → KeepAwake** (every installed app has an on/off switch). Changes take effect the next time you open the app.

- Built for **arm64 / arm64e**, iOS 15.0+ (tested target: iOS 16.5, iPhone 14 Pro Max).
- Works on rootless and **RootHide / Dopamine** jailbreaks.

## How it works

The tweak is injected into every UIKit app. On launch it registers for foreground/background
notifications; when an **enabled** app becomes active it sets `UIApplication.idleTimerDisabled = YES`
(which overrides auto-lock and Low Power Mode) and clears it again when the app resigns active.
The per-app switches live in a PreferenceLoader settings bundle and are read from the
`com.cobradarsh.keepawake` preferences domain.

## Build

Builds automatically on GitHub Actions (macOS runner, RootHide Theos fork). See
[`.github/workflows/build.yml`](.github/workflows/build.yml). Download the finished `.deb`
from the run's **Artifacts** (`KeepAwake-debs`).

To build locally with [Theos](https://theos.dev):

```sh
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless
# or, for a RootHide-native package:
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=roothide
```

## Install

1. Download the `.deb` artifact from the latest successful Actions run.
2. Transfer it to the phone and install with **Sileo → Install Local Package**, or over SSH:
   ```sh
   sudo dpkg -i KeepAwake_*.deb
   ```
3. Respring. Open **Settings → KeepAwake** and toggle the apps you want.

On RootHide, try the `*rootless*` package first; if it doesn't take, use the `*roothide*` one.
