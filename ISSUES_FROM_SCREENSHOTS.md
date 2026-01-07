# Flutter Web Issues (from `issues/` screenshots)

This document consolidates the issues shown in the screenshots under `issues/` and translates the Bisaya notes to English. Each issue includes reproduction steps, expected vs actual behavior, and implementation notes to make it easier to fix.

## Environment

- Project: Flutter Web (repo: `juan_million`)
- Evidence source: `issues/Screenshot 2026-01-07 *.png`

## Index of issues

- 1. Transfer shows notification but no balance changes
- 2. Popup message uses wrong color (top up)
- 3. Wrong PIN still proceeds (PIN validation not enforced)
- 4. QR icon not clickable / no action
- 5. Data privacy: QR generation view shows points (should be hidden)
- 6. Not accessible / not usable on phone (mobile web)
- 7. Transfer flow wrongly prompts to register (existing account not detected)
- 8. Blank screen after creating Cash Wallet (Business)
- 9. Notifications / recent transactions missing after purchasing points
- 10. Top up credit mismatch (input vs output)
- 11. Success alert shown with wrong color (profile update)
- 12. Page fails to render after back navigation (signup/back button)

---

## 1) Transfer shows notification but no balance changes

- **Screenshot**: `issues/Screenshot 2026-01-07 060445.png`
- **Area**: Business Account -> Wallet Transfer

### Steps to reproduce

- Open **Business Account**.
- Transfer wallet/points to a member.

### Expected behavior

- Sender account should be debited.
- Recipient account should be credited.
- A success notification/toast should be shown after the transaction is confirmed.

### Actual behavior (from screenshot / Bisaya -> English)

- “No debit on the account and also no credit on the recipient, but a notification appears.”

### Impact

- High: Users can’t transfer value reliably; creates trust and accounting issues.

### Implementation notes / likely causes

- Transaction is not being committed (e.g., Firestore transaction not `await`ed or failing silently).
- Only the UI notification is triggered regardless of the backend result.
- Backend write succeeds partially (one write fails) and there’s no rollback.
- Client is writing to the wrong document path / wrong user id.

### Suggested fixes

- Make the transfer function:
  - **Validate inputs** (amount > 0, balance sufficient, recipient exists).
  - **Use an atomic transaction** (Firestore `runTransaction`) for debit+credit+ledger entry.
  - **Await** the transaction and show success toast **only** on success.
  - On error, show an error toast and log the exception.
- Add a transfer ledger record (immutable history) and compute balance from ledger or update balance in the same transaction.

---

## 2) Popup message uses wrong color (top up)

- **Screenshot**: `issues/Screenshot 2026-01-07 060504.png`
- **Area**: Customer -> Top up

### Steps to reproduce

- Login as **Customer**.
- Perform **Top up**.

### Expected behavior

- Popup message color should be **green** (success).

### Actual behavior

- Popup message color is **red**.

### Notes

- Screenshot comment says “Suggestion only”, but it’s still worth standardizing UI meaning:
  - green = success
  - red = error
  - yellow/orange = warning

### Suggested fixes

- Centralize toast/snackbar styling (single helper) and require a `ToastType`/`Severity`:
  - `success` -> green
  - `error` -> red
  - `info` -> blue/gray

---

## 3) Wrong PIN still proceeds (PIN validation not enforced)

- **Screenshot**: `issues/Screenshot 2026-01-07 060512.png`
- **Area**: Business account -> Cash wallet transfer

### Steps to reproduce

- Open **Business account**.
- Register cashier.
- Open **Cash Wallet**.
- Transfer any amount.
- Input wrong password / PIN.

### Expected behavior

- App should block the action and show a prompt like **“Wrong PIN”**.

### Actual behavior

- The flow continues even with a wrong PIN.

### Likely causes

- The PIN check result is not used to gate navigation / transfer.
- Async validation returns after navigation proceeds (missing `await`).
- Validation is being bypassed for certain roles or in web builds.

### Suggested fixes

- Ensure the transfer action is disabled until PIN verification returns success.
- Add an explicit guard:
  - if `!isPinValid` -> show error -> return
