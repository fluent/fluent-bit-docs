<!-- vale off -->
<!-- markdownlint-disable MD033 -->

# Contributing to Fluent Bit docs

First of all, thanks for taking the time to read this guide. The fact that you're here means you're interested in contributing to Fluent Bit, and we highly appreciate your time.

This repository contains the files for the [Fluent Bit documentation library](https://docs.fluentbit.io/). Keeping these docs separate from the [main Fluent Bit repository](https://github.com/fluent/fluent-bit) helps reduce the number of commits to the Fluent Bit source code and makes it easier to maintain both projects.

Fluent Bit has a group of dedicated maintainers who oversee this repository, including several technical writers. These writers will review any pull requests you open, so don't be afraid to contribute—even if you're not a writer by trade. Your suggestions are valuable, and we'll help you wrangle any stray commas.

## :star: Quick tips

- [Sign off](#sign-off-your-git-commits) your Git commits.
- Use [soft line wraps](#line-wraps) in Markdown files.
- To link between pages, use [absolute file paths](#links).
- Review the results of [linters](#linters) for style and formatting guidance.

## Review process

After you open a pull request in this repository, a Fluent Bit maintainer will review it, add comments or suggestions as needed, and then merge it. After your changes are successfully merges into `master`, the docs site will update within a few minutes.

### Request review without merging

If you're contributing documentation for a Fluent Bit feature that's still in development, ask a maintainer to add the `waiting-on-code-merge` label to your pull request. This lets other maintainers know that your changes aren't ready to merge yet, even if they were approved.

### Stale pull requests

If you open a pull request that requires extended discussion or review, the Fluent Bit maintainers will add a `waiting-for-user` label to your pull request. This label means that we're blocked from moving forward until you reply. To keep contributions from going stale, we'll wait 45 days for your response, but we might close the pull request if we don't hear back from you by then.

## Pass DCO checks

To pass this repository's [DCO checks](https://github.com/apps/dco), you'll need to adhere to the following Git practices.

### Set your email in Git

To sign commits properly, you must first set your email address in your local Git environment. This should be the same email address associated with your GitHub account.

For more information, refer to GitHub's guide to [setting your commit email address in Git](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-email-preferences/setting-your-commit-email-address#setting-your-commit-email-address-in-git).

### Sign off your Git commits

You must sign off your commits to certify your identity as the commit author. A commit is "signed off" when its commit message looks like this:

```text
pipeline: outputs: syslog: fix grammar in examples
Signed-off-by: Tux <tux@linux.org>
```

For faster signing, you can use the `-s` flag:

`git commit -a -s -m "pipeline: outputs: syslog: fix grammar in examples"`

> :bulb: If you're using VSCode, the [**Git: Always Sign Off**](https://github.com/microsoft/vscode/issues/83096#issuecomment-545350047) option automatically appends a `Signed-off-by:` message to all of your commits.

### Fix "DCO is missing" errors

If a DCO error blocks your pull request from merging, refer to this guide about [how to add sign-offs retroactively](https://github.com/src-d/guide/blob/master/developer-community/fix-DCO.md#how-to-add-sign-offs-retroactively).

## Style guidelines

The Fluent Bit documentation follows the [Google developer documentation style guide](https://developers.google.com/style) for most topics related to grammar and style. We don't expect you
to memorize these style rules, but the maintainers who review your pull request might suggest changes accordingly.

The active [linters](#linters) in this repository flag certain style errors and, in some cases, explain how to fix them.

## Formatting guidelines

The Fluent Bit docs library is built and hosted through [GitBook](https://docs.gitbook.com/). Unfortunately, GitBook doesn't support local previews for contributors, but a Fluent Bit maintainer with a dedicated GitBook account can verify that things are formatted correctly after you open a new pull request.

### Links

When cross-linking between in this repository, use a full absolute path whenever
possible. For example:

```text
[LTSV](../pipeline/parsers/ltsv.md) and [Logfmt](../pipeline/parsers/logfmt.md)
```

### Line wraps

When GitBook renders pages, it treats all newlines literally, which means hard line wraps in Markdown files create awkward line breaks in the Fluent Bit docs site. Due to this, docs contributions must use soft line wraps.

<details>
<summary>:white_check_mark: Example: soft line wraps</summary>

```text
Soft-wrapped text uses newlines only to mark the end of a paragraph. From the perspective of a text editor, this means each paragraph looks like a single, unbroken line of text.

After two newlines, another paragraph begins.
```

</details>

<details>
<summary>:no_entry_sign: Example: hard line wraps</summary>

```text
Hard-wrapped text uses newlines
in the middle of sentences and
paragraphs.

This can make text easier for
humans to read, but GitBook
renders hard line wraps
awkwardly.
```

</details>

### Quotes

By default, Google Docs and Microsoft Word turn standard straight quotes into "smart"
curly quotes. If you copy-paste from one of these tools, you must correct the quotes back to straight quotes. You can also turn off smart quotes in [Google Docs](https://support.google.com/docs/thread/217182974/can-i-turn-smart-quotes-off-in-a-google-doc?hl=en) or [Microsoft Word](https://support.microsoft.com/en-us/office/smart-quotes-in-word-and-powerpoint-702fc92e-b723-4e3d-b2cc-71dedaf2f343) to prevent this problem.

### Table of contents

When you create a new `.md` file for a new page, you must add an entry to this repository's [`SUMMARY.md` file](https://github.com/fluent/fluent-bit-docs/blob/master/SUMMARY.md) (or ask a maintainer to add it on your behalf). If you don't update `SUMMARY.md`, the new page won't appear in the table of contents on the Fluent Bit docs site.

Similarly, if you update the `# h1` title header of an existing page, make sure to update that page's `SUMMARY.md` entry to match. `SUMMARY.md` entries takes precedence over in-page headers, which means that if you update a page's `# h1` title without updating `SUMMARY.md`, the unchanged `SUMMARY.md` title will persist in both the rendered page and the table of contents.

## Linters

This repository runs linters as GitHub Actions for each pull request. If a linter finds errors or makes suggested changes, you can view these results in the **Files changed** tab.

<details>
<summary>:mag: Examples: linter results</summary>

![An example of a warning-level Vale result.](/.gitbook/assets/vale-example-warning.png)

![An example of an error-level Vale result.](/.gitbook/assets/vale-example-error.png)

![An example of a Markdownlint result.](/.gitbook/assets/markdownlint-example.png)

</details>

### Vale

[Vale](https://vale.sh/docs/) lints prose for style and clarity. In addition to reviewing the results of each Vale test in GitHub, you can use the [Vale plugin for VSCode](https://marketplace.visualstudio.com/items?itemName=ChrisChinchilla.vale-vscode) to view errors and suggestions locally.

Vale tests for the Fluent Bit docs are stored in the [`/vale-styles`](https://github.com/fluent/fluent-bit-docs/tree/master/vale-styles) folder. Most Vale tests are at the `suggestion` or `warning` level and won't block pull requests from merging. However, tests at the `error` level will block merging until the associated issue is fixed.

### Markdownlint

[Markdownlint](https://github.com/markdownlint/markdownlint) lints Markdown formatting and makes suggestions for improvements. In addition to reviewing the results of each test in GitHub, you can use the [markdownlint plugin for VSCode](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint) to view suggestions locally.

Markdownlint tests for the Fluent Bit docs are stored in [`markdownlint.json`](https://github.com/fluent/fluent-bit-docs/blob/master/.markdownlint.json). These tests don't block pull requests from merging.

## Additional resources

For general guidance about writing documentation, consult the following resources:

- [Open Source Technical Documentation Essentials (LFC111)](https://training.linuxfoundation.org/training/open-source-technical-documentation-essentials-lfc111/)
- [Creating Effective Documentation for Developers (LFC112)](https://training.linuxfoundation.org/training/creating-effective-documentation-for-developers-lfc112/)
- [Google Technical Writing Courses for Engineers](https://developers.google.com/tech-writing)

<!-- vale on -->
<!-- markdownlint-disable MD033 -->
