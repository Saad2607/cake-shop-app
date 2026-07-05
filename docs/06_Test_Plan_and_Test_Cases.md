# Test Plan and Test Cases

## Cake Online Shopping Android App

**Document ID:** TEST-CAKE-001  
**Version:** 1.0  
**Date:** June 2026

---

## 1. Test Plan Overview

### 1.1 Purpose
Define testing strategy, scope, resources, and schedule to verify the Cake Online Shopping Android App meets requirements in the SRS.

### 1.2 Scope
- Unit testing (ViewModels, Repositories, utilities)
- Integration testing (Room DAO, Repository + Database)
- UI testing (Espresso — critical flows)
- Manual system testing (full user journeys)
- User Acceptance Testing (UAT) with sample users

### 1.3 Out of Scope
- Load/stress testing of backend (no backend in v1)
- Penetration testing
- iOS compatibility

---

## 2. Test Strategy

| Level | Tool | Focus |
|-------|------|-------|
| Unit | JUnit 4/5, Mockito | Business logic, validators |
| Integration | AndroidX Test, Room in-memory DB | DAO queries, Repository |
| UI | Espresso | Login, browse, cart, checkout |
| Manual | Test case checklist | Exploratory, UX, edge cases |
| UAT | Feedback form | Real user scenarios |

### 2.1 Entry Criteria
- Feature complete for test cycle
- Build installs on test device/emulator
- Test data seeded in database

### 2.2 Exit Criteria
- ≥ 90% of high-priority test cases passed
- No critical or high-severity open bugs
- All blockers resolved

---

## 3. Test Environment

| Item | Specification |
|------|---------------|
| Emulator | Pixel 6, API 34 |
| Physical device | Android 10+ phone |
| Min API | API 24 emulator spot check |
| Build | Debug APK with test data |
| Test accounts | customer@test.com / test123, admin@cakeshop.com / admin123 |

---

## 4. Test Schedule

| Phase | Week | Activities |
|-------|------|------------|
| Unit tests | 11 | Write & run JUnit tests |
| Integration | 11–12 | DAO and Repository tests |
| UI automation | 12 | Espresso scripts |
| System manual | 12 | Full regression checklist |
| UAT | 12–13 | 5 users, feedback collection |
| Bug fix retest | 13 | Verify fixes |

---

## 5. Test Cases

### 5.1 Authentication

| ID | Test Case | Steps | Expected Result | Priority |
|----|-----------|-------|-----------------|----------|
| TC-AUTH-01 | Valid registration | 1. Open Register<br>2. Enter valid details<br>3. Submit | Account created, success message | High |
| TC-AUTH-02 | Duplicate email | Register with existing email | Error: "Email already registered" | High |
| TC-AUTH-03 | Invalid email format | Enter "notanemail" | Validation error on email field | High |
| TC-AUTH-04 | Short password | Password "123" | Error: min 6 characters | High |
| TC-AUTH-05 | Valid login | Enter correct credentials | Navigate to Home | High |
| TC-AUTH-06 | Invalid login | Wrong password | Error message, stay on login | High |
| TC-AUTH-07 | Logout | Tap logout in profile | Return to login, session cleared | Medium |
| TC-AUTH-08 | Empty fields | Submit login with empty fields | Validation errors shown | Medium |

### 5.2 Product Catalog

| ID | Test Case | Steps | Expected Result | Priority |
|----|-----------|-------|-----------------|----------|
| TC-CAT-01 | Display catalog | Open app after login | Cake list with images and prices | High |
| TC-CAT-02 | Category filter | Tap "Birthday" category A chip | Only birthday cakes shown | High |
| TC-CAT-03 | Search by name | Search "Chocolate" | Matching cakes displayed | High |
| TC-CAT-04 | Cake detail | Tap a cake card | Detail page with full info | High |
| TC-CAT-05 | Out of stock | Open out-of-stock cake | Add button disabled, label shown | Medium |
| TC-CAT-06 | Empty search | Search "xyznonexistent" | Empty state message | Low |

