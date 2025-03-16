# .dmg creator

.dmg file is a disk image file for macos. It is used to distribute macos apps.

This folder (./appdmg) serves necessary file to create a .dmg file for the app. We use the [node-appdmg](https://github.com/LinusU/node-appdmg) tool to create the .dmg file.

## Prerequisites

- A Mac Machine
- Make sure node is installed
- Install appdmg tool: `npm install -g appdmg`

## Create a .dmg file

Steps:

- Build macos Flutter app.
- Run `appdmg <config-json-path> <output-dmg>`.

Example (Run in the root of the project):

```shell
flutter build macos
appdmg ./appdmg/config.json ./build/PublisherApp.dmg
```

See `config.json` specification [here](https://github.com/LinusU/node-appdmg?tab=readme-ov-file#specification).
