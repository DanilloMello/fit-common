# ConnectHealth Coding Guidelines

## General Principles

1. **Domain-Driven Design (DDD)**: Follow DDD principles in all modules
2. **Single Responsibility**: Each class/function should have one clear purpose
3. **Testability**: Write testable code with clear dependencies
4. **Documentation**: Document complex business logic and API contracts
5. **Consistency**: Follow established patterns within each project

---

## fit-api (Java/Spring Boot) Guidelines

### Package Structure
```
com.connecthealth.{module}/
├── domain/           # Pure domain logic, no framework dependencies
├── application/      # Use cases, @Transactional only here
├── infrastructure/   # JPA entities, repositories, external clients
└── presentation/     # REST controllers
```

### Naming Conventions
- **Entities**: `User`, `Client`, `Plan` (singular nouns)
- **Value Objects**: `Email`, `PhoneNumber`, `Address`
- **Use Cases**: `CreateClientUseCase`, `UpdatePlanUseCase`
- **Controllers**: `ClientController`, `PlanController`
- **Repositories**: `ClientRepository`, `PlanRepository`
- **DTOs**: `CreateClientRequest`, `ClientResponse`

### Code Rules
1. **@Transactional on Use Cases only**, never on repositories
2. **Events published within transaction** for consistency
3. **Repository methods return domain entities**, not JPA entities
4. **Controllers use DTOs**, never expose domain entities directly
5. **No business logic in controllers** - delegate to use cases
6. **Use Optional<T>** for nullable return values
7. **Validate at boundaries** - controllers and domain entities

### API Contract Rules
1. **RESTful conventions**:
   - `POST /clients` - create
   - `GET /clients/{id}` - retrieve
   - `PUT /clients/{id}` - update
   - `DELETE /clients/{id}` - delete
2. **HTTP Status Codes**:
   - `200 OK` - successful GET/PUT
   - `201 Created` - successful POST
   - `204 No Content` - successful DELETE
   - `400 Bad Request` - validation error
   - `404 Not Found` - resource not found
   - `500 Internal Server Error` - unexpected error
3. **Update API_REGISTRY.md** when adding/changing endpoints
4. **Versioning**: `/api/v1/` prefix for all endpoints

### Testing Standards
- **Unit tests**: Test domain logic in isolation
- **Integration tests**: Test use cases with real database (Testcontainers)
- **Controller tests**: Use `@WebMvcTest` with mocked use cases
- **Minimum coverage**: 80% for domain and application layers

### Code Quality
- **Google Java Format**: Use consistent formatting
- **SonarLint**: No critical or blocker issues
- **No commented code**: Remove unused code
- **No System.out.println**: Use proper logging (SLF4J)

---

## fit-mobile (React Native/Expo) Guidelines

### Project Structure
```
libs/{module}/
├── domain/           # Entities, value objects
├── application/      # Zustand stores, repository ports
├── infrastructure/   # API clients (axios)
└── ui/               # React hooks, components
```

### Naming Conventions
- **Components**: `ClientList`, `PlanCard` (PascalCase)
- **Hooks**: `useAuth`, `useClients` (camelCase, use prefix)
- **Stores**: `authStore`, `clientStore` (camelCase, store suffix)
- **Types**: `User`, `Client` (PascalCase, match backend)
- **Files**: `client-list.tsx`, `use-auth.ts` (kebab-case)

### Code Rules
1. **Consume APIs via API_REGISTRY.md** - never guess endpoints
2. **TanStack Query for server state** (cache, refetch, optimistic updates)
3. **Zustand for client state** (auth, UI state)
4. **TypeScript strict mode** - no `any` types
5. **Functional components** with hooks, no class components
6. **Props interfaces** for all components
7. **Error boundaries** for graceful error handling

### Component Guidelines
1. **Small, focused components** - single responsibility
2. **Prop drilling limit**: Max 2 levels, then use context/store
3. **Conditional rendering**: Use early returns, not nested ternaries
4. **Event handlers**: Prefix with `handle` - `handlePress`, `handleSubmit`
5. **Accessibility**: Add `accessibilityLabel` for all interactive elements

### State Management
1. **Local state (useState)**: UI state within component
2. **Global state (Zustand)**: Auth, user profile, app settings
3. **Server state (React Query)**: API data with caching
4. **Form state**: Use React Hook Form for complex forms

### API Integration
1. **Base URL from environment**: `process.env.EXPO_PUBLIC_API_URL`
2. **Axios interceptors**: Add auth token, handle errors
3. **Error handling**: Show user-friendly messages
4. **Loading states**: Always show loading UI during fetches
5. **Optimistic updates**: Use React Query mutations with optimistic updates

### Testing Standards
- **Unit tests**: Test hooks and utility functions
- **Component tests**: Use React Testing Library
- **Integration tests**: Test user flows (login → dashboard)
- **Minimum coverage**: 70% for domain and application layers

### Code Quality
- **ESLint**: Fix all errors before commit
- **Prettier**: Auto-format on save
- **TypeScript strict**: No type errors
- **No console.log**: Use proper debugging or remove

---

## Cross-Project Rules

### API Contract Synchronization
1. **fit-api** implements endpoint → updates `API_REGISTRY.md`
2. **fit-mobile** reads `API_REGISTRY.md` → implements client
3. **Never guess endpoints** - always check registry first
4. **Types must match**: Backend DTOs ↔ Frontend types

### Documentation Updates
When changing:
- **Entities/Enums** → Update `DOMAIN_SPEC.md`
- **API endpoints** → Update `API_REGISTRY.md`
- **Requirements** → Update `PRD.md`
- **Roadmap** → Update `SPRINT_PLAN.md`

### Commit Message Format
```
type(scope): short description

Longer description if needed

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Types**: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`
**Scopes**: `identity`, `client`, `training`, `shared`, `api`, `mobile`

### Branch Naming
- `feature/module-name` - new features
- `fix/bug-description` - bug fixes
- `refactor/component-name` - refactoring
- `test/test-description` - test additions

---

## Pre-Push Checklist

### fit-api
- [ ] All tests passing (`./gradlew test`)
- [ ] Build successful (`./gradlew build`)
- [ ] Code formatted (Google Java Format)
- [ ] SonarLint clean (no critical/blocker issues)
- [ ] API_REGISTRY.md updated if endpoints changed
- [ ] No System.out.println or commented code

### fit-mobile
- [ ] All tests passing (`nx test`)
- [ ] Type check clean (`tsc --noEmit`)
- [ ] Lint clean (`nx lint`)
- [ ] Build successful (`nx build`)
- [ ] No console.log or debugging code
- [ ] API calls match API_REGISTRY.md

---

## Enforcement

These guidelines are enforced via:
1. **Pre-push hooks** - Block pushes that violate rules
2. **PR templates** - Checklist for reviewers
3. **CI/CD pipelines** - Automated validation on PRs
4. **Code reviews** - Human verification of best practices
