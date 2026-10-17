# Review and architecture hints: Heliograph for SailfishOS

For anyone reviewing the `sailfishos` branch: where the code comes from, how it is laid out, what is worth reading and what is boilerplate.

## Where the code comes from

The app is the AsteroidOS watch app on `main`. This branch forks from it at `612fd6b`, and its commits are the SailfishOS port. The reliable view of what the port changed:

    git diff 612fd6b sailfishos -- qml src rpm '*.pro' '*.desktop'

Many port edits carry a `SailfishOS:` comment, but not all of them. Each commit message says what changed, why, and what was not checked, and ends with an LLMGD line grading it.

Up to 1.2.0 the watch QML ran inside a Silica page through small stand-ins for the AsteroidOS controls; 1.3.0 replaced them with Silica's own components.

The port was written by an LLM (Claude), directed and tested by the author, who has not read the code. Everything here is a prototype until a reviewer owns it. That is the point of this file.

## Architecture

- `qml/harbour-asteroid-heliograph.qml`: the Silica `ApplicationWindow` and the cover, which shows the banner itself (`BannerView`), scaled down.
- `qml/pages/MessagePage.qml` (about 470 lines): a Silica `Page` in a `SilicaFlickable`. Categories and messages, the preview that grows into the full-screen banner turned level by the accelerometer (a square of the screen's diagonal, so it covers the screen at any angle), drag to adjust speed, Add / Remove, the brightness.
- `qml/pages/BannerView.qml`: the banner content, used by page and cover: scrolling text, or a blinking emoji (Twemoji SVG for the six built-in ones).
- `qml/pages/BannerScroll.qml`: the scrolling text, moved by an `XAnimator` on the render thread.
- `qml/pages/Picker.qml`: a two-line ComboBox (label, value at double size) with a `ContextMenu`.
- `qml/pages/AddMessageDialog.qml`: the Silica `Dialog` for an own message.
- `qml/pages/MessageStore.qml`: QML singleton for own messages, a JSON list in dconf (`/apps/harbour-asteroid-heliograph/typed`).
- Packaging: pure QML, no binary. `Exec=sailfish-qml harbour-asteroid-heliograph` (package `libsailfishapp-launcher`), the `.pro` is `TEMPLATE = aux` with plain `INSTALLS`, and the spec is `BuildArch: noarch` with an xz payload (rpm 4.14 on SailfishOS 3.4 can not unpack the zstd of newer SDKs).

## Read these first

1. `BannerScroll.qml`: the Animator restarts (an Animator writes `x` back only when it stops, so the position for a speed change is computed from the start time).
2. `MessagePage.qml`, `reload()` and `showCustom()`: the lists are rebuilt from untouched base lists after every edit.
3. The banner rotation and the drag handling (the axis decision against the tilt angle).

## Skim

Twemoji files, translations, packaging.

## Worth questioning

- Brightness as in Pulsar: restored only on a clean exit, and not allowed in the Jolla Store.

## How it was tested

By the author, by playing it on a Jolla C2 (SailfishOS 5.1), the Jolla Tablet (4.6, x86) and a Jolla 1 (3.4, 32-bit ARM), with the same noarch package on all three. Before each handover, the LLM checked builds, package contents and start logs on those devices.

There are no automated tests; the on-device checks are listed in the commit messages.
