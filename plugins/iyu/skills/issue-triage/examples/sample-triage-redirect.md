# Sample Triage Report: REDIRECT Decision

This is an example of a completed triage report where the issue was redirected to a more appropriate solution.

---

## Input

```
/iyu:issue "Add model definitions and migrations like Prisma/TypeORM"
```

---

## Output

```
================================================================
                    ISSUE TRIAGE REPORT
================================================================
Generated: 2024-12-11T15:30:00Z
Issue: Add model definitions and migrations like Prisma
Source: Direct input
================================================================

[PHASE 1: ISSUE INTAKE]

ISSUE SUMMARY
+------------------+------------------------------------------------+
| Title            | Add ORM features (models and migrations)       |
| Source           | Direct text                                    |
| Requester        | Unknown                                        |
| Labels           | N/A                                            |
+------------------+------------------------------------------------+
| Surface Request  | Full ORM functionality like Prisma/TypeORM     |
| Underlying Need  | Schema management alongside query building     |
| Root Cause       | Unclear library boundaries in user's mind      |
| Mental Model     | One tool should handle all database operations |
| Use Case         | Define models in code, run migrations          |
| Proposed Solution| Add model definitions and migration system     |
+------------------+------------------------------------------------+

JOB TO BE DONE
- What: Manage database schema in code alongside queries
- Why blocked: Library focuses on queries, not schema
- Frequency: Common desire to consolidate database tools
- Prevention: Clearer positioning on library scope in README

[PHASE 2: PHILOSOPHY ALIGNMENT]

PHILOSOPHY ALIGNMENT
+----------------------+-------+----------------------------------------+
| Dimension            | Score | Reasoning                              |
+----------------------+-------+----------------------------------------+
| Core Mission Fit     | 2     | We're a query builder, not ORM         |
| Scope Alignment      | 1     | Schema management is different domain  |
| Pattern Consistency  | 2     | Would require fundamental changes      |
| User Base Impact     | 3     | Some users would benefit               |
+----------------------+-------+----------------------------------------+
| OVERALL              | 2.0   | Low - Outside our core scope           |
+----------------------+-------+----------------------------------------+

KEY CONSIDERATIONS
- Scope expansion: Would fundamentally change project identity
- Responsibility: Schema management is a different tool's job

[PHASE 3: FEASIBILITY REVIEW]

FEASIBILITY ASSESSMENT
+----------------------+---------------+--------------------------------+
| Factor               | Rating        | Details                        |
+----------------------+---------------+--------------------------------+
| Technical Complexity | High          | Entirely new subsystem         |
| Breaking Changes     | Major         | Would change core abstraction  |
| Maintenance Burden   | Very High     | Two tools in one               |
| Test Requirements    | Very High     | Migration testing is complex   |
| Doc Requirements     | Very High     | Essentially two products       |
| Dependencies         | Yes           | Schema parsing, diff tools     |
+----------------------+---------------+--------------------------------+
| OVERALL FEASIBILITY  | High*         | *Technically possible but wrong|
+----------------------+---------------+--------------------------------+

*Note: High feasibility doesn't mean we should do it - this is
technically achievable but philosophically misaligned.

RISKS
- Risk 1: Becoming "jack of all trades, master of none"
- Risk 2: Maintenance burden of competing with Prisma/TypeORM
- Risk 3: Confusing existing users about project scope

AFFECTED COMPONENTS
- Would require entirely new architecture
- Core abstraction would change
- Documentation would double

[PHASE 4: DECISION]

DECISION
+------------------+------------------------------------------------+
| Verdict          | REDIRECT                                       |
| Confidence       | High                                           |
+------------------+------------------------------------------------+
| Primary Rationale| Good idea, wrong project. Schema management is |
|                  | a different tool's job. Better alternatives    |
|                  | exist that we integrate well with.             |
+------------------+------------------------------------------------+
| Key Factors      |                                                |
| - Scope boundary | We excel at query building, not modeling       |
| - Better options | Prisma, TypeORM, Drizzle do this excellently   |
| - Integration    | These tools work great alongside us            |
+------------------+------------------------------------------------+

WHY WE MAINTAIN THIS BOUNDARY
1. Focus enables excellence - we're great at queries because we focus
2. Ecosystem collaboration - ORMs handle schema, we handle queries
3. User choice - different projects need different approaches
4. Maintenance reality - can't compete with full-time ORM teams

ALTERNATIVES PROVIDED
1. **Prisma + Our Library**: Use Prisma for schema/migrations, our
   library for complex queries Prisma can't express
2. **Drizzle + Our Library**: Drizzle is lightweight, pairs naturally
3. **TypeORM + Our Library**: For existing TypeORM projects
4. **Raw migrations**: Use Flyway/Liquibase/Knex migrations directly

[PHASE 5: EXECUTION]

EXECUTION: Skipped (Decision: REDIRECT)

[PHASE 6: STRATEGIC INSIGHT EXTRACTION]

STRATEGIC INSIGHTS (Think 10 from 1)
+----------------------+------------------------------------------------+
| Gap Type             | Finding                                        |
+----------------------+------------------------------------------------+
| Documentation Gap    | No clear "What we are/aren't" in README        |
| API Gap              | No easy integration hooks for ORMs             |
| Example Gap          | No Prisma/TypeORM integration examples         |
| Architecture Gap     | Users expect all-in-one database tools         |
+----------------------+------------------------------------------------+

IMPROVEMENT OPPORTUNITIES (redirecting doesn't mean ignoring)
- Create prominent "What this library is NOT" section
- Build official integration guides for Prisma, Drizzle, TypeORM
- Add code examples showing hybrid ORM + query builder usage
- Consider partnership or endorsement strategy with ORMs
- Blog post: "Why we focus on queries (and how to combine with ORMs)"

PATTERN ANALYSIS
- Recurring theme: Yes - "All-in-one database tool" category
- Similar past requests: "Add connection pooling", "Add query logging"
- Fundamental solution: Clear positioning + excellent integration guides

PREVENTIVE ACTIONS
- FAQ update needed: Yes - "Why don't you have models/migrations?"
- Error message improvement: No
- Documentation enhancement: Yes - Integration guides, scope clarity
- API refinement consideration: No - This is a scope boundary, not API gap

[PHASE 7: KNOWLEDGE CAPTURE]

KNOWLEDGE CAPTURED
- CLAUDE.md: Clarified scope boundary (query builder vs ORM)
- FAQ: Added "Why don't you have model definitions?"
- ADR: Not applicable

DOCUMENTATION CREATED
```markdown
## Integration Guide: Using with ORMs