- Ensure PIN verification function is awaited and errors are handled.

---

## 4) QR icon not clickable / no action

- **Screenshot**: `issues/Screenshot 2026-01-07 060518.png`
- **Area**: Business -> QR icon (upper right)

### Steps to reproduce

- Open **Business**.
- Click the **QR icon** (upper right corner).

### Expected behavior

- QR icon should open the QR feature (e.g., generate/show QR, scan, etc.).

### Actual behavior

- “Not clickable / No function.”

### Suggested fixes

- Verify the widget has a handler:
  - `IconButton(onPressed: ...)` is not null.
  - If it’s wrapped in custom UI, ensure `GestureDetector`/`InkWell` captures taps.
- On Flutter Web, also ensure:
  - no overlay widget is blocking pointer events
  - correct `MouseRegion`/`Listener` is used if needed

---

## 5) Data privacy: QR generation view shows points (should be hidden)

- **Screenshot**: `issues/Screenshot 2026-01-07 060535.png`
- **Area**: QR generation

### Steps to reproduce

- Open business account or customer account.
- Click **Generate QR**.

### Expected behavior (translated intent)

- It should behave like GCash-style shortcuts: **do not show points/balance** on the QR display.

### Actual behavior

- Points are visible on the QR generation screen.

### Risk / impact

- Medium to high: Balance disclosure can be sensitive.

### Suggested fixes

- Remove/hide points/balance from the QR screen UI.
- If the QR payload contains points/balance, change it to only include a non-sensitive identifier:
  - user id / wallet id / payment token
- If balance must be shown, consider:
  - masking (e.g., show only on explicit “reveal”)
  - a permission toggle

---

## 6) Not accessible / not usable on phone (mobile web)

- **Screenshot**: `issues/Screenshot 2026-01-07 060557.png`
- **Area**: Mobile browser access

### Observed

- The app appears not properly accessible/usable on phone (mobile view).

### Common causes on Flutter Web

- Missing responsive layout handling (fixed widths causing overflow).
- Touch targets too small / overflowed content.
- Viewport meta tag issues (`web/index.html`).
- Web-only navigation assumptions / hover-only interactions.

### Suggested fixes

- Add responsive breakpoints using `LayoutBuilder` / `MediaQuery`.
- Ensure scrollable areas on small screens (`SingleChildScrollView`).
- Verify `web/index.html` has a correct viewport meta tag.
- Audit pages for hard-coded widths and replace with constraints.

---

## 7) Transfer flow wrongly prompts to register (existing account not detected)

- **Screenshot**: `issues/Screenshot 2026-01-07 060605.png`
- **Area**: Business -> Wallet -> Transfer points

### Steps to reproduce

- Open **Business account**.
- Click **Wallet**.
- Try to **Transfer points**.

### Expected behavior

- If an account already exists, the flow should proceed normally.

### Actual behavior (from Bisaya -> English)

- App prompts: “Register staff or register user account.”
- But it should proceed because there is already an existing account.

### Likely causes

- The “exists” check uses the wrong key (email vs uid) or wrong collection.
- Case-sensitivity mismatch (email casing).
- Race condition: account creation not fully written before check.
- Caching/stale auth state.

### Suggested fixes

- Ensure existence checks use the canonical identifier (Firebase `uid`) and consistent collection paths.
- Add logging around the existence query:
  - which collection
  - which document id
  - query results
- If relying on eventual consistency, show a loading state and retry once.

---

## 8) Blank screen after creating Cash Wallet (Business)

- **Screenshot**: `issues/Screenshot 2026-01-07 060613.png`
- **Area**: Business -> Register new account -> Proceed to wallet

### Steps to reproduce

- Open **Business account**.
- Register **New Account**.
- Proceed to **Wallet**.

### Expected behavior

- Should proceed to the next panel/screen (wallet UI).

### Actual behavior (translated)

- After creating the user account, it shows a **blank screen**.

### Likely causes

- Route navigation to a page that expects non-null user data, but receives null.
- Exception thrown during build but not visible (web console only).
- Missing `FutureBuilder`/loading state while fetching wallet info.

### Suggested fixes

