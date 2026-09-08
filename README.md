# KAIROS — Field Intelligence for Safer Seas

> **KAIROS** is the on-ground field investigation layer of an AI-enabled oil spill detection and vessel attribution platform, built for the National Technical Research Organisation (NTRO) — Smart India Hackathon 2026.

---

## Monorepo Structure

```
kairos-mobile/
├── mobile/           Flutter application (Android + iOS)
├── mobile-api/       Node.js + TypeScript mobile BFF (Backend for Frontend)
├── context/          PRD, API flow documentation
└── README.md
```

---

## System Architecture

```
Satellite → FastAPI (ML + Drift + AIS + Attribution)
                         ↓
               Node.js mobile-api (Auth, Assignment, Inspection, Evidence)
                         ↓
               Flutter KAIROS App (Offline-first field investigation)
```

The FastAPI backend (existing) handles all computational intelligence. Node.js is the **mobile API gateway** — it owns authentication, officer assignment, field inspection CRUD, evidence management, and sync.

---

## Quick Start

### Prerequisites
- Node.js >= 20.x
- Flutter >= 3.22.x (stable)
- MongoDB >= 7.x (running locally or Atlas)
- Dart >= 3.4.x

---

### Backend (mobile-api)

```bash
cd mobile-api
npm install
cp .env.example .env
# Edit .env with your values
npm run dev
```

API available at: `http://localhost:3000`
Swagger docs: `http://localhost:3000/api-docs`
Health check: `http://localhost:3000/api/v1/health`

---

### Frontend (Flutter)

```bash
cd mobile
flutter pub get
flutter run
```

For Android: `flutter run -d android`
For iOS: `flutter run -d ios`

---

## Demo Credentials

After running the seed script (`npm run seed` in `mobile-api/`):

| Role | Employee ID | Password |
|---|---|---|
| Officer | `OFF-001` | `Demo@1234` |
| Officer | `OFF-002` | `Demo@1234` |
| Supervisor | `SUP-001` | `Demo@1234` |
| Admin | `ADM-001` | `Demo@1234` |

> ⚠️ All demo data is clearly marked `[DEMO DATA]` in the application. Do not use in production.

---

## Environment Variables

See [`mobile-api/.env.example`](./mobile-api/.env.example) for all required configuration.

Key variables:
- `MONGO_URI` — MongoDB connection string
- `JWT_SECRET` — Strong random secret for JWT signing
- `FASTAPI_BASE_URL` — URL of the existing FastAPI backend
- `FILE_STORAGE_MODE` — `local` (default) or `s3` / `gcs` / `cloudinary`

---

## MongoDB Setup

1. Install MongoDB 7.x or use MongoDB Atlas
2. The server creates the `kairos` database automatically
3. Run `npm run seed` to populate demo data
4. Indexes are created automatically on startup

**Collections added by Node.js** (existing FastAPI collections are not modified):
- `users`
- `refresh_tokens`
- `investigation_assignments`
- `field_inspections`
- `field_observations`
- `evidence`
- `audit_logs`
- `sos_events`
- `idempotency_keys`

---

## Map Configuration

By default, the Flutter app uses **OpenStreetMap tiles via `flutter_map`** — no API key required.

To use Google Maps, set in `mobile/lib/core/config/app_config.dart`:
```dart
static const mapProvider = MapProvider.googleMaps;
static const googleMapsApiKey = 'YOUR_KEY';
```

To use Mapbox, set `MAPBOX_ACCESS_TOKEN` in mobile-api `.env` and update `app_config.dart`.

---

## FastAPI Integration

Node.js proxies investigation data from FastAPI via `FastApiClient`. Set:
```
FASTAPI_BASE_URL=http://localhost:8080
```

Required FastAPI endpoints consumed:
- `GET /api/v1/investigations/{id}/full`
- `GET /api/v1/investigations/{id}/timeline`

See [`mobile-api/API.md`](./mobile-api/API.md) for full integration documentation.

---

## File Storage

**MVP Default:** Local disk storage at `./uploads` relative to `mobile-api/`.

The `StorageService` abstraction supports:
- `local` — filesystem (default)
- `s3` — AWS S3 (set `AWS_*` env vars)
- `gcs` — Google Cloud Storage
- `cloudinary` — Cloudinary

---

## Known Limitations (MVP)

1. Push notifications (FCM) are scaffolded but not wired to a production FCM project
2. Map uses OSM tiles — no satellite imagery in the Flutter map layer
3. PDF report generation is a backend stub (returns HTML summary)
4. File storage defaults to local disk — not suitable for multi-instance deployment
5. AIS vessel track rendering on the map uses simplified polylines
6. Audio evidence recording is scaffolded but disabled pending platform permissions review

---

## License

Government / Internal Use — NTRO Smart India Hackathon 2026
