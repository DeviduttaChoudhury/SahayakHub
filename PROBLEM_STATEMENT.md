# Problem statement (Odisha)

## The problem
Many people in Odisha already run their family and work life on WhatsApp, but only in the ways they are comfortable with: short voice notes and phonetic Odia or Hindi typed in English letters. People who care for an elderly or ill relative, and small shop owners who depend on a driver or a supplier, give instructions to several people a day this way. Each instruction is easy to say and easy to miss: who exactly must hear it, in which language, and at what time.

## Who is affected
- **Caregivers of elderly relatives**, including relatives with dementia or poor eyesight. They coordinate medicine times, doctor visits and who accompanies whom, across family members who may prefer Odia or Hindi.
- **Small shop owners and local businesses** coordinating a driver, a supplier or a helper.
- **The people being cared for**, who cannot use apps but can receive a short message or a call to action from a family member.

## Current gaps
1. Standard reminder and task apps need typing in a fixed format, an English interface, or a smartphone-literate user.
2. Group chats send the same message to everyone, so people receive instructions that are not theirs, in a language that may not be theirs.
3. Nothing separates what a person is telling the assistant ("tell Bhaina the same as Bicky") from what a recipient should read, so assistants either copy the instruction or miss the target.
4. Reminders depend on the sender remembering to send them again.
5. There is no safe way for an assistant to message a stranger. A message to someone who has never contacted the service must not be sent automatically.

## Solution in one paragraph
SahayakHub accepts one message in Romanised Odia or Hinglish, identifies each recipient, writes each person's part in their own language, and sends it. Contacts the system does not know yet are verified before anything is sent. Contacts who have not been reached through the service are handled in assist mode, where the sender forwards a prepared WhatsApp link from their own phone. Where the sender gives a time, each affected receiver also gets a timed reminder.

## Target beneficiaries and impact (to complete with sourced figures)
Needs figures before submission, each with a source:
- [ ] Number or share of people aged 60+ in Odisha (Census / LASI).
- [ ] Prevalence of dementia or vision impairment among older adults in India, with the source.
- [ ] Smartphone or WhatsApp use among Odisha households, with the source.

Measured impact from the prototype so far is limited to the run ledger (`Export CSV` in the simulator): runs, deliveries, held messages, blocked messages, relay warnings and nudges queued. These are simulator runs by the author, not field results, and must be described that way.

## Limits and risks, stated plainly
- The simulator is not connected to WhatsApp yet.
- The model can misread Odia. The guard layer and the correction feedback reduce this but do not remove it.
- Health and care messages are sensitive. The live version must store as little as possible, ask consent from every contact, and follow India's Digital Personal Data Protection Act. This design work is not done yet.
