# Gap Analysis: PRD vs Current Implementation

## Status: Phase 1 MVP Complete

**Live at:** https://osn-ai-prep.fly.dev/

---

## What's Implemented (Phase 1 MVP)

| Component | Status | Notes |
|-----------|--------|-------|
| Phoenix Project | ✅ Complete | Elixir 1.19.5, Phoenix 1.8.3 |
| PostgreSQL Database | ✅ Complete | Fly.io managed Postgres |
| User Authentication | ✅ Complete | phx.gen.auth with email/password |
| Problem Schema | ✅ Complete | Bilingual fields (EN/ID) |
| Submission Schema | ✅ Complete | Tracks solved problems |
| MCQ Question Schema | ✅ Complete | Bilingual, 4 options |
| ProblemLive.Index | ✅ Complete | Filters by topic, difficulty, competition |
| ProblemLive.Show | ✅ Complete | Colab link, Mark as Solved |
| DashboardLive | ✅ Complete | Progress by topic/difficulty, rank |
| LeaderboardLive | ✅ Complete | Real-time PubSub updates |
| Seeded Content | ✅ Complete | 22 problems, 10 MCQ questions |
| Fly.io Deployment | ✅ Complete | Singapore region, 2 machines |

---

## Gap Summary by Priority

### P1 - Critical (Stripe & Monetization)
- **User schema missing:** stripe_customer_id, subscription_status, subscription_plan, subscription_ends_at
- **No Stripity Stripe dependency**
- **No Subscriptions context**
- **No Paywall module**

### P2 - High (Core Features)
- **MCQ Practice Mode:** No quiz LiveView, no timed exam, no attempt tracking
- **Bilingual Support:** Gettext not configured, no language toggle, no translations
- **Competition Prep Mode:** No onboarding, no mode selector, no customization
- **Stripe Pages:** No pricing page, checkout, webhook handler

### P3 - Medium (Extended Features)
- **Learning Modules:** No Lesson schema, no lessons UI, no progress tracking
- **Mock Exam System:** No exam schema, no timed exams
- **AI Hints:** No OpenAI integration
- **Only 10 MCQ questions** (need 500+)

### P4 - Low (Polish)
- Mobile optimization review
- Analytics setup
- Email sequences
- Performance audit
- Security review

---

## Beads Task Summary

| Priority | Open | Blocked | Ready |
|----------|------|---------|-------|
| P1 | 5 | 2 | 3 |
| P2 | 20 | 11 | 9 |
| P3 | 22 | 12 | 10 |
| P4 | 6 | 2 | 4 |
| **Total** | **53** | **27** | **26** |

---

## Recommended Execution Order (Ralph Wiggum)

### Sprint 1: Stripe Foundation
```
1. lolososn-s16: Add subscription fields to User schema
2. lolososn-6bh: Add Stripity Stripe dependency
3. lolososn-f9w: Create Subscriptions context
4. lolososn-usy: Create Paywall module
```

### Sprint 2: Stripe Integration
```
5. lolososn-cbc: Create PricingLive page
6. lolososn-bop: Create Checkout controller
7. lolososn-r32: Create Stripe Webhook handler
8. lolososn-e17: Test Stripe integration
```

### Sprint 3: MCQ Practice Mode
```
9. lolososn-iuq: Create McqLive.Index
10. lolososn-3td: Create McqAttempt schema
11. lolososn-qtp: Create McqLive.Quiz
12. lolososn-4zy: Create McqLive.TimedExam
13. lolososn-249: Implement scoring
```

### Sprint 4: Bilingual & Prep Mode
```
14. lolososn-2gt: Setup Gettext
15. lolososn-i5m: Add preferred_language to User
16. lolososn-3vf: Create language toggle
17. lolososn-877: Create PrepMode enum
18. lolososn-phn: Add prep_mode to User
19. lolososn-aas: Create onboarding flow
```

### Sprint 5: Learning & Mock Exams
```
20. lolososn-781: Create Lesson schema
21. lolososn-mtm: Create LessonProgress schema
22. lolososn-v6k: Create LessonLive.Index
23. lolososn-eut: Create MockExam schema
24. lolososn-v1s: Create MockExamLive.Index
```

### Sprint 6: Content & AI
```
25. lolososn-8qa: Seed 500+ MCQ questions
26. lolososn-94x: Add learning content
27. lolososn-09p: Add Req dependency
28. lolososn-r67: Create AI hints controller
```

### Sprint 7: Polish & Launch
```
29. lolososn-bzg: Create landing page
30. lolososn-mbw: Mobile optimization
31. lolososn-4ke: Setup analytics
32. lolososn-bv9: Security audit
```

---

## Quick Commands

```bash
# Check what's ready to work on
bd ready

# Start working on a task
bd update <task-id> --status=in_progress

# Complete a task
bd close <task-id>

# See blocked tasks
bd blocked

# Sync changes
bd sync
```

---

## Files to Reference

- **PRD:** `/osn_ai_prep/PRD.md` (full specifications)
- **Current Schemas:** `lib/osn_ai_prep/problems/*.ex`, `lib/osn_ai_prep/mcq/*.ex`
- **Current LiveViews:** `lib/osn_ai_prep_web/live/*.ex`
- **Router:** `lib/osn_ai_prep_web/router.ex`
