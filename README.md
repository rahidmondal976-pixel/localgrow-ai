# LocalGrow AI — Full-stack MVP starter

A modern React/Vite dashboard starter for an AI-assisted marketing CRM for Indian local businesses.

## What is included

- Responsive SaaS dashboard UI
- Demo-mode customer CRM (add, search, delete, CSV export)
- Campaign drafts
- Follow-up automation rule builder (draft only)
- AI marketing message screen (demo mode; live Edge Function scaffold included)
- Settings and WhatsApp setup guidance
- Supabase schema with Row Level Security policies
- Supabase Edge Function scaffold for AI message generation
- WhatsApp webhook verification scaffold

## Important status

This is a **starter MVP**, not a production-ready WhatsApp automation service. In demo mode, data is held in browser memory and will reset on refresh. Live authentication/database need Supabase setup. AI needs a server-side provider key. Real WhatsApp sending and scheduled automation are not enabled by default.

Never put OpenAI keys, WhatsApp access tokens, Meta app secrets, or Supabase service-role keys in frontend `.env` variables. Only the Supabase URL and anon key belong in the frontend.

## Run locally

Requirements: Node.js 20+ and npm.

```bash
npm install
cp .env.example .env
npm run dev
```

Open the URL printed by Vite.

Without Supabase values, the app runs in demo mode. Demo mode is for evaluation only and does not provide secure accounts or persistent storage.

## Connect Supabase

1. Create a Supabase project.
2. Open SQL Editor and run `supabase/schema.sql`.
3. In Authentication settings, configure email verification and your allowed site URLs.
4. Copy the project URL and anon/public key into `.env`:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
5. Restart `npm run dev`.

The frontend uses Supabase Auth and reads/writes `business_profiles`, `customers`, and `automations`. Configure appropriate production policies and test tenant isolation before launch.

## Configure AI message generation

Deploy `supabase/functions/generate-marketing/index.ts` as an Edge Function. Add the provider key as a server-side secret:

```bash
supabase secrets set OPENAI_API_KEY=YOUR_KEY
supabase secrets set OPENAI_MODEL=gpt-4.1-mini
```

Deploy using the Supabase CLI:

```bash
supabase functions deploy generate-marketing
```

Provider model availability and pricing can change. Set a model available to your API account. This function is a minimal scaffold; before public launch add per-user rate limits, usage metering, abuse protection, stronger input validation, and an allowlisted CORS origin.

## WhatsApp integration requirements

Real automated sending requires a Meta/WhatsApp Business Platform setup. Follow the official docs:
https://developers.facebook.com/docs/whatsapp/cloud-api/

Production checklist:
- Complete Meta business and phone-number setup.
- Store WhatsApp access tokens and app secrets as server-side secrets only.
- Complete required permissions and template approval.
- Obtain appropriate customer permission and respect opt-outs.
- Outside the customer-service window, use approved message templates as required.
- Verify webhook signatures using `META_APP_SECRET` before trusting webhook events.
- Add a server-side scheduler (for example Supabase Cron calling a secured Edge Function).
- Implement a queue with idempotency keys, retries, rate limits, and per-tenant isolation.
- Log sent/delivered/read/failed statuses.
- Add consent and opt-out controls before enabling production sending.

The included webhook function is a scaffold and does **not** yet verify webhook signatures or persist delivery events. Do not use it for production until those TODOs are completed.

## Free hosting notes

The static frontend can be deployed to Vercel or Cloudflare Pages on an eligible free plan. Supabase has a free tier subject to current limits. AI API usage and WhatsApp messaging can incur charges; free hosting does not make those services free. Confirm each provider's current terms before deploying.

## Suggested next steps

1. Configure Supabase and test signup/login.
2. Add and isolate customer data per authenticated account.
3. Deploy the AI Edge Function and test message generation.
4. Implement server-side scheduled queue processing.
5. Complete Meta WhatsApp setup and webhook verification.
6. Add billing only after a small paid pilot validates demand.

## Current limitations

- Automation rules are saved as drafts; no scheduled sender is implemented.
- WhatsApp connection modal is informational; OAuth/embedded signup is not implemented.
- Demo fallback message is a deterministic template, not a live AI response.
- Campaign analytics are placeholders until real provider events are stored.
- Add customer edit flow, consent evidence, opt-out workflow, timezone tests, and production security review before selling.
