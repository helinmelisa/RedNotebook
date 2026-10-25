# Red Notebook

A Hobonichi-inspired journaling app for iPhone: a red leather notebook with daily pages, bullet journal, diary, calendar, to-do list and stickers.

Built with SwiftUI.

## Running

Requires Xcode and [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`).

```sh
xcodegen generate        # regenerate RedNotebook.xcodeproj after adding/removing files
open RedNotebook.xcodeproj
```

Launch with the `--open` argument to skip the cover.

## Roadmap

1. Cover + page shell
2. Today page (diary, bullet items, notes)
3. Calendar (synced with iPhone Calendar)
4. To-do list with migration
5. Stickers (emoji, own photos, drawn pack)
6. Polish (page turns, quotes, haptics)
7. Drawing layer (PencilKit)
