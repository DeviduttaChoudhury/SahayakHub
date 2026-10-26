# AI use disclosure

## Where AI is part of the product
The routing decision for every message is made by a large language model, guided by the prompt in `prompts/core_engine_system_prompt.txt` (the simulator also carries a shorter prompt in `prototype/index.html`). Its output is checked by ordinary code before anything is sent.

## Where AI tools were used to build it
- Claude (Anthropic) was used to review and extend the simulator, write the guard and nudge logic, write test scripts, and draft this documentation.
- Other AI assistants were used to draft early versions of the prompt and the database design.

## What the author did
- Defined the product, the three-tier model, the language rules and the safety rules.
- Ran the simulator with real message examples, found the failures (nudges applied to the wrong receivers, instructions leaking into receiver messages) and directed the fixes.
- Chose the track and prepared the submission.

## Estimate
Share of code and text produced with AI assistance: about 90 percent of the code and documentation was drafted with AI assistance. The product idea, the language and safety rules, the test messages, the bug reports and the decisions are the author's.

## Not AI output
Test results in `tests/` and the run ledger come from running the code. The preset answers in offline replay mode are pre-written examples and are labelled as such in the page.
