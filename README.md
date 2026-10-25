# Red Notebook

A Hobonichi-inspired journaling app for iPhone: a red leather notebook with daily pages, bullet journal, diary, calendar, to-do list and stickers.

Built with SwiftUI.

## Running

Requires Xcode and [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`).

```sh
xcodegen generate        # regenerate RedNotebook.xcodeproj after adding/removing files
open RedNotebook.xcodeproj
```

Launch arguments for development: `--open` skips the cover, `--tab calendar|todo|diary|stickers` starts on a tab,
and `--sample-data` fills in example content.

### App icon

The icon is drawn in code, once per cover colour (`AppIcon` is wine red; `AppIcon-teal`, `AppIcon-navy`, `AppIcon-pink`, `AppIcon-barbie`, `AppIcon-matcha`, `AppIcon-orange` are alternates
the app switches to when the cover colour changes). To regenerate one, pass the cover's base colour as r g b:

```sh
swift Scripts/make_app_icon.swift /tmp/icon.png 0.13 0.20 0.38   # navy (see CoverColor.base for the others)
# add "glossy" for lacquered covers (orange, barbie) and "soft" for pastels (pink)
sips -s format jpeg /tmp/icon.png --out /tmp/icon.jpg            # flatten: app icons can't be transparent
sips -s format png /tmp/icon.jpg --out RedNotebook/Resources/Assets.xcassets/AppIcon-navy.appiconset/AppIcon.png
```

The handwriting font is [Caveat](https://github.com/googlefonts/caveat) (SIL Open Font License, see `RedNotebook/Resources/Fonts`).

## Roadmap

1. Cover + page shell
2. Today page (diary, bullet items, notes)
3. Calendar (synced with iPhone Calendar)
4. To-do list with migration
5. Stickers (emoji, own photos, drawn pack)
6. Polish (page turns, quotes, haptics)
7. Drawing layer (PencilKit)