### 5.3 Shopping Cart

| ID | Test Case | Steps | Expected Result | Priority |
|----|-----------|-------|-----------------|----------|
| TC-CART-01 | Add to cart | Select options, tap Add | Item appears in cart | High |
| TC-CART-02 | Update quantity | Increase qty to 3 in cart | Subtotal updates correctly | High |
| TC-CART-03 | Remove item | Swipe/delete item | Item removed, total recalculated | High |
| TC-CART-04 | Empty cart | Remove all items | Empty cart message | Medium |
| TC-CART-05 | Cart persistence | Add item, close app, reopen | Cart items still present | Medium |
| TC-CART-06 | Custom message | Add 51-char message | Truncated or validation error | Low |

### 5.4 Checkout & Orders

| ID | Test Case | Steps | Expected Result | Priority |
|----|-----------|-------|-----------------|----------|
| TC-ORD-01 | Place order | Complete checkout flow | Order ID generated, confirmation shown | High |
| TC-ORD-02 | Checkout without login | Guest tries checkout | Prompt to login | High |
| TC-ORD-03 | Empty cart checkout | Checkout with empty cart | Error, redirect to home | High |
| TC-ORD-04 | Past delivery date | Select yesterday's date | Validation error | Medium |
| TC-ORD-05 | Order history | View Orders tab | List of past orders | High |
| TC-ORD-06 | Order detail | Tap order in history | Full order details shown | High |
| TC-ORD-07 | Cancel pending order | Cancel PENDING order | Status → CANCELLED | Medium |

### 5.5 Profile

| ID | Test Case | Steps | Expected Result | Priority |
|----|-----------|-------|-----------------|----------|
| TC-PROF-01 | View profile | Open Profile tab | Name, email, phone displayed | Medium |
| TC-PROF-02 | Edit profile | Change name, save | Updated name shown | Medium |

### 5.6 Admin (Optional)

| ID | Test Case | Steps | Expected Result | Priority |
|----|-----------|-------|-----------------|----------|
| TC-ADM-01 | Admin login | Login as admin | Admin dashboard access | Medium |
| TC-ADM-02 | Add product | Fill form, save | Product in catalog | Medium |
| TC-ADM-03 | Update order status | Change to BAKING | Status updated in DB | Medium |

### 5.7 Non-Functional

| ID | Test Case | Steps | Expected Result | Priority |
|----|-----------|-------|-----------------|----------|
| TC-NFR-01 | App launch time | Cold start app | Opens within 3 seconds | Medium |
| TC-NFR-02 | Rotation | Rotate during checkout | State preserved | Medium |
| TC-NFR-03 | Low memory | Background/foreground app | No crash, data intact | Low |

---

## 6. Bug Report Template

| Field | Value |
|-------|-------|
| Bug ID | BUG-001 |
| Title | Short description |
| Severity | Critical / High / Medium / Low |
| Priority | P1 / P2 / P3 |
| Steps to Reproduce | Numbered steps |
| Expected | What should happen |
| Actual | What happened |
| Environment | Device, API level, build |
| Screenshot | Attach if UI bug |
| Status | Open / Fixed / Closed |

---

## 7. Test Summary Report Template

| Metric | Value |
|--------|-------|
| Total test cases | 35+ |
| Executed | |
| Passed | |
| Failed | |
| Blocked | |
| Pass rate | % |
| Critical bugs open | |

---

## 8. Sample Unit Test (Kotlin)

```kotlin
@Test
fun `calculateCartTotal returns correct sum`() {
    val items = listOf(
        CartItem(unitPrice = 25.0, quantity = 2),
        CartItem(unitPrice = 15.0, quantity = 1)
    )
    val total = CartCalculator.calculateTotal(items)
    assertEquals(65.0, total, 0.01)
}

@Test
fun `email validator rejects invalid email`() {
    assertFalse(Validators.isValidEmail("invalid"))
    assertTrue(Validators.isValidEmail("user@example.com"))
}
```

---

*Document Version: 1.0 | June 2026*
