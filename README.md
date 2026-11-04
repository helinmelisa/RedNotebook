# Red Notebook

A personal, Hobonichi-inspired journal for iPhone, built with SwiftUI. Open a textured notebook cover, turn the pages with your finger, and keep daily plans, diary entries, photos, outfits, and little scraps of life together.

The Xcode project is named **RedNotebook**; the current app and widget display name is **helin's**.

## What's new

- **A separate Diary page for every day.** Write on dotted paper, add photos and stickers, and draw without crowding the Today page. Browse previous entries in a searchable list grouped by month.
- **Sticky notes you can write and place anywhere.** Choose from 11 designs and 12 soft paper colours, then move, resize, rotate, or rewrite the note on the page.
- **Choose where notes and tape go.** The sticky-note and washi-tape makers let you pick the day's **Today** or **Diary** page. Stickers from the sticker book can also be placed on the diary page.
- **A calmer Today page.** Remove sections from a busy day and bring them back through **Add to this page**. Q&A is added when wanted instead of always occupying space.
- **More physical page behaviour.** Page curls follow the drag, the whole sheet scrolls with its margins and ribbon, and tapping outside a text field dismisses the keyboard.

## Inside the notebook

| Section | What it does |
| --- | --- |
| **Today** | Daily bullet items, habits, countdowns, mood and weather, timed meal entries, outfits, notes, optional Q&A, memories, and a Portuguese word of the day. |
| **Diary** | A dated dotted page for writing, drawings, photos, and stickers, with searchable past entries. |
| **Calendar** | Day, week, month, and year views; Portuguese holidays; read and create iPhone Calendar events with permission, and choose which calendars appear. |
| **To-Do** | Tasks grouped into overdue, today, upcoming, and someday, plus completed tasks from the week and migration of overdue tasks to today. |
| **Closet** | Add clothing and full-length photos, remove photo backgrounds, arrange outfit layers, adjust their fit, and keep track of what was worn on a day. |
| **Stickers** | Illustrated and emoji packs, personal photo cutouts, framed photos, patterned washi tape, and handwritten sticky notes. |

### Make the pages yours

- Drag stickers into place, pinch to resize, and twist to rotate. Notes and suitable photo stickers can be written on or captioned.
- Use PencilKit for handwriting and doodles on Today and Diary pages.
- Personalize the cover title and choose wine red, teal, navy, pastel pink, hot pink, matcha, or glossy orange. The app accent and alternate Home Screen icon follow the cover colour.
- Seasonal decoration appears around the closed notebook. Paper and sticker sounds can be switched off.
- Practise the Portuguese words collected so far with flashcards or a multiple-choice quiz.

### Widgets, privacy, and backups

- **Word-of-the-day widget:** Home Screen and Lock Screen layouts with a configurable cover colour.
- **Countdown widget:** configure an event and date for a Home Screen or Lock Screen countdown.
- **Optional notebook lock:** Face ID or device passcode, with page content hidden in the app switcher while the locked notebook is inactive.
- **Local storage:** SwiftData stores notebook content; UserDefaults stores preferences and lightweight tracking data.
- **Manual JSON backup and restore:** export notebook content from the cover customizer. Restoring replaces the current notebook rather than merging it.
- **Monthly PDF export:** create printable A5 pages for the month's non-empty entries.

Calendar events remain managed by the iPhone's Calendar accounts; they are separate from the notebook's JSON backup.

## Run locally

You need Xcode and an iPhone or simulator running **iOS 18 or later**.

1. Clone this repository and open `RedNotebook.xcodeproj`.
2. Select the **RedNotebook** app target/scheme and an iPhone simulator, then press Run.
3. To run on your own iPhone, select your Apple development team for both **RedNotebook** and **NotebookWidget**, and use bundle identifiers belonging to your account.
4. Grant Calendar access if you want to view or create system calendar events. Photo selection and optional device authentication are used by their respective features.

The generated Xcode project is included. [XcodeGen](https://github.com/yonaskolb/XcodeGen) is needed only when regenerating it from `project.yml`, for example after adding or removing source files:

```sh
brew install xcodegen
xcodegen generate
open RedNotebook.xcodeproj
```

`project.yml` currently contains the developer's signing team and bundle identifiers; change these before generating a project for another account.

### Development launch arguments

Set these in **Product → Scheme → Edit Scheme → Run → Arguments**:

| Argument | Behaviour |
| --- | --- |
| `--open` | Skip the closed cover and open the notebook. |
| `--tab today\|calendar\|todo\|diary\|closet\|stickers` | Choose the initial section; pass one value after `--tab`. Combine with `--open` to see it immediately. |
| `--sample-data` | Seed example pages, closet content, and calendar events in a Debug build. Use a simulator or a development calendar for sample data. |

For example, `--open --tab diary` starts directly on the Diary section.

## Project layout

- `RedNotebook/App` — app entry point, notebook lock, and keyboard dismissal.
- `RedNotebook/Models` — SwiftData models for daily pages and their content.
- `RedNotebook/Today`, `Diary`, `Calendar`, `Todo`, `Closet`, `Stickers` — notebook features.
- `RedNotebook/Notebook`, `Cover`, `Theme` — paper, page turns, covers, typography, sounds, and seasonal decoration.
- `RedNotebook/Backup` — JSON backup/restore and monthly PDF export.
- `Widget` — word-of-the-day and countdown widgets.
- `Scripts` — app-icon artwork generation.
- `project.yml` — XcodeGen project configuration.

## App icons and fonts

Cover-colour icons are drawn by `Scripts/make_app_icon.swift`. `AppIcon` is the default wine-red icon; alternate asset names follow the cases in `CoverColor.swift`, such as `AppIcon-navy` and `AppIcon-hotPink`.

To regenerate the navy icon:

```sh
swift Scripts/make_app_icon.swift /tmp/notebook-icon.png 0.13 0.20 0.38
sips -s format jpeg /tmp/notebook-icon.png --out /tmp/notebook-icon.jpg
sips -s format png /tmp/notebook-icon.jpg \
  --out RedNotebook/Resources/Assets.xcassets/AppIcon-navy.appiconset/AppIcon.png
```

The JPEG conversion flattens the artwork so the final app icon has no transparency. The generator also accepts `glossy` or `soft` as a style argument; match the cover's current design when regenerating another colour.

Typography uses [Caveat](https://github.com/googlefonts/caveat) for handwriting and [Fraunces](https://github.com/undercasetype/Fraunces) for display text. Both are distributed under the SIL Open Font License; their license files are included in [`RedNotebook/Resources/Fonts`](RedNotebook/Resources/Fonts).

## Project status

This is an actively developed personal notebook app. The features above describe the current implementation, including the latest Diary, sticky-note, and page-customization updates. The repository does not currently include an automated test target.
