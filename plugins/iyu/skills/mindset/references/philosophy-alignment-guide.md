# Philosophy Alignment Scoring Guide

Detailed methodology for evaluating how well an issue aligns with project philosophy and scope.

## Contents

- [Overview](#overview)
- [The Four Dimensions](#the-four-dimensions) — Core Mission Fit, Scope Alignment, Pattern Consistency, User Base Impact
- [Calculating Overall Alignment](#calculating-overall-alignment) — average, interpretation, weighting
- [Red Flags](#red-flags)
- [Scoring Worksheet Template](#scoring-worksheet-template)
- [Common Scoring Pitfalls](#common-scoring-pitfalls)
- [Integration with Feasibility](#integration-with-feasibility)

## Overview

Philosophy alignment scoring determines whether a request fits the project's identity, mission, and established patterns. This guide provides detailed criteria for consistent, defensible scoring.

## The Four Dimensions

### 1. Core Mission Fit (1-5)

**Question**: Does this serve the project's primary purpose?

| Score | Description | Indicators |
|-------|-------------|------------|
| 5 | Perfect fit | Directly advances core mission; users expect this |
| 4 | Strong fit | Natural extension of core capabilities |
| 3 | Acceptable | Related to mission but peripheral |
| 2 | Marginal | Tangentially related; stretches definition |
| 1 | Poor fit | Conflicts with or distracts from mission |

**Examples**:
- Score 5: "Add TypeScript types" for a JS library (DX is core)
- Score 4: "Add new query operator" for query builder
- Score 3: "Add logging integration" (helpful but not core)
- Score 2: "Add deployment scripts" (operational, not library)
- Score 1: "Build a GUI dashboard" (completely different product)

**Key Questions**:
- Would this appear in a "What is [project]?" description?
- Do competitors in this space typically include this?
- Would users be surprised if this feature existed?

### 2. Scope Alignment (1-5)

**Question**: Is this library responsibility or application concern?

| Score | Description | Indicators |
|-------|-------------|------------|
| 5 | Core library | Infrastructure that belongs in the library |
| 4 | Library infrastructure | Supporting capability for library users |
| 3 | Borderline | Could go either way; requires judgment |
| 2 | Application adjacent | More app-level but could be supported |
| 1 | Application concern | Clearly application responsibility |

**Library vs. Application Boundary**:

| Library Responsibility | Application Responsibility |
|------------------------|---------------------------|
| Query construction | Query caching |
| Type definitions | User authentication |
| Error handling patterns | Error message display |
| Connection interface | Connection pooling strategy |
| Data validation rules | Business validation logic |

**Examples**:
- Score 5: "Improve query builder API" (core library)
- Score 4: "Add middleware hooks" (library infrastructure)
- Score 3: "Add retry logic" (could be either)
- Score 2: "Add request logging" (more app-level)
- Score 1: "Add user management" (application feature)

**Key Questions**:
- Would this require application-specific configuration?
- Does this involve runtime state management?
- Could different applications need this implemented differently?

### 3. Pattern Consistency (1-5)

**Question**: Does it fit existing architecture and conventions?

| Score | Description | Indicators |
|-------|-------------|------------|
| 5 | Natural extension | Follows existing patterns exactly |
| 4 | Consistent | Minor adaptation of existing patterns |
| 3 | Compatible | Different but not conflicting |
| 2 | Divergent | Requires new patterns that might conflict |
| 1 | Conflicting | Fundamentally conflicts with architecture |

**Pattern Considerations**:
- API style (fluent, functional, declarative)
- Error handling approach
- Configuration patterns
- Naming conventions
- Module organization

**Examples**:
- Score 5: "Add new chainable method" (matches fluent API)
- Score 4: "Add configuration option" (extends existing config)
- Score 3: "Add callback support" (different but compatible)
- Score 2: "Add promise-based alternative API" (parallel patterns)
- Score 1: "Rewrite to use classes" (conflicts with functional style)

**Key Questions**:
- Does this follow established naming conventions?
- Can this be implemented without changing core abstractions?
- Would existing users find this intuitive?

### 4. User Base Impact (1-5)

**Question**: How wide is the set of users who share this request's *root cause*?

Read one request as a sample of everyone who runs into the same underlying problem ("Think 10 from
1"). A niche-sounding API request is often the first report of a gap every user of that path hits;
a popular one can still be a single deployment's concern stated many times. Restate the root cause
in the library's own terms first, then score how far it reaches — not how many people asked.

| Score | Description | The root cause is shared by |
|-------|-------------|-----------------------------|
| 5 | Universal | Effectively every user of the library |
| 4 | Majority | Most users — a common path, a mainstream platform |
| 3 | Significant minority | A substantial, recognizable segment |
| 2 | Niche | A narrow segment with a distinct environment |
| 1 | Single context | One deployment's specifics — usually a sign the concern sits outside the library (see Scope Alignment) |

**Evidence for the reading — never the score itself**:
- Related issues, questions, or reactions
- Industry adoption data
- Download/usage analytics

These help establish who shares the root cause. Their absence is not a low score: the first report
of a problem everyone has scores high on its first day.

**Examples**:
- Score 5: "TypeScript support" (type safety is wanted on every typed call path)
- Score 4: "PostgreSQL array support" (common database)
- Score 3: "Oracle-specific features" (enterprise segment)
- Score 2: "Firebird database support" (rare database)
- Score 1: "Custom protocol for company X" (one deployment's private protocol)

**Key Questions**:
- What is the root cause behind the request, stated in the library's terms?
- Who else runs into that root cause, whether or not they have asked?
- Is this technology/pattern gaining or losing adoption?

## Calculating Overall Alignment

### Simple Average

```
Overall = (Mission + Scope + Patterns + Impact) / 4
```

### Interpretation

| Range | Level | Typical Decision |
|-------|-------|------------------|
| 4.0-5.0 | High | ACCEPT likely |
| 3.0-3.9 | Medium | ADAPT likely (DEFER only with a named blocker) |
| 1.0-2.9 | Low | REDIRECT or DECLINE likely |

### Weighted Considerations

In some cases, certain dimensions matter more:

**Mission-Critical Projects** (core infrastructure):
- Weight Mission Fit and Scope higher
- Be strict about scope creep

**Developer Experience Projects**:
- Weight User Base Impact higher
- Consider adoption and ecosystem fit

**Pre-1.0 Projects**:
- Be more flexible with patterns
- Focus on mission and impact
- A breaking change is an ordinary tool here (released as a minor) — it costs nothing in the score

**Stable (1.0+) Projects**:
- Weight Pattern Consistency higher
- A change to a published contract is not scored down; it is reported as a version decision
  (it implies a major release, which is the owner's call)

## Red Flags

Score reductions for properties of the *design* — never for the effort it takes or the number of
people who asked ([decision-lenses.md](../../_shared/decision-lenses.md) defines what is not a
lens):

| Red Flag | Impact | Example |
|----------|--------|---------|
| Security risk | -2 overall | Exposing credentials |
| Runtime dependency | -1 to scope | Adding heavy library |
| Maintenance burden — complexity the design leaves behind | -1 to scope | An external service the library must track from now on (not "a lot of work to build") |
| Precedent danger | -1 to mission | Opens flood of similar requests |

**Breaking change is not a red flag — it is read by version stage.** Pre-1.0: no reduction; breaking
is an ordinary tool, released as a minor. 1.0+: no reduction either, but a change to a published
contract is flagged for the owner as a version decision. Neither stage lets "it breaks something"
decide between options.

## Scoring Worksheet Template

```
PHILOSOPHY ALIGNMENT ASSESSMENT
==============================
Issue: [title]
Date: [date]
Evaluator: [name/system]

DIMENSION SCORES
----------------
Core Mission Fit:    [1-5]
Reasoning: [why this score]

Scope Alignment:     [1-5]
Reasoning: [why this score]

Pattern Consistency: [1-5]
Reasoning: [why this score]

User Base Impact:    [1-5]
Reasoning: [why this score]

RED FLAGS
---------
[ ] Security risk
[ ] Runtime dependency
[ ] High maintenance burden (complexity left behind, not effort)
[ ] Precedent danger

VERSION NOTE (not scored)
-------------------------
[ ] Breaking change — pre-1.0: ordinary, minor release · 1.0+: report as version decision

OVERALL CALCULATION
-------------------
Base: ([_] + [_] + [_] + [_]) / 4 = [_]
Red flag adjustments: [_]
Final: [_]
Level: [High/Medium/Low]

NOTES
-----
[Any additional considerations]
```

## Common Scoring Pitfalls

### Pitfall 1: Conflating "Nice" with "Aligned"

A feature can be nice without being aligned:
- "Add dark mode" might be nice but not aligned for a CLI library
- Score based on fit, not desirability

### Pitfall 2: Overweighting Popular Requests

Popular doesn't mean aligned:
- Many requests might still be application-level concerns
- Scope boundary matters regardless of demand

### Pitfall 3: Underweighting Maintenance

Consider long-term cost:
- A feature with high initial impact but ongoing burden might score lower
- Factor maintenance into scope alignment
- "Burden" is the complexity the design leaves for every future change — not the effort to build
  it. Effort decides staging, not alignment

### Pitfall 4: Inconsistent Scoring Over Time

Keep consistent standards:
- Document scoring decisions for reference
- Review past decisions when similar requests arrive
- Maintain project philosophy document

### Pitfall 5: Scoring the Effort or the Headcount

Neither how much work a change is nor how many people asked for it is a dimension:
- Large, aligned work is staged into pieces that each ship — not marked down
- A single request is read for its root cause (User Base Impact) — not discounted for being single

## Integration with Feasibility

Philosophy alignment combines with feasibility for final decision.

**Feasibility is about real blockers, not effort.** It asks whether something concrete has to
happen first:

| Feasibility | Means |
|-------------|-------|
| HIGH | Nothing blocks starting now |
| MED | Partly blocked — a slice or an adapted form can proceed now; the rest waits on a named blocker |
| LOW | A real prerequisite blocks it: a design decision not yet made, an external dependency not yet available, or earlier work on the same surface |

How much work it takes is not feasibility. A large, aligned change is accepted and **staged**, never
deferred for its size. "It competes with current priorities" is ordering, not a blocker: accept it
and place it in the backlog.

```
                 | Philosophy HIGH | Philosophy LOW  |
-----------------|-----------------|-----------------|
Feasibility HIGH | ACCEPT          | REDIRECT        |
Feasibility MED  | ADAPT           | DEFER/REDIRECT  |
Feasibility LOW  | DEFER           | DECLINE         |
```

High philosophy + low feasibility = valuable but blocked — defer with the named blocker as the
resume condition (it resumes when the blocker clears, not when demand accumulates)
Low philosophy + high feasibility = redirect to alternatives
Both low = decline with clear explanation
