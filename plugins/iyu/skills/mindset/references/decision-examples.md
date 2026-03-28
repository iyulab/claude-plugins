# Issue Triage Decision Examples

Real-world examples demonstrating the decision framework in action.

## ACCEPT Example: TypeScript Type Definitions

**Issue**: "Add TypeScript type definitions for the public API"

**Analysis**:
- Surface Request: Add .d.ts files
- Underlying Need: Type safety and IDE autocomplete for TS users
- Job to be Done: Get type checking when using library in TypeScript

**Philosophy Alignment**: 4.75/5 (High)
- Core Mission: 5 - Developer experience is core
- Scope: 5 - Types are library infrastructure
- Patterns: 4 - Standard practice in ecosystem
- User Impact: 5 - Benefits majority of modern users

**Feasibility**: High
- Complexity: Low - straightforward type extraction
- Breaking: None - additive only
- Maintenance: Low - types update with API

**Decision**: ACCEPT
- Perfect alignment with DX mission
- Low complexity, high impact
- No downsides

**Response**: "Thank you for suggesting TypeScript types! This aligns perfectly with our DX focus. We've added comprehensive type definitions in v2.1.0."

---

## ADAPT Example: Custom Error Messages

**Issue**: "Add ability to customize all error messages for i18n"

**Analysis**:
- Surface Request: Make every error string configurable
- Underlying Need: Support non-English users
- Job to be Done: Display errors in user's language

**Philosophy Alignment**: 3.5/5 (Medium)
- Core Mission: 4 - Usability matters
- Scope: 3 - Borders on application concern
- Patterns: 3 - Not our current pattern
- User Impact: 4 - Benefits international users

**Feasibility**: Medium
- Complexity: Medium - affects many files
- Breaking: Minor - if done carefully
- Maintenance: Medium - new surface area

**Decision**: ADAPT
- Good idea, but full customization is over-engineered
- Better approach: Error codes + message catalog

**Adapted Solution**:
```javascript
// Instead of customizing every string:
throw new CustomError("User not found");

// Provide error codes and let apps handle messages:
throw new LibraryError({ code: "USER_NOT_FOUND", context: { id } });
```

**Response**: "Great suggestion for i18n support! Rather than customizing individual messages, we'll add error codes that your app can map to localized strings. This keeps our API stable while giving you full control."

---

## DEFER Example: GraphQL Support

**Issue**: "Add native GraphQL query builder"

**Analysis**:
- Surface Request: Build GraphQL queries like SQL queries
- Underlying Need: Same developer experience for GraphQL
- Job to be Done: Query GraphQL APIs with familiar patterns

**Philosophy Alignment**: 3.75/5 (Medium-High)
- Core Mission: 4 - Query building is our focus
- Scope: 4 - Natural extension to other query languages
- Patterns: 3 - Would require new patterns
- User Impact: 4 - Growing GraphQL adoption

**Feasibility**: Low
- Complexity: High - different paradigm from SQL
- Breaking: None - would be new module
- Maintenance: High - separate ecosystem to track

**Decision**: DEFER
- Valuable and aligned, but significant undertaking
- Current focus on SQL performance
- Add to roadmap for v3.0

**Conditions to accelerate**:
- Community PR with full implementation
- Sponsorship for dedicated development
- GraphQL usage survey showing >30% demand

**Response**: "Excellent suggestion! GraphQL support aligns with our mission, but it's a significant undertaking. We've added this to our v3.0 roadmap. A community PR or sponsorship would accelerate this timeline."

---

## REDIRECT Example: ORM Features

**Issue**: "Add model definitions and migrations like Prisma"

**Analysis**:
- Surface Request: Full ORM functionality
- Underlying Need: Schema management alongside queries
- Job to be Done: Manage database schema in code

**Philosophy Alignment**: 2.0/5 (Low)
- Core Mission: 2 - We're a query builder, not ORM
- Scope: 1 - Schema management is different domain
- Patterns: 2 - Would require fundamental changes
- User Impact: 3 - Some users would benefit

**Feasibility**: High (technically possible)
- Complexity: High but doable
- Breaking: Major - would change core abstraction

**Decision**: REDIRECT
- Good idea, wrong project
- Schema management is a different tool's job

**Alternatives provided**:
1. Use Prisma/TypeORM for schema, our library for complex queries
2. Use our library with raw migrations (Knex, Flyway)
3. Integration guide for hybrid approach

**Response**: "Thank you for the suggestion! Schema management is outside our scope - we focus on query building, not database modeling. Consider Prisma or TypeORM for migrations, and use our library for complex queries they can't express. See our integration guide: /docs/with-prisma.md"

---

## DECLINE Example: Built-in Redis Caching

**Issue**: "Add built-in Redis caching layer to query results"

**Analysis**:
- Surface Request: Integrate Redis caching into core
- Underlying Need: Faster repeated queries
- Job to be Done: Cache query results automatically

**Philosophy Alignment**: 2.0/5 (Low)
- Core Mission: 2 - Caching is app concern, not query building
- Scope: 1 - Runtime infrastructure, not our domain
- Patterns: 2 - We don't manage external connections
- User Impact: 3 - Useful for some, not universal

**Feasibility**: Low
- Complexity: High - connection management, TTL, invalidation
- Breaking: None - would be additive
- Maintenance: High - Redis version compat, security patches

**Decision**: DECLINE
- Crosses boundary from query library to infrastructure
- Would set precedent (Memcached? In-memory?)
- High maintenance burden for non-core feature

**What we offer instead**:
1. Middleware hooks for custom caching
2. Query fingerprinting for cache keys
3. Example recipes for Redis/Memcached integration

**Response**: "After careful consideration, built-in caching falls outside our scope. We focus on query building, not runtime infrastructure. However, we provide: (1) middleware hooks for wrapping queries, (2) `query.fingerprint()` for cache keys, (3) recipes at /docs/caching.md. Would these work for your use case?"

---

## Pattern Recognition

### Signs pointing to ACCEPT
- Directly serves core mission
- Low complexity, high impact
- No maintenance concerns
- Benefits majority of users

### Signs pointing to ADAPT
- Good underlying idea
- Proposed solution is over-engineered
- Simpler approach achieves same goal
- Can be done without expanding scope

### Signs pointing to DEFER
- Aligned but resource-intensive
- Competes with current priorities
- Would benefit from more community input
- Clear conditions for revisiting

### Signs pointing to REDIRECT
- Good idea, wrong project
- Another tool does this better
- We can provide integration guidance
- Helps user without expanding our scope

### Signs pointing to DECLINE
- Conflicts with core philosophy
- Would set problematic precedent
- High burden, low alignment
- Better alternatives exist elsewhere
