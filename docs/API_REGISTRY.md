# API Registry (Common)
## ConnectHealth Platform

**Centralized API specs. Consumers reference this file to integrate.**

---

## 1. Registry

| App | Base URL | Type |
|-----|----------|------|
| **fit-api** | `/api/v1` | Provider |
| **fit-mobile** | N/A | Consumer |

---

## 2. fit-api Endpoints

### 2.1 Auth (No auth required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Register |
| POST | `/auth/login` | Login |
| POST | `/auth/refresh` | Refresh token |

```json
// POST /auth/register - Request
{ "name": "João", "email": "joao@email.com", "password": "Pass123!" }

// Response 201
{ "data": { "user": { "id": "uuid", "name": "João" }, "tokens": { "accessToken": "jwt", "refreshToken": "jwt", "expiresIn": 900 } } }
```

### 2.2 Profile (Auth required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/profile` | Get profile |
| PATCH | `/profile` | Update profile |
| POST | `/profile/photo` | Upload photo |

### 2.3 Clients (Auth required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/clients` | List (query: search, active, page, size) |
| POST | `/clients` | Create |
| GET | `/clients/:id` | Get by ID |
| PATCH | `/clients/:id` | Update |
| DELETE | `/clients/:id` | Delete |
| POST | `/clients/:id/link` | Link to user |
| POST | `/clients/:id/measurements` | Add measurement |
| GET | `/clients/:id/measurements` | Get measurements |

```json
// POST /clients - Request
{ "name": "Maria", "email": "maria@email.com", "profile": { "birthdate": "1990-05-15", "gender": "FEMALE", "goal": "WEIGHT_LOSS" } }

// Response 201
{ "data": { "id": "uuid", "name": "Maria", "profile": { ... } } }
```

### 2.4 Exercises (Auth required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/exercises` | List (query: search, muscleGroup, equipment) |
| GET | `/exercises/search` | Autocomplete (query: q, limit) |

### 2.5 Plans (Auth required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/plans` | List (query: filter=created\|assigned, clientId, status) |
| POST | `/plans` | Create |
| GET | `/plans/:id` | Get by ID |
| PATCH | `/plans/:id` | Update (owner only) |
| DELETE | `/plans/:id` | Delete (owner only) |
| POST | `/plans/:id/clone` | Clone |
| POST | `/plans/:id/share` | Get share text |

```json
// POST /plans - Request
{ "name": "Treino A", "type": "WORKOUT", "clientId": "uuid", "exercises": [{ "exerciseId": "uuid", "dayNumber": 1, "order": 1, "sets": 4, "reps": "10-12" }] }
```

### 2.6 Dashboard (Auth required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/dashboard` | Get stats |
| GET | `/search` | Global search (query: q) |

### 2.7 Health

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |

---

## 3. Adding New Endpoints

When fit-api exposes new endpoints:
1. Implement in fit-api
2. **Update this file** with spec
3. Consumers (fit-mobile) can then integrate
