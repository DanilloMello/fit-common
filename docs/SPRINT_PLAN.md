# Sprint Plan
## ConnectHealth Platform

**Total:** ~30 days

---

## Roadmap

| Phase | Days | Focus |
|-------|------|-------|
| Sprint 0 | 4 | Foundation |
| Sprint 1 | 4 | Identity |
| Sprint 2-3 | 8 | Client |
| Sprint 4-5 | 10 | Training |
| Sprint 6 | 4 | Polish |

---

## Sprint 0: Foundation

| fit-api | fit-mobile |
|------------|------------|
| Gradle multi-module | NX workspace |
| Docker Compose | Library structure |
| Health endpoint | API client |

---

## Sprint 1: Identity

| fit-api | fit-mobile |
|------------|------------|
| User entity | Login screen |
| Auth use cases | Register screen |
| JWT | Auth store |

**DB:** V1: users

---

## Sprint 2-3: Client

| fit-api | fit-mobile |
|------------|------------|
| Client entity | Client list |
| CRUD use cases | Client profile |
| Measurement entity | Client form |
| Dashboard endpoint | Home screen |

**DB:** V2: clients, V3: measurements

---

## Sprint 4-5: Training

| fit-api | fit-mobile |
|------------|------------|
| Exercise entity | Plan list |
| Plan entity | Plan detail |
| Clone/Share use cases | Plan form |

**DB:** V4-V7: exercises, plans, plan_exercises

---

## Sprint 6: Polish

| fit-api | fit-mobile |
|------------|------------|
| Profile endpoints | Profile screen |
| Deploy | Settings |
| | Beta build |
