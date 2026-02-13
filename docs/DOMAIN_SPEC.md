# Domain Specification (Common)
## ConnectHealth Platform

**Shared across all applications**

---

## 1. Bounded Contexts

| Module | Responsibility | Owner App |
|--------|----------------|-----------|
| `identity` | Authentication, user profile | fit-api |
| `client` | Client management, measurements | fit-api |
| `training` | Plans, exercises | fit-api |

---

## 2. Entities

### 2.1 User

| Field | Type | Required |
|-------|------|----------|
| id | UUID | Yes |
| name | string | Yes |
| email | string (unique) | Yes |
| phone | string | No |
| photoUrl | string | No |
| cref | string | No |
| createdAt | datetime | Yes |

### 2.2 Client

| Field | Type | Required |
|-------|------|----------|
| id | UUID | Yes |
| ownerId | UUID (ref: User) | Yes |
| userId | UUID (ref: User) | No |
| name | string | Yes |
| email | string | No |
| phone | string | No |
| notes | string | No |
| active | boolean | Yes (default: true) |
| profile | ClientProfile | No |
| createdAt | datetime | Yes |

### 2.3 ClientProfile (Value Object)

| Field | Type |
|-------|------|
| birthdate | date |
| gender | Gender |
| heightCm | int |
| currentWeightKg | decimal |
| goal | Goal |
| experienceLevel | ExperienceLevel |
| limitations | string |
| availableDays | int |

### 2.4 Measurement

| Field | Type | Required |
|-------|------|----------|
| id | UUID | Yes |
| clientId | UUID | Yes |
| weightKg | decimal | Yes |
| measuredAt | date | Yes |
| notes | string | No |

### 2.5 Exercise

| Field | Type | Required |
|-------|------|----------|
| id | UUID | Yes |
| name | string | Yes |
| muscleGroup | MuscleGroup | Yes |
| equipment | Equipment | Yes |
| description | string | No |

### 2.6 Plan

| Field | Type | Required |
|-------|------|----------|
| id | UUID | Yes |
| ownerId | UUID | Yes |
| clientId | UUID | No |
| name | string | Yes |
| type | PlanType | Yes |
| description | string | No |
| status | PlanStatus | Yes |
| totalDays | int | Yes |
| createdAt | datetime | Yes |

### 2.7 PlanExercise

| Field | Type | Required |
|-------|------|----------|
| id | UUID | Yes |
| planId | UUID | Yes |
| exerciseId | UUID | Yes |
| dayNumber | int | Yes |
| order | int | Yes |
| sets | int | Yes |
| reps | string | Yes |
| load | string | No |
| restSeconds | int | No |
| notes | string | No |

---

## 3. Enums

```
Gender: MALE | FEMALE | OTHER
Goal: HYPERTROPHY | WEIGHT_LOSS | STRENGTH | CONDITIONING | HEALTH
ExperienceLevel: BEGINNER | INTERMEDIATE | ADVANCED
PlanType: WORKOUT | PERIODIZATION
PlanStatus: DRAFT | ACTIVE | ARCHIVED
MuscleGroup: CHEST | BACK | SHOULDERS | BICEPS | TRICEPS | FOREARMS | CORE | QUADRICEPS | HAMSTRINGS | GLUTES | CALVES | FULL_BODY
Equipment: BARBELL | DUMBBELL | CABLE | MACHINE | BODYWEIGHT | KETTLEBELL | BAND | OTHER
```

---

## 4. Business Rules

- Client belongs to an owner (User who created it)
- Client can optionally be linked to a User account
- Only owner can edit/delete a plan
- Plan filters: "Created by me" (ownerId) / "Assigned to me" (client.userId)

---

## 5. API Standards

### Headers
```
Authorization: Bearer <access_token>
```

### Response
```json
{ "data": { }, "meta": { "timestamp": "..." } }
```

### Error
```json
{ "error": { "code": "...", "message": "...", "details": { } } }
```

### Error Codes
| Code | HTTP |
|------|------|
| VALIDATION_ERROR | 400 |
| UNAUTHORIZED | 401 |
| FORBIDDEN | 403 |
| NOT_FOUND | 404 |
