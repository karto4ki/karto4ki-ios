# karto4ki-iOS

**Karto4ki** is an iOS flashcards app inspired by modern learning tools and built to help users retain knowledge more effectively.  
The key differentiator is **AI-assisted content creation**: users can generate high-quality flashcards from learning materials and study them with a structured repetition flow.

---

## Overview

Karto4ki focuses on two core problems:

1. **Turning raw learning materials into structured flashcards quickly**  
2. **Helping users remember information long-term** using progress-aware repetition

The app supports creating personal card libraries, studying by sets, and sharing content with others.

---

## Key Features

### AI-powered flashcard generation
- Generate flashcards from uploaded materials:
  - **PDF / DOC / DOCX / TXT**
  - **Images** (e.g., photos of notes)
- Extract key terms and definitions from text
- Server-side processing to keep the UI responsive (progress indicators included)

### LLM-based question rephrasing
- Rephrases prompts for the same answer to reduce memorization of exact wording
- Improves recall by encouraging understanding over pattern learning

### Spaced repetition
- Progress-aware review scheduling
- Cards marked as “don’t know” appear earlier and more frequently
- Reminder notifications if the user hasn’t practiced for several days

### Flashcard library & organization
- Organize cards into themed folders/sets
- Track learning progress per set

### Sharing & discovery
- Publish sets publicly or keep them private
- Share sets via link and import them into your own library
- Search for public sets created by other users

---

## Authentication

Supports multiple sign-in options:
- Email verification code (6 digits)
- Apple ID
- Google

Includes resend-code flow with a cooldown timer.

---

## Tech Stack (iOS)

- **Swift + UIKit**
- Auto Layout (programmatic UI)
- Client–server architecture
- Networking via REST API
- Background-friendly UI updates for long-running operations (AI generation)

---

## API

The iOS client communicates with a backend that provides:
- Authentication and session management
- User profile and settings
- Flashcard CRUD, tags, search
- AI generation and rephrasing pipeline

---

## Roadmap

- Improved OCR pipeline for handwritten notes
- More study modes (test mode, audio-first learning)
- Advanced analytics (streaks, review history, difficulty tracking)
- Offline-friendly reading and cached sets

---

## Contributing

Issues and PRs are welcome.  
Please follow the existing code style and keep UI changes consistent with the current design system.