Our library complements ORMs - use each for what they do best:

### Prisma
- Prisma: Models, migrations, simple queries
- Our lib: Complex analytical queries, dynamic filters

### Example
// schema.prisma defines your models
// Use Prisma for CRUD:
await prisma.user.create({ ... });

// Use our library for complex queries:
const analytics = await ourLib
  .select('users')
  .join('orders')
  .aggregate(['sum(amount)', 'count(*)'])
  .groupBy('user_id')
  .having('count(*) > 10')
  .execute();
```

================================================================
                    RESPONSE DRAFT
================================================================

Thank you for this suggestion! I understand the appeal of having
everything in one tool - models, migrations, and queries together.

**Why this falls outside our scope:**

We focus specifically on query building - constructing complex,
type-safe queries that other tools struggle with. Schema management
(models and migrations) is a different domain with its own complexity:

- Schema diffing and migration generation
- Entity relationship mapping
- Connection pooling and lifecycle
- Cross-database DDL differences

Excellent tools already solve these problems:
- **Prisma** - Best-in-class DX and type safety
- **Drizzle** - Lightweight, SQL-like approach
- **TypeORM** - Full ORM with decorators

**The good news: we work great together!**

Many teams use a hybrid approach:
- ORM for models, migrations, and simple CRUD
- Our library for complex analytical queries

See our integration guides:
- [Using with Prisma](/docs/integrations/prisma.md)
- [Using with Drizzle](/docs/integrations/drizzle.md)
- [Using with TypeORM](/docs/integrations/typeorm.md)

**Example hybrid approach:**

```javascript
// Prisma handles your models and migrations
const user = await prisma.user.create({ data: {...} });

// Our library handles complex queries
const insights = await queryBuilder
  .select(['user_id', 'sum(amount)', 'count(*)'])
  .from('orders')
  .join('users', 'users.id = orders.user_id')
  .where('created_at > ?', lastMonth)
  .groupBy('user_id')
  .having('count(*) > 5')
  .orderBy('sum(amount) DESC')
  .execute();
```

Would this hybrid approach work for your use case? Happy to help
you set up the integration!

================================================================
                    QUICK ACTIONS
================================================================
- [x] Post response to issue
- [x] Update CLAUDE.md (if noted above)
- [ ] Create follow-up tasks (if ACCEPT/ADAPT)
- [x] Create/update integration guides
- [ ] Add "What we are/aren't" section to README
- [ ] Create Prisma/Drizzle/TypeORM integration examples
- [ ] Consider blog post on library positioning
================================================================
```
