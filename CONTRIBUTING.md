# Fluent Bit Documentation

First of all, thanks for taking the time to read this document. It means you are interested in contributing, and we highly appreciate the time you are investing.

## Introduction

[Fluent Bit Documentation](https://docs.fluentbit.io) source code lives in a separate repository called [fluent/fluent-bit-docs](https://github.com/fluent/fluent-bit-docs) on Github. The reason of this separate repository is to avoid extra commits on Fluent Bit source code project history that leads to more complexity when maintaining the core project: yes, we read the commit history every single day, and usually, we maintain separate branches and this separation simplify the process for us.

## Workflow

All documentation contributions arrives as Pull Requests (PR) on Github in the repository [fluent/fluent-bit-docs](https://github.com/fluent/fluent-bit-docs). Then some of the maintainers of Fluent Bit will review it, triage it, add comments if needed, or merge it.

Once a PR is merged, a third-party service called [Gitbook](https://gitbook.com) will receive a notification and will grab the latest changes, render a new site and update the content of [docs.fluentbit.io](https://docs.fluentbit.io).

## Source Code Structure

Documentation source code structure depends on Fluent Bit source code structure and its versions. In Fluent Bit source code, we  have a stable branch and a development branch; as of now, these are:

- stable branch: [1.8](https://github.com/fluent/fluent-bit/tree/1.8)
- development branch: [master](https://github.com/fluent/fluent-bit/tree/master)

For Documentation, we follow the same pattern; we have branches for the stable and development versions.

## Submitting Contributions

All contributions must be made **first** against [master branch](https://github.com/fluent/fluent-bit-docs/tree/master) which is the active development branch, and then **if** the contribution also applies for the current stable branch, submit another PR for that specific branch, if submitting another PR adds some complexity, please specify in the first PR as a comment (for master branch)  that it needs to be *backported*. One of our maintainers will take care of that process.

### GIT email check

Most of the time GIT is not fully configured in your environment, and when cloning the repository and committing changes, the user email might not be set. Make sure your email is properly configured. You can check your current setting with:

```bash
cd fluent-bit-docs/
git config user.email 
```

If you need to adjust your email, do this:

```
git config user.email something@myemailprovider.com
```

### Commit Subjects

The subject must be representative enough to describe which `file` or `interface` is modifying when committing your changes. An everyday use case or example is:

- User is enhancing the documentation for the Syslog output plugin

Considering that Syslog output plugin documentation resides in this address:

- [pipeline/outputs/syslog.md](https://github.com/fluent/fluent-bit-docs/blob/master/pipeline/outputs/syslog.md)

the suggested commit will be:

```
pipeline: outputs: syslog: fix grammar in examples
```

As you can see, the commit is prefixed with the paths of the file being modified. For maintainers, this helps to understand and prioritize the review of the contributions.

Usually, a PR can have multiple commits, but we enforce that every commit only touches one file or interface (we apply the same practice in Fluent Bit source code).

### Sign off your commits

Your commits must be **sign off**; this certifies who is the author of the commit. It might sound a bit redundant, but it is needed. If you don't sign-off your commits, our CI system will flag the PR with a [DCO](https://github.com/src-d/guide/blob/master/developer-community/fix-DCO.md) error and the PR will be blocked.

The following link explains how to fix DCO error by signing your commits properly:

- https://github.com/src-d/guide/blob/master/developer-community/fix-DCO.md

For short: always use `-s` when committing your changes, e.g.:

```
git commit -a -s -m "pipeline: outputs: syslog: fix grammar in examples"
```

