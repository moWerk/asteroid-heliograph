# Review and architecture hints: Heliograph for SailfishOS

For anyone reviewing the `sailfishos` branch: where the code comes from, how it is laid out, what is worth reading and what is boilerplate.

## Where the code comes from

The app is the AsteroidOS watch app on `main`. This branch forks from it at `612fd6b`, and its commits are the SailfishOS port. The reliable view of what the port changed:

    git diff 612fd6b sailfishos -- qml src rpm '*.pro' '*.desktop'

Many port edits carry a `SailfishOS:` comment, but not all of them. Each commit message says what changed, why, and what was not checked, and ends with an LLMGD line grading it.

The port was written by an LLM (Claude), directed and tested by the author, who has not read the code. Everything here is a prototype until a reviewer owns it. That is the point of this file.

## Architecture

- `qml/harbour-asteroid-heliograph.qml`: the Silica `ApplicationWindow`. It sizes `Dims` from the screen width, then loads the app (`game/main.qml`). When the app goes to the background, the same item is moved into the cover and scaled down, so the home screen tile shows it live. The same shell is used in all eight ports.
- `qml/game/Dims.qml`, `Label.qml`, `HighlightBar.qml`, `Icon.qml`, `PageHeader.qml`, `ValueCycler.qml`, `IntSelector.qml`, `DeviceSpecs.qml` (whichever exist here): small stand-ins for AsteroidOS's `org.asteroid.controls` and `org.asteroid.utils`, so the watch QML runs unchanged where possible. Each is a few dozen lines.
- `qml/game/main.qml`: the app frame and the brightness (as in Pulsar).
- `qml/game/MessagePage.qml` (about 580 lines): categories and messages, the full-screen banner turned level by the accelerometer (a square of the screen's diagonal, so it covers the screen at any angle), drag to adjust speed, the + / − buttons and the text input overlay (Silica `TextField`).
- `qml/game/BannerScroll.qml`: the scrolling text.
- `qml/game/MessageStore.qml`: QML singleton for own messages. Typed messages are a JSON list in dconf (`/apps/harbour-asteroid-heliograph/typed`). A hand-written `custom.txt` in `StandardPaths.data` is read once at start with a synchronous `file://` XMLHttpRequest. QML can not write files, so lines from the file can not be removed in the app. It replaced a C++ FileHelper with the same function names.
- `custom.txt` (repository root): the documented template, installed to `/usr/share/harbour-asteroid-heliograph/`.
- Packaging: pure QML, no binary. `Exec=sailfish-qml harbour-asteroid-heliograph` (package `libsailfishapp-launcher`), the `.pro` is `TEMPLATE = aux` with plain `INSTALLS`, and the spec is `BuildArch: noarch` with an xz payload (rpm 4.14 on SailfishOS 3.4 can not unpack the zstd of newer SDKs).

## Read these first

1. `MessageStore.qml`: the parsing of the file, the dconf JSON, and `isTyped()`, which decides whether − deletes or only points to the file.
2. `MessagePage.qml`, `reload()` and `showCustom()`: the lists are rebuilt from untouched base lists after every edit.
3. The banner rotation and the drag handling (the axis decision against the tilt angle).

## Skim

Stand-ins, icons, translations, packaging.

## Worth questioning

- The synchronous XHR at start: fine for a small text file, but it blocks while it reads.
- The data directory differs on SailfishOS 3.4: without sailjail, the launcher does not take `net.mowerk` from the desktop file.
- Brightness as in Pulsar: restored only on a clean exit, and not allowed in the Jolla Store.

## How it was tested

By the author, by playing it on a Jolla C2 (SailfishOS 5.1), the Jolla Tablet (4.6, x86) and a Jolla 1 (3.4, 32-bit ARM), with the same noarch package on all three. Before each handover, the LLM checked builds, package contents and start logs on those devices.

There are no automated tests; the on-device checks are listed in the commit messages.
