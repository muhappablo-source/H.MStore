# H.M STORE AI — server scaffold

This folder contains the first Node.js server scaffold for the official WhatsApp Cloud API webhook.

## Render settings
- Runtime: Node
- Root Directory: `bot`
- Build Command: `npm install`
- Start Command: `npm start`
- Health Check Path: `/`

## Environment variables (add later in Render only)
- `WHATSAPP_VERIFY_TOKEN`: a private random value you choose for Meta webhook verification.
- `WHATSAPP_ACCESS_TOKEN`: the access token issued by Meta.
- `WHATSAPP_PHONE_NUMBER_ID`: the WhatsApp Cloud API phone number ID.
- `PORT`: provided automatically by Render; do not set unless needed.

Never put real tokens, passwords, or private credentials in GitHub files.

## Current status
The server can answer a health check and handle Meta webhook verification and incoming webhook requests. It does not send replies or use an AI model yet. Configure Cloud API and add the AI reply integration before enabling customer-facing automation.
