# Revath's Tooltip Helper

This World of Warcraft addon adds the total quantity of an item across all characters that have been logged into on the current WoW account.

## Installation

Copy the `revaths_tooltip_helper` folder into:

```text
World of Warcraft\_retail_\Interface\AddOns\
```

The folder must contain `RevathsTooltipHelper.toc` directly.

## How it works

The addon scans the current character's bags at login and after bag changes. When the bank is opened, it also scans the bank, bank bags, and reagent bank. Counts are saved per character in `RevathsTooltipHelperDB` and summed in item tooltips. Soulbound items are excluded because they cannot be shared between characters, while Warbound/account-bound items are included. Run `/rth rescan` after updating to rebuild the current character's saved counts.

Offline characters are represented by their last saved scan, so log into each character once and open its bank to build a complete total.

Use `/rth rescan` to manually rescan the current character.

## Releases

Pushing to `main` automatically reads the version from `RevathsTooltipHelper.toc`, creates a matching `vX.Y.Z` tag, and runs the GitHub Actions release workflow. It packages the addon with `RevathsTooltipHelper` as the ZIP's top-level folder, uploads the ZIP as a workflow artifact, and attaches it to a generated GitHub Release.

To publish a release:

```text
git add RevathsTooltipHelper.toc
git commit -m "Prepare v1.0.0 release"
git push origin main
```

The workflow can also be started manually from the GitHub Actions tab by providing a release tag. Existing `v*` tags pushed manually are supported too.