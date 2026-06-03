# 02 — Scorecard

Scored by the orchestrator against the per-principle anchors. Rules applied: score the worst instance, tie-break downward, no weights. Evidence anchors reference `01-evidence.md`.

```
1. Good design is innovative — Score: 1/3
   Evidence: Standard streak-counter + skeleton-shimmer + celebration-burst patterns (E-S1, E-V5); no novel interaction or advance on the form.
   Justification: Imitates the generic habit-tracker pattern with minor variation (anchor 1); not 0 because it copies a genre, not a specific competitor's flow wholesale.

2. Good design makes a product useful — Score: 1/3
   Evidence: Core metric is a tap tally, not days — no calendar-day guard (E-C4); mandatory Apple sign-in with no skip before any use (E-C2); counter hidden behind a network wait although a local cached value exists (E-W3).
   Justification: The primary task completes but through unnecessary detours and on an unreliable measure (anchor 1); not 0 because viewing the count and adding a day are directly supported on Home.

3. Good design is aesthetic — Score: 1/3
   Evidence: No spacing scale (E-V1), semantic type mixed with hardcoded 25/30pt on the primary counter (E-V2), ad-hoc color assignments with an EMPTY AccentColor asset (E-V3), ~2.8:1 caption contrast (E-V4, INFERRED).
   Justification: Four systemic inconsistencies land in the 3–5 band (anchor 1); not 0 because system fonts/colors give a partial visible system and there is no active visual noise.

4. Good design makes a product understandable — Score: 1/3
   Evidence: "Negate day" and "Last tracking change date" jargon (E-C3); Reset/Negate exist only inside an unhinted long-press context menu (E-S3, E-A3); "Add days" plural adds one (E-C4).
   Justification: 2–3 unclear controls plus jargon (anchor 1); not 0 because the primary action is a clearly labeled, visually prominent button.

5. Good design is unobtrusive — Score: 2/3
   Evidence: 5 controls total (E-S1); zero idle animations once loaded, fireworks gated and self-dismissing (E-W4); static decorative header rows are quiet (E-V3).
   Justification: Chrome is visible but quiet (anchor 2); not 3 because the decorative header occupies the top of every screen including sign-in, and not 1 because decoration never competes with the counter.

6. Good design is honest — Score: 1/3
   Evidence: Two unconditional inflations — "You're doing great" on every screen and in every daily notification regardless of actual progress (E-C1); the headline metric "Non-smoking days" is actually a button-press tally (E-C4).
   Justification: 2+ inflations plus label→behavior mismatches (anchor 1); not 0 because no deceptive flow (no forced continuity, hidden cost, or fake scarcity — E-C2).

7. Good design is long-lasting — Score: 2/3
   Evidence: System fonts, system colors, native controls throughout (E-V2, E-V3); shimmer/fireworks are established, non-faddish patterns (E-W4).
   Justification: At most one dated marker (the purple glow-shadow pill button, E-V3) on an otherwise system-idiom design (anchor 2); not 3 because the unfinished accent/token story keeps it from reading as a deliberate, durable language.

8. Good design is thorough down to the last detail — Score: 0/3
   Evidence: empty, error, focus, disabled states all MISSING (E-V5); user-facing grammar error in the daily notification (E-C3); destructive actions with no confirmation (E-C2); errors assigned to a never-read variable (E-S4); same document fetched twice on load (E-W2).
   Justification: 4+ states missing with default-system behavior everywhere (anchor 0); the shipped typo and silent error handling confirm the absence of last-detail care rather than an isolated rough edge.

9. Good design is environmentally friendly — Score: 1/3
   Evidence: 13-package Firebase/gRPC/abseil/leveldb stack + transitive analytics for one Int and one Date (E-W1, INFERRED heavy); duplicate fetch of the same document (E-W2); launch-time permission interruption (E-W5); Reduce Motion ignored (E-A5).
   Justification: Heavy payload with motion always-on for those who opted out of it (anchor 1); not 0 because dark mode is honored via system colors and the idle screen runs zero animations (E-W4).

10. Good design is as little design as possible — Score: 2/3
    Evidence: 5 interactive controls app-wide (E-S1); every Home element except the decorative praise row serves the task; NavigationStack titles duplicate tab labels (E-S3).
    Justification: ≤2 removable elements — the unconditional praise row and the redundant navigation chrome (anchor 2); not 3 because those two removables exist, not 1 because nothing else is decoration.
```

## Total: **12 / 30**

| # | Principle | Score |
|---|-----------|-------|
| 1 | Innovative | 1 |
| 2 | Useful | 1 |
| 3 | Aesthetic | 1 |
| 4 | Understandable | 1 |
| 5 | Unobtrusive | 2 |
| 6 | Honest | 1 |
| 7 | Long-lasting | 2 |
| 8 | Thorough | 0 |
| 9 | Environmentally friendly | 1 |
| 10 | As little design as possible | 2 |
| | **Total** | **12/30** |
