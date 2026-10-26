"""Smoke test for prototype/index.html in offline replay mode. Run: python tests/smoke_test.py"""
import pathlib, sys
from playwright.sync_api import sync_playwright

PAGE = pathlib.Path(__file__).resolve().parent.parent / "prototype" / "index.html"
fails = []
def check(ok, what):
    print(("PASS " if ok else "FAIL ") + what)
    if not ok: fails.append(what)

with sync_playwright() as p:
    b = p.chromium.launch(executable_path='/opt/pw-browsers/chromium') if __import__('os').path.exists('/opt/pw-browsers/chromium') else p.chromium.launch()
    pg = b.new_page()
    errs = []
    pg.on("pageerror", lambda e: errs.append(str(e)))
    pg.goto(PAGE.as_uri()); pg.wait_for_timeout(300)
    check("Offline replay mode" in pg.inner_text("#conn"), "page starts in offline replay mode")
    pg.select_option("#tier", "paid")

    def run(preset):
        pg.click(f'#presets button:has-text("{preset}")'); pg.click("#run"); pg.wait_for_timeout(300)
        return pg.inner_text("#st").split()[0], pg.inner_text("#recv")

    st, recv = run("Pickup + nudge")
    check(st == "ready", "pickup+nudge is ready")
    check(recv.count("TOUCH 2: TIME-DELAYED") == 2 and "6:00 PM" in recv, "Bicky and Bhaina both nudged at 6:00 PM")

    st, recv = run("Two people")
    check(st == "ready" and len(pg.query_selector_all("#recv .phone")) == 2, "two people: two receiver phones")
    check(recv.count("TOUCH 2: TIME-DELAYED") == 1, "only the receiver with a time gets Touch 2")
    check("NO NUDGE" not in recv.upper(), "receiver without nudge sees no nudge bubble")

    st, _ = run("Unverified")
    check(st == "needs_verification", "unverified contact freezes the message")
    st, _ = run("Broadcast")
    check(st == "blocked_by_tier", "broadcast is blocked")

    pg.select_option("#tier", "free")
    pg.click("#resetwin")
    st, _ = run("Pickup + nudge")
    check(st == "ready", "free tier allows 2 recipients")

    check(not errs, "no page errors")
    b.close()
sys.exit(1 if fails else 0)
