---
name: writing-style
description: Write and review English text in ASD-STE100 Simplified Technical English (STE). Use this skill when you write or change a skill, a README, a CLAUDE.md file, a spec, a test checklist, a procedure or other documentation in this repository. Also use it in a project whose instructions require STE. Also use it when the user asks you to write in STE, Simplified Technical English or ASD-STE100, to make technical text clear and simple, or to examine text against the STE rules.
---

# Writing style: ASD-STE100

STE is a controlled language for technical documentation. This skill uses ASD-STE100
Issue 9, January 2025 ([asd-ste100.org](https://asd-ste100.org/about_STE.html)). STE
has 53 writing rules and a dictionary of about 900 approved words. Each word has one
meaning and one part of speech. STE applies only to English text.

## Scope

- **Use it for** skills, agent files, specs, ADRs, feature docs, READMEs, runbooks,
  memory files, doc comments, commit bodies, PR and issue descriptions.
- **Do not use it for** text in the UI. Use the localization skill for UI text.
- **Current text** — apply STE only to the sections that you change. Do not rewrite a
  full file only for style, if the task does not tell you to do it.

## Limits of this skill

The full STE dictionary is not available here. Use the rules below. For each meaning,
use the most simple and common English word. If you are not sure that a word is
approved, use a more simple word.

Do not tell the user that the text is certified STE. Tell the user that the text follows
the STE rules.

## Words

1. Use one word for one meaning, and one meaning for one word. Do not use synonyms to
   make the text more interesting. If the text uses "spec", do not also use
   "specification" or "document" for the same item.
2. Use each word only as one part of speech. For example, use "test" as a noun or a
   verb, but keep the same meaning.
3. You can use technical names: file names, tools, techniques, UI labels, IDs and
   product names. You can also use technical verbs of the field, for example "commit",
   "merge" and "deploy".
4. Use one verb, not a verb with a particle, when this is possible. Write "install",
   not "set up". Write "continue", not "go on".
5. Do not use contractions. Write "do not", not "don't".
6. Do not use "e.g.", "i.e.", "etc." or "via". Write "for example", "that is", or give
   the full list. Write "through" or "with".
7. Do not use slang, figures of speech, or jargon that is not a technical name.

Use the simple word:

| Do not use | Use |
|------------|-----|
| utilize, leverage | use |
| perform, carry out | do |
| commence, initiate | start |
| terminate, cease | stop |
| obtain, acquire | get |
| assist | help |
| display, indicate | show |
| locate, identify | find |
| notify, inform | tell |
| ensure, verify | make sure, examine |
| prior to | before |
| due to | because of |
| in order to | to |
| in case, provided that | if |
| approximately | about |
| be able to | can |
| is required to, has to | must |
| existing | current |
| missing | not there, not found |

## Noun clusters

Do not use more than three nouns in a row. Use a preposition to divide a longer cluster.

- Not: "test checklist file name rule"
- Write: "the rule for the name of the test checklist file"

## Verbs

1. Use only these verb forms:
   - the infinitive ("to write")
   - the imperative ("write")
   - the simple present ("writes")
   - the simple past ("wrote")
   - the future ("will write")
   - the past participle as an adjective or in the passive ("the written spec")
2. Do not use the "-ing" form of a verb. Write "Before you edit the file", not "Before
   editing the file". Technical names are an exception, for example "equivalence
   partitioning" and "error guessing".
3. Do not use the perfect or continuous tenses. Write "The file changed", not "The file
   has changed" or "The file is changing".
4. Use the active voice. In descriptive text, you can use the passive voice only when
   the person or item that does the action is not known or not important.
5. Do not use "should", "would", "could", "might" or "may". Write an instruction as a
   command. Use "must" for a requirement. Use "can" for a possibility.

## Sentences

1. A sentence in a procedure has a maximum of 20 words. A sentence in a description has
   a maximum of 25 words. A code identifier, a file path or an ID counts as one word.
2. Write about only one topic in each sentence.
3. Do not remove words such as "the", "a", "this" or "that" to make a sentence
   shorter.
4. Do not use semicolons. Write two sentences.
5. Use a vertical list for steps, and for three or more items that are long.

## Procedures

1. Write each step as a command. Start the step with the verb.
2. Write only one instruction in each step. You can write more than one action only
   when the actions occur at the same time.
3. Put the condition before the instruction: "If the spec is a draft, mark the check
   as blocked."
4. Give numbers to steps that occur in sequence.
5. Do not put instructions in a note. Use a note only to give information.

## Descriptions

1. Put the most important information first.
2. Write about only one topic in each paragraph.
3. A paragraph has a maximum of six sentences.
4. Use words such as "because", "but", "if" and "when" to show the logic between
   sentences.

## Warnings and cautions

Start with a clear command. Then give the reason in a different sentence.

- Not: "IDs are stable since plans refer to them, so they should never be renumbered."
- Write: "Do not change IDs. Plans, tasks and tests refer to them."

## Exceptions

Do not change these items to STE:

- code, commands, file paths, IDs and EARS keywords
- quoted text that a user types or that a UI shows
- text in a language that is not English

Headings can be short noun phrases.

## Workflow

1. Write the text, or read the text that you must examine.
2. Examine each sentence against the checklist below.
3. Correct each problem. Do not change the technical meaning.
4. If a correction makes a sentence unclear, write two sentences.
5. When you examine text for the user, show the problems in a table. Use the
   columns "Original", "Rule" and "Correction".

In a PR review, a style finding is 🟡. It is more serious only if the text can cause a
wrong action.

## Checklist

- [ ] Each sentence in a procedure has 20 words or fewer.
- [ ] Each sentence in a description has 25 words or fewer.
- [ ] There are no "-ing" verb forms, except in technical names.
- [ ] There are no perfect or continuous tenses.
- [ ] The text uses the active voice.
- [ ] Each instruction is a command, and the condition comes first.
- [ ] Each step has only one instruction.
- [ ] Each noun cluster has three words or fewer.
- [ ] The text uses one word for each meaning, at all locations.
- [ ] There are no "should", "would", "could", "might", "may" or contractions.
- [ ] There are no "e.g.", "i.e.", "etc." or "via".
- [ ] The text does not remove "the", "a" or "this" to make sentences shorter.
- [ ] Each paragraph has six sentences or fewer.
- [ ] Each warning starts with a command and then gives the reason.

## Examples

| Original | Correction |
|----------|------------|
| Utilize the existing endpoint prior to creating a new one. | Use the current endpoint. Do not make a new endpoint before you examine the current one. |
| The checklist should be regenerated when the spec has been updated. | When the spec changes, make the checklist again. |
| User permission validation error message text | The text of the error message for user permissions |
| Don't stop; analyze what's there. | Do not stop. Analyze the data that you have. |
