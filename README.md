# asteroid-heliograph

A scrolling light message app for [AsteroidOS](http://asteroidos.org/)

Display scrolling text messages on your watch screen to communicate
across a room without sound. Choose from Emergency, Navigation, Social,
Fun, Emoji and Kaomoji categories. Drag horizontally while active to
adjust scroll speed. The screen auto-rotates to stay readable regardless
of wrist angle.

### Custom messages

Edit `/home/ceres/.local/share/asteroid-heliograph/custom.txt` to add
your own messages. Prefix with a category key to insert into an existing
category, or use `custom:` to create a personal category that appears
first in the list. The file ships with usage instructions as comments.
Changes take effect on next app launch.

https://github.com/user-attachments/assets/66c30bc3-fb30-4363-a997-241118051b46

### Screenshots

![shot-helio1](https://github.com/user-attachments/assets/8dca63bb-8d0a-435a-8e39-efda23f1d08e)

![shot-helio2](https://github.com/user-attachments/assets/0a5bd018-4f57-43c8-af13-07426617e796)

![shot-helio3](https://github.com/user-attachments/assets/56883968-5da7-4e31-a980-cf251e1b6ff2)

![shot-helio4](https://github.com/user-attachments/assets/5e321eb0-f11e-4b04-8283-8addf6495f99)

![shot-helio5](https://github.com/user-attachments/assets/825b1313-b50d-42e0-9bb4-d421ab7adf29)

## SailfishOS

The `sailfishos` branch is the SailfishOS version, built for Sailfish OS
5.1 on aarch64 and run on a Jolla C2. The banner is the watch app; the
controls keep the watch proportions across the phone's width, and the
banner fills the whole screen when it runs.

- Your own messages go into
  `~/.local/share/net.mowerk/harbour-asteroid-heliograph/custom.txt`.
  The first start copies the documented template there.
- The app reads the accelerometer to keep the banner level, so it asks
  once for the Sensors permission when it is started from the app grid.
- The brightness is raised to maximum while a message is shown and set
  back when the app closes normally, as on the watch. If the app is
  killed, the brightness stays at maximum.
- Install: `devel-su pkcon install-local harbour-asteroid-heliograph-1.0.0-1.aarch64.rpm`
  (aarch64 only).
- Build: `mb2 -t SailfishOS-5.1.0.11-aarch64 build` with the Sailfish
  Platform SDK.

The author tested the port on his C2 and had three things changed: the
full screen banner covers the whole screen at any tilt, the banner text
is bold, and the scroll speed goes up to 2000 px/s.

```
Disclosure: LLMGD-3 · origin O1 (LLM-ported; the author tested it on his Jolla C2 and had the banner area, font weight and speed limit changed; code not read; self-graded)
LLMGD: v0.2; assurance=A3; flags=U,T; origin={O0:.7,O1:.3}; origin_headline=O0; scope=port(code+assets+packaging+docs); graded-by=claude-opus-5-5; retrieval=author-side
```
