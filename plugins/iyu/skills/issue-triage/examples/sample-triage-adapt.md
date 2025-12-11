# Sample Triage Report: ADAPT Decision

This is an example of a completed triage report where the issue was adapted to a different implementation approach.

---

## Input

```
/iyu:issue "Add ability to customize all error messages for i18n support"
```

---

## Output

```
================================================================
                    ISSUE TRIAGE REPORT
================================================================
Generated: 2024-12-11T11:45:00Z
Issue: Add ability to customize all error messages for i18n
Source: Direct input
================================================================

[PHASE 1: ISSUE INTAKE]

ISSUE SUMMARY
+------------------+------------------------------------------------+
| Title            | Customize error messages for i18n              |
| Source           | Direct text                                    |
| Requester        | Unknown                                        |
| Labels           | N/A                                            |
+------------------+------------------------------------------------+
| Surface Request  | Make every error string configurable           |
| Underlying Need  | Support non-English users                      |
| Root Cause       | Error handling designed for English-only devs  |
| Mental Model     | Libraries should enable full localization      |
| Use Case         | International applications with localization   |
| Proposed Solution| String configuration for all error messages    |
+------------------+------------------------------------------------+

JOB TO BE DONE
- What: Display errors in user's preferred language
- Why blocked: Hardcoded English strings in library
- Frequency: Common need for international applications
- Prevention: Designing with error codes from start would have helped

[PHASE 2: PHILOSOPHY ALIGNMENT]

PHILOSOPHY ALIGNMENT
+----------------------+-------+----------------------------------------+
| Dimension            | Score | Reasoning                              |
+----------------------+-------+----------------------------------------+
| Core Mission Fit     | 4     | Usability and DX are core priorities   |
| Scope Alignment      | 3     | Borders on application concern         |
| Pattern Consistency  | 3     | Not our current pattern                |
| User Base Impact     | 4     | Benefits growing international base    |
+----------------------+-------+----------------------------------------+
| OVERALL              | 3.5   | Medium - Good idea, needs adaptation   |
+----------------------+-------+----------------------------------------+

KEY CONSIDERATIONS
- Scope expansion: Full string customization is over-engineering
- Responsibility: Message display is typically app responsibility

[PHASE 3: FEASIBILITY REVIEW]

FEASIBILITY ASSESSMENT
+----------------------+---------------+--------------------------------+
| Factor               | Rating        | Details                        |
+----------------------+---------------+--------------------------------+
| Technical Complexity | Medium        | Affects error handling paths   |
| Breaking Changes     | Minor         | If done carefully              |
| Maintenance Burden   | Medium        | New configuration surface      |
| Test Requirements    | Medium        | Test with various locales      |
| Doc Requirements     | Medium        | Document error codes           |
| Dependencies         | No            | None required                  |
+----------------------+---------------+--------------------------------+
| OVERALL FEASIBILITY  | Medium        | Achievable with right approach |
+----------------------+---------------+--------------------------------+

RISKS
- Risk 1: API surface bloat if exposing all strings
- Risk 2: Version compatibility if string keys change

AFFECTED COMPONENTS
- src/errors/: Error class definitions
- src/validation/: Validation error messages
- docs/errors.md: Error code documentation

[PHASE 4: DECISION]

DECISION
+------------------+------------------------------------------------+
| Verdict          | ADAPT                                          |
| Confidence       | High                                           |
+------------------+------------------------------------------------+
| Primary Rationale| Good underlying need (i18n support) but        |
|                  | proposed solution (full customization) is      |
|                  | over-engineered. Error codes are better.       |
+------------------+------------------------------------------------+
| Key Factors      |                                                |
| - Good intent    | i18n support is valuable for users             |
| - Simpler path   | Error codes let apps handle messages           |
| - API stability  | Codes are stable, strings change               |
+------------------+------------------------------------------------+

ADAPTED SOLUTION
Instead of customizing every string:
```javascript
// Current approach (problematic for i18n)
throw new LibraryError("User not found");

// Adapted approach (i18n-friendly)
throw new LibraryError({
  code: "USER_NOT_FOUND",
  context: { id: userId }
});
```

Benefits of adaptation:
1. Apps have full control over message display
2. Error codes are stable across versions
3. Context data enables rich localized messages
4. No bloated configuration API

[PHASE 5: EXECUTION]

EXECUTION SUMMARY
- Status: Completed
- Changes Made:
  - src/errors/base.ts: Added error code support
  - src/errors/codes.ts: Created error code enum
  - src/validation/: Updated to use error codes
- Tests: Added tests for error code consistency
- Documentation: Created docs/error-codes.md

[PHASE 6: STRATEGIC INSIGHT EXTRACTION]

STRATEGIC INSIGHTS (Think 10 from 1)
+----------------------+------------------------------------------------+
| Gap Type             | Finding                                        |
+----------------------+------------------------------------------------+
| Documentation Gap    | No i18n/localization guide in documentation    |
| API Gap              | Error messages not machine-parseable           |
| Example Gap          | No i18n integration example with popular libs  |
| Architecture Gap     | Errors designed for console, not user display  |
+----------------------+------------------------------------------------+

IMPROVEMENT OPPORTUNITIES (informed by this request)
- Create dedicated i18n/localization guide in documentation
- Add example integrating with i18next, react-intl
- Consider adding error severity levels for better UX
- Export error code constants for static analysis

PATTERN ANALYSIS
- Recurring theme: Yes - "Customization" category
- Similar past requests: "Custom validation messages", "Custom logging"
- Fundamental solution: Plugin/adapter architecture for customization points

PREVENTIVE ACTIONS
- FAQ update needed: Yes - "How to handle errors in my language?"
- Error message improvement: Yes - Use codes internally
- Documentation enhancement: Yes - i18n integration guide
- API refinement consideration: Yes - Error context expansion

[PHASE 7: KNOWLEDGE CAPTURE]

KNOWLEDGE CAPTURED
- CLAUDE.md: Added note about error code approach
- FAQ: Added "How to localize error messages?" entry
- ADR: Created ADR-002

ADR (if created):
## ADR-002: Error Codes Over Customizable Strings
- Status: Accepted
- Context: Users need i18n support for error messages
- Decision: Provide error codes, let apps handle messages
- Consequences: Stable API, full i18n flexibility for apps

================================================================
                    RESPONSE DRAFT
================================================================

Thank you for raising i18n support for error messages! This is
valuable feedback, and we understand the challenge of displaying
errors in multiple languages.

We'd like to approach this differently than full string customization:

**Our solution: Error codes with context**

Instead of exposing every string for configuration, we're adding
structured error codes that your application can map to localized
messages:

```javascript
try {
  await library.findUser(id);
} catch (error) {
  if (error.code === 'USER_NOT_FOUND') {
    // Display your localized message
    showError(t('errors.userNotFound', { id: error.context.id }));
  }
}
```

**Why this approach?**
- Your app has full control over message wording and formatting
- Error codes are stable across library versions
- Context data enables rich, dynamic messages
- No bloated configuration API in the library

See the complete error code reference at `/docs/error-codes.md`.

Would this approach work for your i18n needs? We're happy to add
more context data to specific errors if needed.

================================================================
                    QUICK ACTIONS
================================================================
- [x] Post response to issue
- [x] Update CLAUDE.md (if noted above)
- [x] Create follow-up tasks (if ACCEPT/ADAPT)
- [ ] Create i18n integration guide
- [ ] Add i18next/react-intl example
- [ ] Export error codes as constants
================================================================
```
