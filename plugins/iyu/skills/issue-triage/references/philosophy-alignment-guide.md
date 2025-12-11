# Philosophy Alignment Scoring Guide

Detailed methodology for evaluating how well an issue aligns with project philosophy and scope.

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
| 1 | Breaking | Fundamentally conflicts with architecture |

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

**Question**: Does it benefit the majority or a niche use case?

| Score | Description | User Impact |
|-------|-------------|-------------|
| 5 | Universal | Benefits >80% of users |
| 4 | Majority | Benefits 50-80% of users |
| 3 | Significant minority | Benefits 20-50% of users |
| 2 | Niche | Benefits 5-20% of users |
| 1 | Edge case | Benefits <5% of users |

**Estimation Methods**:
- Issue reactions/votes
- Related issues or questions
- Industry adoption data
- Community survey results
- Download/usage analytics

**Examples**:
- Score 5: "TypeScript support" (~70% of modern JS projects)
- Score 4: "PostgreSQL array support" (common database)
- Score 3: "Oracle-specific features" (enterprise niche)
- Score 2: "Firebird database support" (rare database)
- Score 1: "Custom protocol for company X" (single user)

**Key Questions**:
- How many similar requests have we received?
- Is this technology/pattern gaining or losing adoption?
- Would this attract new users or just help existing ones?

## Calculating Overall Alignment

### Simple Average

```
Overall = (Mission + Scope + Patterns + Impact) / 4
```

### Interpretation

| Range | Level | Typical Decision |
|-------|-------|------------------|
| 4.0-5.0 | High | ACCEPT likely |
| 3.0-3.9 | Medium | ADAPT or DEFER likely |
| 1.0-2.9 | Low | REDIRECT or DECLINE likely |

### Weighted Considerations

In some cases, certain dimensions matter more:

**Mission-Critical Projects** (core infrastructure):
- Weight Mission Fit and Scope higher
- Be strict about scope creep

**Developer Experience Projects**:
- Weight User Base Impact higher
- Consider adoption and ecosystem fit

**Early-Stage Projects**:
- Be more flexible with patterns
- Focus on mission and impact

**Mature Projects**:
- Weight Pattern Consistency higher
- Protect existing users and API stability

## Red Flags

Automatic score reductions regardless of other factors:

| Red Flag | Impact | Example |
|----------|--------|---------|
| Security risk | -2 overall | Exposing credentials |
| Breaking change | -1 to patterns | Removing existing API |
| Runtime dependency | -1 to scope | Adding heavy library |
| Maintenance burden | -1 to scope | External service integration |
| Precedent danger | -1 to mission | Opens flood of similar requests |

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
[ ] Breaking change
[ ] Runtime dependency
[ ] High maintenance burden
[ ] Precedent danger

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

### Pitfall 4: Inconsistent Scoring Over Time

Keep consistent standards:
- Document scoring decisions for reference
- Review past decisions when similar requests arrive
- Maintain project philosophy document

## Integration with Feasibility

Philosophy alignment combines with feasibility for final decision:

```
                 | Philosophy HIGH | Philosophy LOW  |
-----------------|-----------------|-----------------|
Feasibility HIGH | ACCEPT          | REDIRECT        |
Feasibility MED  | ADAPT           | DEFER/REDIRECT  |
Feasibility LOW  | DEFER           | DECLINE         |
```

High philosophy + low feasibility = valuable but defer
Low philosophy + high feasibility = redirect to alternatives
Both low = decline with clear explanation
