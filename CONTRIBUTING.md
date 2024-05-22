# Contributing to Fluent Bit docs

First of all, thanks for taking the time to read this guide. The fact that you're
here means you're interested in contributing to Fluent Bit, and we highly appreciate
your time.

This repository contains the files for the
[Fluent Bit documentation library](https://docs.fluentbit.io/). Keeping these docs
separate from the [main Fluent Bit repository](https://github.com/fluent/fluent-bit)
helps reduce the number of commits to the Fluent Bit source code and makes it
easier to maintain both projects.

Fluent Bit has a group of dedicated maintainers who oversee this repository,
including several technical writers. These writers will review any pull requests
you open, so don't be afraid to contribute—even if you're not a writer by trade.
Your suggestions are valuable, and we'll help you wrangle any stray commas.

## GitBook

The Fluent Bit docs library is built and hosted through
[GitBook](https://docs.gitbook.com/). Unfortunately, GitBook doesn't support
local previews for contributors, but a Fluent Bit maintainer with a dedicated GitBook
account can verify that things are formatted correctly after you open a new pull
request.

Each `.md` file in this repository is a single page. You can use
[standard Markdown syntax](https://docs.gitbook.com/content-editor/editing-content/markdown)
to edit existing pages, or create a new `.md` file to add an additional page to
the docs library. If you create a new page, you'll also need to update
[GitBook's `SUMMARY.md` file](https://docs.gitbook.com/integrations/git-sync/content-configuration#structure)
(or ask a maintainer to update it for you).

## Workflow

After you open a pull request in this repo, a Fluent Bit maintainer will review
it, triage it, add comments or suggestions as needed, and then merge it. After
your changes are successfully merged into `master`, the docs site will update
within a few minutes.

### Stale pull requests

If you open a pull request that requires ongoing discussion or review, the
Fluent Bit maintainers will add a [`waiting-for-user` tag](#tags) to your pull
request. This tag means that we're blocked from moving forward until you reply.
To keep contributions from going stale, we'll wait 45 days for your response,
but we may close the pull request if we don't hear back from you by then.

## Submit a contribution

When you open a pull request, make your changes against `master`, which is the
active development branch. If your contribution also applies to the latest
stable version, submit another PR for that versioned branch. However, if
submitting multiple PRs at the same time adds too much complexity, you can instead
create a single PR against `master` and specify that your changes need to be
**backported** to other branches; one of our maintainers will take care of that
process on your behalf.

All contributions must be made **first** against [master branch](https://github.com/fluent/fluent-bit-docs/tree/master) which is the active development branch, and then **if** the contribution also applies for the current stable branch, submit another PR for that specific branch, if submitting another PR adds some complexity, please specify in the first PR as a comment (for master branch) that it needs to be *backported*. One of our maintainers will take care of that process.

As a contributor, we'll ask you to follow a few best practices related to Git:

### One file per commit

Each commit you make should only modify one file or interface—we follow the same
practice in the Fluent Bit source code.

### Commit subjects

Use descriptive commit subjects that describe which file or interface you're
modifying.

For example, if you're modifying the Syslog output plugin doc, whose file is
located at [pipeline/outputs/syslog.md](https://github.com/fluent/fluent-bit-docs/blob/master/pipeline/outputs/syslog.md), this would be a descriptive commit subject:

`pipeline: outputs: syslog: fix grammar in examples`

Since this commit is prefixed with the relevant file path, it helps our maintainers
understand and prioritize your contribution.

### Set your email in Git

Make sure your email address is configured in your local Git environment. This
should be the same email address associated with your GitHub account.

For more information, refer to GitHub's guide to
[setting your commit email address in Git](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-email-preferences/setting-your-commit-email-address#setting-your-commit-email-address-in-git).

### Sign off your commits

You must sign off your commits to certify your identity as the commit author. If
you don't sign off your commits, our CI system will flag the pull request with a
[DCO](https://github.com/src-d/guide/blob/master/developer-community/fix-DCO.md)
error and prevent your pull request from merging.

To prevent DCO errors, refer to the following guide about
[signing your commits properly](https://github.com/src-d/guide/blob/master/developer-community/fix-DCO.md).

> :bulb: For faster signing, you can use the `-s` flag in Git:
>
> `git commit -a -s -m "pipeline: outputs: syslog: fix grammar in examples"`
>
> If you're using VS Code, you can also enable the
> [**Git: Always Sign Off**](https://github.com/microsoft/vscode/issues/83096#issuecomment-545350047)
> setting, whch automatically appends a `Signed-off-by:` message to your commits.

## Style guidelines

The Fluent Bit maintainers refer to the
[Google developer documentation style guide](https://developers.google.com/style)
for most topics related to grammar, style, and formatting. We don't expect you
to memorize these style rules, but the technical writer who reviews your pull
request may suggest changes accordingly.

### Vale

The Fluent Bit maintainers are working to add a [Vale](https://vale.sh/docs/) plugin
to this repository, which will automatically lint pull requests and add
suggestions to improve style and clarity.
