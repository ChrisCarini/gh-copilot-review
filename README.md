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

### 🤖 Automatically request a Copilot code review on PRs

> [!NOTE]
> GitHub has native functionality to [enable automatic Copilot reviews](https://docs.github.com/en/copilot/using-github-copilot/code-review/using-copilot-code-review#enabling-automatic-reviews). **It's advised to use that, if able.**
>
> The below workflow is better suited for cases where more complex logic is desired.

Use the below workflow to automatically request a Copilot review on pull requests that match certain criteria.

```yaml
name: Automatic Copilot Code Review

on:
  pull_request:
    types:
      - opened           # brand-new PRs
      - ready_for_review # drafts marked “Ready for review”
      - reopened         # PRs that were closed then reopened

jobs:
  add-copilot-to-pr-reviews:
    name: "Add Copilot to PR reviews"
    if: ${{ github.event.pull_request.draft == false }}   # skip still-draft PRs
    runs-on: ubuntu-latest
    env:
      GH_TOKEN: ${{ secrets.GH_TOKEN_COPILOT_REVIEW }}   # gh CLI picks this up automatically

    steps:
      - name: Install gh-copilot-review extension
        run: gh extension install ChrisCarini/gh-copilot-review

      - name: Ask Copilot to review this PR
        run: gh copilot-review "${{ github.event.pull_request.html_url }}"
```

#### Token Permissions

You need to create a [GitHub fine-grained personal access token (PAT)](https://github.com/settings/personal-access-tokens/new?name=GH_TOKEN_COPILOT_REVIEW&description=For+Automatic+Copilot+Code+Reviews&expires_in=365&pull_requests=write) with the following permission:

- `Pull requests: Read and write`

Then, add it as a secret to your repository. In the above example, the secret is named `GH_TOKEN_COPILOT_REVIEW`.

**Note:** As of 2025-09, the above link will deep-link you to the fine-grained PAT page with the correct permissions selected. _(Thanks to [@cole-hartman](https://github.com/cole-hartman) and [@dorisbwang](https://github.com/dorisbwang) work adding [Template URLs for fine-grained PATs](https://github.blog/changelog/2025-08-26-template-urls-for-fine-grained-pats-and-updated-permissions-ui/))_

## ⭐ Inspiration

This project was inspired by:

- a desire to automate adding Copilot to certain PRs
- indirect encouragement from a few colleagues looking for the same thing, and...
- the 🔑 piece, a comment on [cli/cli/issues/10598#issuecomment-2893526162](https://github.com/cli/cli/issues/10598#issuecomment-2893526162)
