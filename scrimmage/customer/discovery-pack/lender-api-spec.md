# Keystone Home Lending: Partner Pre-Qualification Verification API

**Version:** 2.3
**Issued to:** Dreamhouse Homes (Partner ID `DREAMHOUSE-0042`)
**Contact:** Monica Feld, Partner Integrations Manager, monica.feld@example.com
**Date:** October 27, 2026

---

## 1. What this API does

The Verification API tells a partner whether a borrower holds an active Keystone
pre-qualification that covers a given purchase price.

- It only reads pre-qualifications the borrower already has with Keystone.
- It does not pull credit and does not create an application.
- It returns one of four results: `VERIFIED`, `INSUFFICIENT`, `NOT_FOUND` or `EXPIRED`.

## 2. Environments

| Environment | Base URL |
|-------------|----------|
| Sandbox | `https://api.sandbox.keystonelending.example` |
| Production | `https://api.keystonelending.example` |

Sandbox and production use different API keys. Sandbox data is test data only.

## 3. Authentication

Every request must send two headers:

| Header | Value |
|--------|-------|
| `X-Api-Key` | Your API key. Keystone sends it to your named technical contact. |
| `X-Partner-Id` | `DREAMHOUSE-0042` |

Keys are secrets. Do not put them in source code, email or chat. Keystone rotates a key
on request within one business day.

All traffic must use TLS 1.2 or higher.

## 4. Endpoint

### `POST /v2/prequal/verify`

**Request headers**

```
Content-Type: application/json
Accept: application/json
X-Api-Key: <your key>
X-Partner-Id: DREAMHOUSE-0042
```

**Request body**

```json
{
  "partnerReference": "OFR-00006",
  "borrower": {
    "firstName": "Priya",
    "lastName": "Raman",
    "email": "priya.raman@example.com"
  },
  "purchasePrice": 950000,
  "loanProgram": "JUMBO",
  "propertyState": "MA"
}
```

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `partnerReference` | string | Yes | Your own reference for this check. 1 to 40 characters. Keystone echoes it back. |
| `borrower.firstName` | string | Yes | 1 to 60 characters. |
| `borrower.lastName` | string | Yes | 1 to 80 characters. |
| `borrower.email` | string | Yes | Valid email address. Keystone matches borrowers on email first, then name. |
| `purchasePrice` | number | Yes | Whole US dollars. Greater than 0. Maximum 10,000,000. |
| `loanProgram` | string | Yes | One of `CONVENTIONAL`, `FHA`, `VA`, `JUMBO`. |
| `propertyState` | string | Yes | Two-letter US state code. Keystone lends in MA, NH and RI. |

Keystone does not verify cash purchases. Do not call the API for them.

**Response: `200 OK`**

```json
{
  "requestId": "kh-7f3a9c21-58e4-4b0d-9a61-2c7d1e0b44f2",
  "partnerReference": "OFR-00006",
  "result": "VERIFIED",
  "approvedPurchasePrice": 1000000,
  "approvalExpires": "2027-01-31",
  "loanOfficer": {
    "name": "Andre Silva",
    "email": "andre.silva@example.com",
    "phone": "617-555-0142"
  },
  "message": "Borrower is pre-qualified for the requested purchase price."
}
```

| Field | Type | Always present | Meaning |
|-------|------|----------------|---------|
| `requestId` | string | Yes | Keystone's ID for this check. Quote it when you contact us. |
| `partnerReference` | string | Yes | Echo of your reference. |
| `result` | string | Yes | See the table below. |
| `approvedPurchasePrice` | number | No | Highest purchase price the borrower is pre-qualified for. Present for `VERIFIED` and `INSUFFICIENT`. |
| `approvalExpires` | string (date, `YYYY-MM-DD`) | No | Last day the pre-qualification is valid. Present for `VERIFIED`, `INSUFFICIENT` and `EXPIRED`. |
| `loanOfficer` | object | No | The borrower's Keystone loan officer. Present unless `NOT_FOUND`. |
| `message` | string | Yes | Plain-English summary. Safe to show to your staff. |

**Results**

| `result` | Meaning |
|----------|---------|
| `VERIFIED` | Active pre-qualification that covers the purchase price. |
| `INSUFFICIENT` | Active pre-qualification, but for less than the purchase price. |
| `NOT_FOUND` | No pre-qualification for this borrower with Keystone. |
| `EXPIRED` | The borrower had a pre-qualification but it has expired. |

A `200` response is a completed check, whatever the result.

## 5. Errors

Errors return this body:

```json
{
  "requestId": "kh-0b51e8d7-1c2a-4f39-8e77-90a3d6c5f1aa",
  "errorCode": "INVALID_FIELD",
  "message": "loanProgram must be one of CONVENTIONAL, FHA, VA, JUMBO.",
  "field": "loanProgram"
}
```

| HTTP status | `errorCode` | Meaning | What to do |
|-------------|-------------|---------|------------|
| 400 | `INVALID_FIELD` | A field is missing or breaks a rule. `field` names it. | Fix the request. Do not retry as is. |
| 400 | `STATE_NOT_SERVED` | Keystone does not lend in `propertyState`. | Do not retry. |
| 401 | `UNAUTHORIZED` | Missing or wrong API key or partner ID. | Check credentials. |
| 429 | `RATE_LIMITED` | Over 60 requests per minute for your partner ID. A `Retry-After` header gives seconds to wait. | Wait, then retry. |
| 500 | `INTERNAL_ERROR` | Problem at Keystone. | Retry later. |
| 503 | `UNAVAILABLE` | Planned maintenance, Sundays 01:00 to 03:00 Eastern. | Retry later. |

Requests time out at Keystone after 10 seconds.

## 6. Sandbox test borrowers

In the sandbox, the result depends only on the borrower email. Any name, price, program and
MA, NH or RI state works.

| Borrower email | Result | `approvedPurchasePrice` |
|----------------|--------|-------------------------|
| `verified.buyer@example.com` | `VERIFIED` | 1,500,000 |
| `insufficient.buyer@example.com` | `INSUFFICIENT` | 400,000 |
| `expired.buyer@example.com` | `EXPIRED` | not returned |
| any other email | `NOT_FOUND` | not returned |

Other sandbox triggers:

| Request | Response |
|---------|----------|
| `propertyState` = `TX` | 400 `STATE_NOT_SERVED` |
| `partnerReference` = `FORCE-429` | 429 `RATE_LIMITED`, `Retry-After: 30` |
| `partnerReference` = `FORCE-503` | 503 `UNAVAILABLE` |

## 7. Limits and terms

- 60 requests per minute per partner ID.
- One request checks one borrower. There is no batch endpoint.
- Keystone keeps request logs for 7 years for compliance.
- Results are for the partner's internal use. Do not show `approvedPurchasePrice` to the
  seller or the seller's agent.
