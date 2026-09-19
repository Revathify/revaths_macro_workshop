# Revath's Macro Workshop

A standalone World of Warcraft macro editor with a customizable font, editor font size, macro import, and create/update actions.

## Install

Copy the `RevathsMacro` folder into `_retail_/Interface/AddOns/` and reload the UI.

## Use

- Type `/rmacro` or `/macroworkshop` to open the window.
- Click an existing macro to import its name, icon, and body.
- Edit the macro and choose `Create / Update`.
- Use the font menu and size slider to customize the editor.

Macro create/update calls use Blizzard's protected macro API and may be refused during combat. Importing and editing remain available.

## Releases

Every commit pushed to `main` automatically bumps the patch version, packages the `RevathsMacro` addon, uploads a workflow artifact, and publishes a GitHub release with the matching version tag.
