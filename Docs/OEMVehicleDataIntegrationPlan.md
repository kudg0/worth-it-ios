# Iteration 3: OEM Vehicle Data Integration

Status: **Deferred — post-legal entity**

This work is intentionally outside the initial product iterations. Do not start a production OEM integration until the entry gates below are met.

## Product Goal

Let a vehicle owner explicitly connect a supported manufacturer account and keep Worth It mileage data up to date without manual odometer entry.

Primary value:

- Automatic odometer snapshots with the source timestamp.
- Optional fuel level, average consumption, EV state of charge, range, charging, and maintenance signals when the vehicle supports them.
- A clear last-sync state and manual fallback when OEM data is stale or unavailable.

## Entry Gates

Start Iteration 3 only after all of the following are true:

- Worth It has an EEA legal entity and the business identity, registration documents, and VAT details required by OEM onboarding.
- The core mileage, trip, expense, and scenario flows are stable and released.
- User demand for automatic mileage sync has been validated.
- A production backend can securely store provider credentials and tokens, receive callbacks/events, and run scheduled synchronization.
- Privacy Policy, Terms, consent copy, deletion/revocation flows, retention rules, and GDPR responsibilities are ready for provider review.
- A recurring per-connected-vehicle data budget is approved.

## Scope

### In scope

- Read-only vehicle data.
- Explicit OEM-hosted owner consent.
- Odometer and source timestamp as the minimum viable signal set.
- Optional fuel/energy, range, consumption, charging, and maintenance signals.
- Capability checks by VIN before promising a signal.
- Disconnect, consent revocation, token expiry, and vehicle-subscription expiry handling.
- Provider-neutral storage so another OEM can be added without changing the product model.

### Out of scope

- Collecting or proxying My BMW, Mercedes-Benz, myAudi, or other OEM passwords.
- Reverse-engineered/private mobile-app endpoints.
- Remote lock/unlock, climate, start, or other vehicle commands.
- Promising real-time data; OEM APIs usually return the latest value already uploaded by the vehicle.
- Promising complete trip or refuelling history before the connection date.
- Inferring fuel purchase price from vehicle telemetry.
- Requesting precise location unless a separately validated feature requires it.

## Delivery Plan

### 3.0 — Validation spike

- Test the free personal BMW CarData Customer API with a real Cyprus VIN.
- Record the exact signals, timestamps, update cadence, ConnectedDrive requirements, and failure states for that VIN.
- Validate whether importing owner-requested EU Data Act exports is useful as a low-cost manual fallback.
- Do not ship the personal BMW client flow as a commercial Worth It integration; BMW labels it personal-use only.

### 3.1 — Provider foundation

- Add a backend-only provider abstraction and normalized signal model.
- Keep provider secrets and tokens off the iOS client.
- Open OEM consent pages from iOS and return only through an approved callback.
- Normalize at least `odometer`, `recordedAt`, `fuelLevel`, `averageConsumption`, `batteryStateOfCharge`, `range`, and `maintenance`.
- Store both ingestion time and OEM source time.
- Make ingestion idempotent by provider, VIN, signal, and source timestamp.
- Reject odometer regressions unless the user explicitly resolves a vehicle replacement or data correction.

### 3.2 — BMW first production integration

- Complete BMW CarData B2B/AOS onboarding.
- Start with one purpose-bound container containing the smallest useful signal set.
- Implement BMW-hosted consent for each VIN and container.
- Use the capability service before enabling automatic sync.
- Prefer REST/events for the initial version; add streaming only if the measured cadence requires it.

### 3.3 — Audi and Volkswagen Group

- Complete ONE Business ID and Volkswagen Group Info Services framework agreement onboarding.
- Use the EU Data Act/Data Hub route rather than private myAudi or brand-app endpoints.
- Validate continuous odometer delivery and data-export fallback on Cyprus vehicles.

### 3.4 — Mercedes-Benz

