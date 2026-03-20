# AGENTS.md

## Repository Purpose

This repository contains the mobile application for the Dolmasoft BabyCare project.

This repository is mobile-only.

## Fixed Stack

- Flutter
- Dart
- Riverpod

Do not propose or use alternative mobile stacks for implementation in this repository.

Invalid stacks for this repository include:

- Java
- Spring Boot
- ASP.NET Core
- PostgreSQL
- TypeScript
- Node.js
- Express
- NestJS
- Python
- Flask
- Django
- Go
- PHP
- Ruby
- React Native
- Kotlin Multiplatform

If stale references to any of the above stacks exist in repository files, treat them as stale unless the task description explicitly confirms them.

## Flutter / SDK Rules

Before making implementation decisions, inspect repository files.

Follow Flutter / Dart version selection in this order:

1. `.fvmrc`
2. `.flutter-version`
3. `pubspec.yaml`
4. CI / workflow files
5. repository documentation

If a repository version file exists, it is authoritative.

Do not change Flutter version, Dart version, or mobile stack unless the task description explicitly requires it.

## State Management Rules

Riverpod is the fixed state management approach unless the task description explicitly requires otherwise.

Reuse existing project structure, naming, routing, and state-management patterns where possible.

Do not introduce a new architecture or state management pattern if the repository already has an established one.

## Backend Contract Rules

The backend API contract is provided through the task description.

Use backend integration sources in this order:

1. `API CONTRACT`
2. `API MOBILE HANDOFF`
3. `ARCHITECTURE`
4. `DELIVERY SCOPE`
5. `PRODUCT SCOPE`
6. `PROJECT DEFAULTS`

Do not inspect, modify, or rely on `dolmasoft-babycare-api` for code changes.

Status codes, error codes, payload fields, token handling, and authenticated-state behavior must match the provided backend contract exactly.

Do not invent fallback backend behavior.

If required backend behavior is missing from the provided source-of-truth sections, treat it as a blocker.

## Task Source of Truth

When implementing a task, use the task description as the primary source of truth.

Follow task sections in this order:

1. `API CONTRACT`
2. `API MOBILE HANDOFF`
3. `ARCHITECTURE`
4. `DELIVERY SCOPE`
5. `PRODUCT SCOPE`
6. `PROJECT DEFAULTS`

If repository contents conflict with the task description, the task description wins.

## Implementation Rules

- Implement only approved scope.
- Do not expand scope.
- Keep changes minimal, clean, and compilable.
- Follow the provided API contract and Mobile Contract Notes strictly.
- Handle loading, success, validation error, and failure states clearly.
- Reuse existing mobile UI, navigation, and state patterns where possible.
- Do not redesign unrelated screens or flows.
- Add or update tests when needed.
- Ensure the project builds successfully before opening a PR.
- Use Conventional Commits.
- Open PR into `development`.
- Do not simulate completion.
- Do not leave placeholder PR links.

## Execution Rules

Proceed without asking questions unless there is a true blocker.

A true blocker is only one of these:

- repository access missing
- cannot create branch
- cannot push
- cannot open PR
- required task sections are missing
- direct conflict between required source-of-truth sections prevents safe implementation
- required backend contract information is missing and safe implementation would require guessing

If no true blocker exists, implement directly.

## Reporting Rules

If stale repository references are detected, ignore them for implementation and report them clearly in the final Notes / Assumptions output.

When reporting final work, include:

- actual branch name
- commit messages
- PR title and PR link
- concise implementation summary
- test instructions
- notes / assumptions