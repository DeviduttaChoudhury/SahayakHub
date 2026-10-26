# SahayakHub

Voice-first message routing on WhatsApp for people who cannot use apps, built around Romanised Odia and Hinglish. A caregiver or shopkeeper sends one messy message ("Bicky ku kahibu party 7ta re, 6:30 sudha ready thibe, mu 6ta re pakeidibi. Bhaina ku bhi same janaibu"). SahayakHub works out who it is for, translates each person's part into their language, and sends it, with an optional timed reminder.

Author: Devidutta Choudhury, Indira Gandhi Institute of Technology, Sarang, Dhenkanal, Odisha.

Submission to the Hack for Social Cause track, Viksit Bharat Young Leaders' Dialogue 2027. State: Odisha.

## What exists today, and what does not

| Part | Status |
|---|---|
| Routing prompt and JSON schema (`prompts/`) | Written and tested through the simulator |
| Browser simulator (`prototype/index.html`) | Working. Sender chat, one phone per receiver, nudges, tier rules, run ledger with CSV export |
| Rule guard (inside the simulator) | Working. Checks tier limits, unverified recipients, instruction words leaking into receiver messages |
| Database design (`supabase/schema.sql`) | Designed. Not deployed |
| Live WhatsApp pipeline (Cloud API, n8n, Supabase) | **Not built yet.** See `docs/ARCHITECTURE.md` and the plan below |
| Institutional tier (old-age homes, hospitals) | Planned. Not built |

## Run the prototype

Open `prototype/index.html` in any browser. No install, no server.

- **Outside Claude** it runs in *offline replay mode*. The ten preset buttons return pre-written example answers (not live model output). The tier checks, nudge timing, relay check and run ledger all run for real on those answers. Typing your own message does not work in this mode.
- **Inside Claude** (the page published as a Claude artifact) every message goes to the model with the prompt in the page, so any message works.

Try the preset "Pickup + nudge": one message, two receivers, both nudged at 6:00 PM. Then "Two people": two receivers, only one has a nudge, and only that receiver's phone shows a Touch 2.

## Environment variables

The simulator needs none. The planned live version (`docs/ARCHITECTURE.md`) will need these, set in n8n and never committed:

```
WHATSAPP_ACCESS_TOKEN     Meta WhatsApp Cloud API token
WHATSAPP_PHONE_NUMBER_ID  the sending number id
WHATSAPP_VERIFY_TOKEN     webhook verification string you choose
SUPABASE_URL              project URL
SUPABASE_SERVICE_KEY      service role key (server side only)
GEMINI_API_KEY            model API key
```

## Sample data and tests

`samples/sample_contacts.json` is the demo address book. `samples/sample_messages.json` lists the ten example messages with the verdict and nudges expected for each.

## Run the tests

```
pip install playwright
python tests/smoke_test.py
```

Opens the prototype in a headless browser and runs every preset, checking verdicts, per-receiver nudges and the free-tier guard.

## Repository layout

```
prototype/index.html        the simulator (single file)
prompts/                    the routing prompt and the JSON schema it must satisfy
supabase/schema.sql         planned database design
docs/PROBLEM_STATEMENT.md   Odisha problem, who is affected, current gaps
docs/ARCHITECTURE.md        how it works and how the live version will work
docs/AI_DISCLOSURE.md       how AI tools were used
samples/                    sample contacts and example messages with expected results
tests/smoke_test.py         browser test of the simulator
```

## Plan

1. Connect the simulator's logic to the WhatsApp Cloud API through n8n and Supabase using a Meta test number.
2. Run it with the author's own contacts and publish the run ledger.
3. Add the institutional tier (care homes) after consent and data-protection design.

## Licence

MIT. See `LICENSE`.
