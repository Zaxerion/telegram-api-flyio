# Telegram Bot API Server on Fly.io

This repository deploys the official [Telegram Bot API server](https://github.com/tdlib/telegram-bot-api) in local mode using Docker and Fly.io.

## Requirements

- A Fly.io account and the `fly` CLI
- A Telegram API ID and API hash from [my.telegram.org](https://my.telegram.org)

## Configure and deploy

Run this from the project directory and follow the prompts to choose your Fly app name and region:

```sh
fly launch --no-deploy
```

`fly launch` creates the app and generates `fly.toml`; this repository intentionally does not include an account-specific Fly config. Review the generated file and make sure the HTTP service uses internal port `8081` (the port exposed by the Dockerfile). Add this mount configuration so Telegram Bot API data is persisted:

```toml
[[mounts]]
  source = 'telegram_data'
  destination = '/data'
```

Do not add a `[[vm]]` section unless you deliberately want to override Fly's default machine sizing.

Create a volume in the same region shown by `primary_region` in your generated `fly.toml`. Replace the placeholders with your app name and chosen volume size in GiB:

```sh
fly volumes create telegram_data --region YOUR_REGION --size YOUR_SIZE_GB -a YOUR_APP_NAME
```

Set the Telegram API credentials as Fly secrets; do not put them in the Dockerfile or commit them:

```sh
fly secrets set TELEGRAM_API_ID="your-api-id" TELEGRAM_API_HASH="your-api-hash" -a YOUR_APP_NAME
fly deploy -a YOUR_APP_NAME
```

Persistent bot data and files are stored under `/data` on the `telegram_data` volume.

## Verify

Call `getMe` using your bot token:

```sh
curl "https://<APP_NAME>.fly.dev/bot<YOUR_BOT_TOKEN>/getMe"
```

A successful response contains `"ok": true`. Do not share or commit your bot token.

## Use with Telegraf

Point Telegraf at the Fly app's API root:

```js
const bot = new Telegraf(process.env.BOT_TOKEN, {
  telegram: {
    apiRoot: 'https://<APP_NAME>.fly.dev',
  },
});
```
