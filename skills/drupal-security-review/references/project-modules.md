# Project-specific module reference

This file lists this repository's project-specific paths and custom module
names to pay particular attention to for each checklist item in
`../SKILL.md`. The checklist items themselves are generic and apply to all
custom code — this file only narrows down *where to look first* for a given
concern.

## Review scope

- Custom modules: `web/modules/custom/*`
- Custom theme: `web/themes/custom/tipi_bootstrap`

## Securing authentication credentials

Hardcoded secrets in PHP/JS, particularly in these integrations:

- `quintain_auth0`
- `quintain_salesforce*`
- `quintain_yardi*`

Exported config (`./config/*.yml`) most likely to contain committed secrets
(API keys, client secrets/ids, tokens, passwords, private keys, SMTP/webhook
credentials) instead of Key module / environment references:

- `quintain_auth0.*`
- `quintain_yardi*.*`
- `quintain_google_reviews.*`
- `quintain_trustpilot.*`
- `quintain_rakuten.*`
- Any `*.settings.yml` for third-party integrations, webform handlers, and
  simple_oauth/consumer config.

## Password management

Custom login/registration/password-reset code most likely to implement
custom password handling instead of Drupal's `PasswordInterface` service:

- `quintain_user`
- `quintain_auth0*`
- `quintain_2022_create_account`

## Privacy management / access bypass

Custom REST/JSON endpoints most likely to expose PII without access control:

- `quintain_endpoints`
- `quintain_export`
