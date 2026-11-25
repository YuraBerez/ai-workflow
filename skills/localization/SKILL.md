---
name: localization
description: Rules to write and show text that users see in more than one language - translation files and keys, placeholders, plurals, locale formats for numbers, units, dates and currency, right-to-left (RTL) layout, text expansion, typography for each language, and SEO for each language. Use it when a task adds or changes text that users see, adds a locale, changes a layout that must mirror in RTL, or formats a number, a unit or a date for display, on web or mobile.
---

# Localization

Obey these rules while you write the code, not in a review after. Each rule prevents a
frequent defect.

## 1. Find the locales

Read the localization configuration of the project before you start:

- the locales of each product (web, mobile, admin) and the default locale
- the framework, for example `i18next`, `vue-i18n`, ARB files or `.strings`
- the location of the translation files
- the test that examines the keys of all locales, if the project has it

Different products can have different locale lists. Do not make them the same without
approval. Do not ship a locale that has only part of its translations.

## 2. Messages

- **The default locale is the source of truth.** Write the text in the default locale
  first. Then write it in each other locale in the same change. Do not leave a key that
  shows the default language in a different locale.
- **Use the same keys and the same placeholders** in each locale file. If you rename a
  placeholder, rename it in all files at the same time.
- **Do not make a sentence from parts in the code**, for example
  `t('a') + name + t('b')`. The word order is different in each language. Use one message
  with named placeholders.
- **Plurals** — many languages have three to six plural forms. Use the plural syntax of
  the framework, or write the text without a plural, for example `Nearby: {n}`. Do not
  write `count === 1 ? 'item' : 'items'` in code.
- **Do not translate names** of brands, products and stores. In RTL text, put them in
  `<bdi>`.
- **Tone** — use the tone and the form of "you" that the project gives for each
  language.
- **Use the official texts** of stores and external services, for example the store
  badges. Do not write your own version.

## 3. Numbers, units, dates and currency

Do not put a raw number into a message, for example `{km} km`. The decimal separator,
the unit and the word order are different in each locale.

- Format each number, distance, duration, date, time and price with the locale API, for
  example `Intl` on the web or `NumberFormat` and `DateFormat` on mobile. Send the
  formatted text to the message.
- Keep and send values in one unit, for example kilometers and UTC. Convert them only
  for display.
- Do not make a date format by hand, for example `MM/DD`.
- In tests, use a regular expression that accepts the different spaces of the locale
  API, for example U+00A0 and U+202F.

## 4. Right-to-left layout

- Get the direction from the locale configuration, and set it on the root element. Do
  not write `dir` on page content.
- **Use logical CSS properties only:** `margin-inline-start`, `padding-inline`,
  `inset-inline-start`, `text-align: start`. `left`, `right` or `margin-left` in a new
  component is a defect. On mobile, use `start` and `end`, not `left` and `right`.
  Exception: an item that shows physical space, for example a map, does not mirror.
- **Mirror icons and motion that show a direction:** arrows, chevrons, slide
  transitions, progress. Do not mirror logos, play icons, check marks or clocks.
- Put arrows in text into the translation: `→` in LTR text, `←` in RTL text.
- Flex and grid layouts change their order with `dir` automatically. Do not add
  `row-reverse` for RTL, because then the layout changes two times.
- **Arabic script:** use a font that has the glyphs, `letter-spacing: normal` (spacing
  breaks the joined letters), `text-transform: none`, and a larger line height.
- Examine each RTL screen visually. A lint cannot find bad RTL.

## 5. Text expansion

- Many languages are 30–40% longer than English. Do not give buttons and labels a fixed
  width. Let the text wrap.
- Use short translations for short UI text (navigation, chips, buttons), not literal
  ones. If a translation does not fit at the minimum width, write a shorter text. Do not
  make the font smaller.
- Examine each locale at the minimum width of the project, for example 320 px, for
  horizontal overflow.

## 6. Typography for each language

Obey the punctuation rules of each language. For example:

| Language | Rules |
|----------|-------|
| French | A non-breaking space before `? ! : ;` and inside `« »`. The apostrophe `’`. |
| Spanish | The opening marks `¿` and `¡`. |
| Polish, Ukrainian | The quotes `„…”` (Polish) and `«…»` (Ukrainian). The Ukrainian apostrophe `ʼ` (U+02BC). The decimal comma comes from the locale API. |
| Arabic | The comma `،` and the question mark `؟`. No Latin punctuation in Arabic sentences. |
| All | The em dash `—` and the ellipsis `…` as one character. |

## 7. SEO for each language

- Translate the title and the description of each public page.
- Add `hreflang` links for each locale and `x-default`, with absolute URLs.
- Redirect by browser language only on the root page. Deep links and crawlers keep the
  URL that they asked for.

## Checklist before a PR

- [ ] All locale files have the same keys and placeholders. The key test passes.
- [ ] No message contains a raw number or unit. The locale API formats each number,
      unit, date and price.
- [ ] New CSS uses logical properties. Icons and motion with a direction mirror in RTL.
- [ ] Each RTL screen was examined visually.
- [ ] The longest locale has no overflow at the minimum width.
