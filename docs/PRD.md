# Product Requirements Document
## ConnectHealth Platform

**Version:** 5.0 | **Status:** MVP

---

## 1. Vision

**ConnectHealth** - Platform for health professionals to manage clients and create training plans.

**Core Value:** Reduce workout creation from 30-60min to 5-15min.

---

## 2. Applications

| App | Type | Stack |
|-----|------|-------|
| **fit-api** | Backend | Java 21, Spring Boot, PostgreSQL |
| **fit-mobile** | Mobile | React Native, Expo, NX |

---

## 3. Requirements

### Identity
- FR-001: Sign Up
- FR-002: Sign In
- FR-003: Session persistence
- FR-004: Sign Out
- FR-005: Profile management

### Client
- FR-010: List clients
- FR-011: Create client
- FR-012: View client
- FR-013: Edit client
- FR-014: Delete client
- FR-015: Link to user
- FR-016: Client profile
- FR-017: Weight tracking

### Training
- FR-020: List plans (filter: created/assigned)
- FR-021: Create plan
- FR-022: Add exercises
- FR-023: Reorder exercises
- FR-024: View plan
- FR-025: Edit plan
- FR-026: Delete plan
- FR-027: Clone plan
- FR-028: Share (WhatsApp)
- FR-029: Exercise library

### Dashboard
- FR-030: Stats
- FR-031: Global search
- FR-032: Quick actions

---

## 4. Non-Functional

- API P95 < 300ms
- bcrypt 12 rounds
- JWT (15min access, 7d refresh)

---

## 5. Out of Scope (MVP)

- AI generation
- Services
- Push notifications
- Offline mode