- Add guarded loading states:
  - if wallet/user data is null -> show loader and fetch
- Add error UI and log exceptions (especially on web):
  - show fallback error widget instead of blank
- Check browser console logs for red errors.

---

## 9) Notifications / recent transactions missing after purchasing points

- **Screenshot**: `issues/Screenshot 2026-01-07 060631.png`
- **Area**: Customer -> Buy points -> Notifications / Recent transactions

### Steps to reproduce

- Open **Customer account**.
- Buy points.
- Click **Notification** or **Recent transactions**.

### Expected behavior

- Recent transactions should include the purchase.

### Actual behavior (translated)

- “No recent transaction after purchasing points.”
- Comment: “This error still exists.”

### Likely causes

- Purchase flow updates balance but does not write a transaction record.
- Transactions are written but query filter/order is wrong (e.g., wrong `uid`).
- Client reads from a different collection than where server writes.

### Suggested fixes

- Ensure every purchase writes a transaction document:
  - type: purchase
  - amount
  - timestamp
  - uid
- Ensure the recent transactions query filters by uid and sorts by timestamp descending.
- Confirm security rules allow read/write.

---

## 10) Top up credit mismatch (input vs output)

- **Screenshot**: `issues/Screenshot 2026-01-07 060639.png`
- **Area**: Customer -> Points -> Top up

### Steps to reproduce

- Open **Customer account**.
- Click **Points**.
- Top up.

### Expected behavior

- The credited amount should match the selected input (e.g., if selecting 5 slots, credit 5 slots).

### Observed issue (translated)

- “Instead of 5 slots, only 3 slots were credited to the wallet. Mismatch between input and output results.”

### Additional note

- The screenshot also shows “Test Result: 5 slots” and comment “New Account”, which suggests this may be:
  - fixed in newer flow
  - only happening for older accounts
  - intermittent depending on account state

### Suggested fixes

- Verify the mapping logic for top up packages (5 slots vs 3 slots) is consistent.
- If there are legacy accounts, run a one-time migration or handle both schemas.
- Add automated validation:
  - after top up, assert new balance = old balance + credited

---

## 11) Success alert shown with wrong color (profile update)

- **Screenshot**: `issues/Screenshot 2026-01-07 060653.png`
- **Area**: Settings -> Edit profile

### Steps to reproduce

- Open Customer/Business account.
- Click **Settings**.
- Edit Profile.

### Expected behavior

- A **success** alert should be styled as success (green).

### Actual behavior

- “Profile update success alert styled incorrectly” and it appears as red.
- Comment: “It should be green.”

### Suggested fixes

- Same fix as Issue #2: centralize alert/toast styling and ensure success uses green.

---

## 12) Page fails to render after back navigation (signup/back button)

- **Screenshots**:
  - `issues/Screenshot 2026-01-07 060702.png`
  - `issues/Screenshot 2026-01-07 060713.png`
- **Area**: Business panel -> Signup -> Browser/app back button

### Steps to reproduce

- Open **Business panel**.
- Go to **Sign up**.
- After signup, click the **back button**.

### Expected behavior

- UI should navigate back and render correctly.

### Actual behavior

- “UI fails to render after back navigation.”
- Back button scenario is explicitly mentioned in the last screenshot.

### Likely causes (Flutter Web)

- Navigator stack not in sync with browser history.
- Using `Navigator.push`/`pop` without proper web URL strategy.
- State disposed incorrectly; returning to a page with missing state.

### Suggested fixes

- If using a router (recommended for web): ensure routes are URL-driven.
  - e.g., `go_router` / `MaterialApp.router`
- Ensure pages can rebuild from URL/state without relying on in-memory-only state.
- Add `WillPopScope`/`PopScope` handling where needed.

---

## Next steps (if you want me to start fixing)

If you want me to work on resolving these in code, tell me which you want to prioritize (I recommend starting with **#1, #3, #7, #8, #12** because they block core flows). For each selected issue, I’ll:

- Identify the exact screen/service files involved
- Reproduce (as much as possible from code)
- Implement a fix with clear error handling
- Suggest a quick manual test checklist
