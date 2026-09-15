# Cloud Shell Setup

This guide assumes **Google Cloud Shell on x86_64 Linux** and is optimized for coding, validation, and headless Godot checks.

The current reference engine is **Godot 4.7.2 stable**.

## What is required now

For the current repository you need:

- Git;
- Python 3;
- `unzip`;
- `curl` or `wget`;
- Godot 4.7.2 editor binary, run with `--headless` in Cloud Shell.

Useful but optional:

- `jq` for inspecting JSON;
- Blender CLI only when validating/converting real Blender assets;
- Godot export templates only when producing platform builds;
- JDK 17 + Android SDK only when producing Android builds.

You do **not** need Node.js, npm, a browser bundler, or the original web game's dependencies for this Godot rebuild.

## Base packages

```bash
sudo apt-get update
sudo apt-get install -y git python3 python3-venv unzip wget curl jq
```

Check architecture:

```bash
uname -m
```

Expected for the commands below:

```text
x86_64
```

## Install Godot 4.7.2 in your home directory

Cloud Shell sessions are easier to maintain when user tools live under `$HOME/.local/bin`.

```bash
mkdir -p "$HOME/.local/bin" "$HOME/.cache/chug"
cd "$HOME/.cache/chug"

wget -O godot.zip \
  "https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip"

unzip -o godot.zip
install -m 0755 Godot_v4.7.2-stable_linux.x86_64 "$HOME/.local/bin/godot"

export PATH="$HOME/.local/bin:$PATH"
grep -q 'HOME/.local/bin' "$HOME/.bashrc" || \
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"

godot --version
```

Expected version should report 4.7.2 stable.

## Clone/open the repository

Example:

```bash
git clone <YOUR-REPOSITORY-URL> chug
cd chug/CHUG-Shadow-of-Fame
```

If the repository root itself is `CHUG-Shadow-of-Fame`, simply `cd` there.

## First validation commands

Run these before editing:

```bash
python3 tools/validate_project.py

godot --headless --path . --import

godot --headless --path . --quit-after 5
```

`--import` asks the editor to import project resources and then quit.
`--headless` avoids requiring a display/GPU window.

## Fast edit loop

After each meaningful code/data change:

```bash
python3 tools/validate_project.py && \
godot --headless --path . --import && \
godot --headless --path . --quit-after 5
```

If this fails, fix the failure before expanding the change.

## Export templates: install only when you actually export

The current repository does not ship `export_presets.cfg`, so platform exporting is not yet part of the baseline build.

Do not download the large export-template package merely to parse or test the project.

When export presets are intentionally added, install the templates that exactly match the editor version before running commands such as:

```bash
godot --headless --path . --export-release "<PRESET NAME>" builds/<output>
```

## Android builds: optional later setup

For Android export on Linux, use:

- OpenJDK 17;
- Android SDK command-line tools;
- matching Godot export templates;
- an `export_presets.cfg` Android preset.

Do not install the Android toolchain until Android export is actually the task; it consumes significant storage and is unrelated to normal GDScript development.

A reasonable first package step when Android export becomes active is:

```bash
sudo apt-get install -y openjdk-17-jdk
java -version
```

Then follow the current Godot Android export requirements for SDK/platform/build-tools/NDK versions rather than freezing old SDK versions in game code.

## Blender in Cloud Shell

For normal modeling/rigging, use a local Blender GUI rather than Cloud Shell.

Only install Blender in Cloud Shell if there is a concrete command-line task such as:

- opening/saving a `.blend` file in batch mode;
- validating a scripted export;
- exporting a known source file to GLB;
- running a deterministic asset conversion.

If needed and the available Debian package is acceptable for the specific task:

```bash
sudo apt-get install -y blender
blender --version
```

Do not make the whole development environment depend on Blender being installed just to edit GDScript.

## Storage discipline

Cloud Shell storage is limited compared with a workstation.

Avoid keeping:

- multiple Godot versions;
- unused export-template packages;
- Android SDK/NDK versions not used by the build;
- large duplicate GLBs/textures;
- generated build outputs in Git.

Use `.gitignore` for local import/build artifacts.

## Suggested Cloud Shell session order

```text
1. Pull repository.
2. Read AGENTS.md and START_HERE.md.
3. Run Python validator.
4. Run Godot headless import/startup.
5. Read the next BUILD_PLAN task.
6. Make one focused change.
7. Re-run validation/import/startup.
8. Commit only working changes.
```

## What Cloud Shell cannot verify well

Headless checks cannot replace:

- visual animation quality;
- touch feel on a real device;
- combat responsiveness at target frame rate;
- Blender rig deformation quality;
- final lighting/material appearance;
- Android device behavior.

Use Cloud Shell as the reliable code/build/validation side of the workflow, then test gameplay/art interactively on a real machine/device.
