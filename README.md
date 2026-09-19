# Revath's Macro Workshop

A standalone World of Warcraft macro editor with separate account, character, and curated community views.

## Install

Copy the `RevathsMacro` folder into `_retail_/Interface/AddOns/` and reload the UI.

## Use

- Type `/rmacro` or `/macroworkshop` to open the window.
- Use **Account Macros** and **Character Macros** to browse the two Blizzard macro stores separately.
- Use **From the Internet** for bundled, attributed community templates. Review placeholders before saving.
- Every list row shows the macro icon. The editor preserves the selected macro's icon.
- Use **Change icon** to choose from Blizzard's macro/item icons and icons registered by installed LibSharedMedia addons.
- Drag an Account or Character macro row directly onto an action-bar button.
- Save an edited or imported macro directly to the account or the current character.
- Open **Settings** to change the mailbox-style palette collection, font collection, editor size, scale, opacity, and row density.
- Drag the title area to move the window or the lower-right handle to resize it. Position and size are saved.

The community catalog is bundled because World of Warcraft addons cannot make live Reddit requests. Popularity values are snapshots from the linked Reddit discussion and are not live scores.

Macro create/update calls use Blizzard's protected macro API and may be refused during combat. Importing and editing remain available.

## Releases

Every commit pushed to `main` automatically bumps the patch version, packages the `RevathsMacro` addon, uploads a workflow artifact, and publishes a GitHub release with the matching version tag.