- Apply for the `Third Party Data Access EU Data Act` product through Mercedes-Benz /developers.
- Confirm Worth It's consumer use case, Cyprus coverage, public-car eligibility, available odometer/consumption signals, commercial terms, and delivery method before implementation.

### 3.5 — Cross-brand provider decision

- Run a production-eligibility spike with High Mobility using real BMW, Audi, and Mercedes-Benz vehicles where possible.
- Compare direct OEM integrations against an aggregator using connection success, VIN coverage, signal availability, source freshness, consent UX, support, minimum commitments, and per-active-vehicle cost.
- Do not select Smartcar for BMW or Mercedes-Benz in Cyprus while its current European partner integrations exclude Cyprus and are primarily BEV/PHEV energy products.
- Use Enode only if Worth It adds an EV charging/energy-specific product direction; it is not the primary ICE ownership-data solution.

## Minimum User Experience

- `Connect vehicle account` explains exactly which data Worth It needs and why.
- The user authenticates only on the OEM/provider domain.
- Worth It shows supported signals before final confirmation.
- Every imported value shows its source and last-updated time.
- Manual mileage entry remains available at all times.
- The user can disconnect the vehicle and request deletion of imported telemetry.
- Stale, expired, revoked, and unsupported states have explicit recovery actions.

## Release Criteria

- Real-VIN verification in Cyprus for every advertised brand and supported powertrain.
- No OEM login credentials pass through Worth It infrastructure.
- Consent, revocation, disconnect, deletion, and token-rotation tests pass.
- Duplicate events and out-of-order timestamps do not create duplicate mileage entries.
- An unavailable provider never blocks manual logging or existing scenario calculations.
- Product copy does not describe OEM data as live unless a contractual and measured SLA supports that statement.
- Location is not requested for the mileage-sync MVP.

## Research Snapshot — 1 August 2026

- [BMW CarData Customer Portal](https://bmw-cardata.bmwgroup.com/customer/public/home): free for personal use, with API and streaming access.
- [BMW CarData overview and supported markets](https://www.bmwgroup.com/en/general/regulations/cardata.html): Cyprus is supported; exact data and cadence depend on the VIN.
- [BMW CarData B2B pricing](https://bmw-cardata.bmwgroup.com/thirdparty/public/car-data/pricing): usage-based REST/events, a monthly clearance cap, paid streaming, and paid historic packages.
- [BMW CarData B2B integration guide](https://bmw-cardata.bmwgroup.com/thirdparty/public/car-data/technical-configuration/api-documentation): EEA-company onboarding, backend credentials, VIN/container consent, capabilities, callbacks, and streaming.
- [Mercedes-Benz EU Data Act instructions](https://www.mercedes-benz.de/passengercars/brand/privacy.html): owner export and third-party onboarding through Mercedes-Benz /developers.
- [Mercedes-Benz Pay As You Drive](https://connectivity.mercedes-benz.com/products/pay-as-you-drive): odometer, timestamp, and trip-boundary position data with owner consent.
- [Volkswagen Group EU Data Act Portal](https://eu-data-act.drivesomethinggreater.com/de/en): owner export and third-party sharing for Audi and other Group brands.
- [Volkswagen Group EU Data Act API](https://drivesomethinggreater.com/developer-hub/api-specifications/EUDA-api-specification): business API for subscribed vehicle data.
- [High Mobility BMW/MINI guide](https://docs.high-mobility.com/oem-guides/bmw-and-mini) and [pricing](https://www.high-mobility.com/pricing): explicit BMW Cyprus coverage and a cross-brand commercial option.
- [Smartcar BMW Energy integration](https://smartcar.com/docs/help/oem-integrations/bmw/energy-integration) and [Mercedes-Benz update](https://smartcar.com/docs/help/oem-integrations/mercedes/whats-new): current partner routes are BEV/PHEV-focused and do not list Cyprus.
- [EU vehicle-data guidance](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A52025XC05026): the EU Data Act covers readily available vehicle data, not a general right to remote vehicle functions.

Revalidate provider products, markets, terms, and pricing before Iteration 3 starts; this market changes quickly.
