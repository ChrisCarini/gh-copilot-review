# `gh copilot-review`

A [`gh` CLI](https://cli.github.com/) extension that
adds [Copilot as a reviewer on pull requests](https://github.blog/changelog/2025-04-04-copilot-code-review-now-generally-available/).

## 🚀 Motivation

`gh copilot-review` is a simple CLI tool to request a GitHub Copilot Code Review on a pull request directly from your terminal. It streamlines the process of
invoking Copilot's PR review bot, saving you time and making it easier to get AI-powered feedback on your code changes.

## 📦 Installation

```shell
gh extension install ChrisCarini/gh-copilot-review
```

_**Note:** This script requires the [GitHub CLI (`gh`)](https://cli.github.com/) to be installed and authenticated._

## ⚡️ Usage

Request a Copilot code review on a GitHub pull request.

```
gh copilot-review [<number> | <url>]
```

**Arguments:**

- By number, e.g. `123`
- By URL, e.g. `https://github.com/OWNER/REPO/pull/123`

**Examples:**

```
gh copilot-review 353
gh copilot-review https://github.com/OWNER/REPO/pull/353
```

## ⭐ Inspiration

This project was inspired by:

- a desire to automate adding Copilot to certain PRs
- indirect encouragement from a few colleagues looking for the same thing, and...
- the 🔑 piece, a comment on [cli/cli/issues/10598#issuecomment-2893526162](https://github.com/cli/cli/issues/10598#issuecomment-2893526162)
