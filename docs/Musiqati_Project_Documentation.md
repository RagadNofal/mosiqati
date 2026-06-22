# Musiqati — Project Documentation

**App Name:** Musiqati (موسيقاتي)
**Version:** 2.0.0+1
**Platform:** Flutter (Android & iOS)
**Course Project:** Mobile Application Development
**Firebase Project:** musiqati-b0284
**Package ID:** com.musiqati.store

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Problem Statement](#2-problem-statement)
3. [Target Users](#3-target-users)
4. [Tools and Technologies](#4-tools-and-technologies)
5. [Flutter Project Structure](#5-flutter-project-structure)
6. [Firebase Setup](#6-firebase-setup)
7. [Authentication Logic](#7-authentication-logic)
8. [App Roles](#8-app-roles)
9. [Admin Dashboard](#9-admin-dashboard)
10. [Product Management](#10-product-management)
11. [Product Fields and Categories](#11-product-fields-and-categories)
12. [Product Details Page](#12-product-details-page)
13. [Cart and Quantity Logic](#13-cart-and-quantity-logic)
14. [Coupons and Discounts](#14-coupons-and-discounts)
15. [Offers Page](#15-offers-page)
16. [Notifications](#16-notifications)
17. [Favorites](#17-favorites)
18. [Orders](#18-orders)
19. [Profile Page](#19-profile-page)
20. [Sounds](#20-sounds)
21. [Image Handling](#21-image-handling)
22. [Localization](#22-localization)
23. [Theme System](#23-theme-system)
24. [Other Screens](#24-other-screens)
25. [Testing Scenarios](#25-testing-scenarios)
26. [Challenges and Solutions](#26-challenges-and-solutions)
27. [Limitations](#27-limitations)
28. [Future Improvements](#28-future-improvements)

---

## 1. Project Overview

Musiqati (موسيقاتي — "My Music" in Arabic) is a mobile e-commerce application for a musical instruments store based in Jordan. The app allows customers to browse, favorite, and purchase musical instruments while giving store administrators a built-in dashboard to manage products and coupons.

The app is built with Flutter for cross-platform support and uses Firebase as its backend. It fully supports English and Arabic with automatic right-to-left (RTL) layout switching, and includes a light/dark theme toggle.

**Key highlights:**
- Bilingual (English + Arabic) with RTL support
- Three access levels: Guest, Customer, Admin
- Firestore-backed product catalog with static JSON fallback
- Cart with coupon/discount system and atomic checkout transaction
- In-app notification system
- Instrument sound previews and UI sound effects
- Favorites and order history persisted per user in Firestore

---

## 2. Problem Statement

Musical instrument stores in Jordan typically have no digital presence beyond social media. Customers must visit the store in person to:
- Check what instruments are available
- Compare prices
- Find out whether a specific item is in stock

This creates friction for both customers and store owners. Musiqati solves this by:
- Giving customers a full product catalog they can browse anytime
- Letting customers save favorites, manage a cart, and place orders online
- Giving the store admin a mobile dashboard to manage inventory and promotions without needing a web panel
- Offering bilingual support so both Arabic and English speakers can use the app comfortably

---

## 3. Target Users

| User Type | Description |
|-----------|-------------|
| **Guest** | Anyone who opens the app without logging in. Can browse all products, view details, use favorites (in-memory only), and add to cart, but cannot checkout. |
| **Customer** | Registered user. Full access: browse, favorite (persisted), add to cart, apply coupons, checkout, and view order history. |
| **Admin** | Store owner or manager. Can manage the product catalog (add, edit, enable/disable, delete) and manage coupons. Accessed through the same app with a special admin role in Firestore. |

**Primary audience:** Jordanian music enthusiasts, music students, and professional musicians aged 15–45 who are comfortable shopping on mobile apps.

---

## 4. Tools and Technologies

### Framework
| Tool | Version | Purpose |
|------|---------|---------|
| Flutter | 3.41.9 | Cross-platform UI framework |
| Dart | 3.11.5 | Programming language |

### Firebase Services
| Service | Status | Purpose |
|---------|--------|---------|
| Firebase Auth | Active | Email/Password authentication |
| Cloud Firestore | Active | Products, orders, coupons, user data, favorites, cart |
| Firebase Storage | **Not active** | Package installed but not used (Spark plan limitation — see Limitations) |

### Flutter Packages
| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.2 | State management (ChangeNotifier pattern) |
| `cloud_firestore` | ^5.4.0 | Database reads and writes |
| `firebase_auth` | ^5.2.0 | User authentication |
| `firebase_core` | ^3.4.0 | Firebase initialization |
| `audioplayers` | ^6.1.0 | Sound effects and instrument previews |
| `video_player` | ^2.9.1 | Product demo videos on details page |
| `image_picker` | ^1.2.2 | Profile photo selection from gallery |
| `shared_preferences` | ^2.3.2 | Local persistence (sound setting, profile image path) |
| `url_launcher` | ^6.3.2 | Open external links (website, email, phone) |
| `share_plus` | ^9.0.0 | Share app content via native share sheet |
| `flutter_rating_bar` | ^4.0.1 | Star rating widget on product details |
| `flutter_localizations` | SDK | Arabic/English localization |
| `intl` | ^0.20.2 | Locale formatting support |
| `http` | ^1.2.0 | HTTP package (used by fallback product service) |

### Development Tools
- Android Studio / VS Code
- Firebase Console (web dashboard)
- `device_preview` package (UI testing on different screen sizes)

---

## 5. Flutter Project Structure

```
project_assignment_e/
├── lib/
│   ├── main.dart                    # App entry point, Firebase init, MultiProvider
│   ├── l10n/
│   │   └── app_localizations.dart   # Custom EN/AR string map
│   ├── models/
│   │   ├── app_user.dart            # AppUser model (uid, name, email, role)
│   │   ├── product.dart             # Result model (static JSON product)
│   │   ├── firestore_product.dart   # FirestoreProduct model (full bilingual fields)
│   │   └── coupon.dart              # Coupon model with status + discount logic
│   ├── providers/
│   │   ├── auth_provider.dart       # AppAuthProvider (login, register, guest, role)
│   │   ├── products_provider.dart   # ProductProvider (list, filter, search, favorites)
│   │   ├── cart_provider.dart       # CartProvider (entries, coupon, checkout)
│   │   ├── notifications_provider.dart # NotificationsProvider (in-app messages)
│   │   ├── sound_provider.dart      # SoundProvider (UI sounds + instrument sounds)
│   │   ├── theme_provider.dart      # ThemeProvider (light/dark toggle)
│   │   └── locale_provider.dart     # LocaleProvider (EN/AR toggle)
│   ├── services/
│   │   ├── auth_service.dart        # Firebase Auth + Firestore user operations
│   │   ├── firestore_service.dart   # All Firestore operations (products, orders, favorites, cart)
│   │   ├── coupon_service.dart      # Coupon CRUD + validation logic
│   │   └── products_services.dart   # Static JSON product loader (fallback)
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── welcome_screen.dart  # First screen (Guest / Login / Register)
│   │   │   ├── login_screen.dart    # Login form
│   │   │   └── register_screen.dart # Registration form
│   │   ├── admin/
│   │   │   ├── admin_dashboard.dart # Admin home (stats, product list, FABs)
│   │   │   ├── product_form_screen.dart # Add / Edit product form
│   │   │   └── coupons/
│   │   │       ├── admin_coupons_screen.dart # Coupon list + management
│   │   │       └── coupon_form_screen.dart   # Add / Edit coupon form
│   │   ├── orders/
│   │   │   └── my_orders_screen.dart # Customer order history
│   │   ├── home_page.dart           # Main customer screen
│   │   ├── details_screen.dart      # Product detail view
│   │   ├── all_products_screen.dart # Full unfiltered product list
│   │   ├── favorites_screen.dart    # Saved favorite products
│   │   ├── cart_screen.dart         # Shopping cart + checkout
│   │   ├── offers_screen.dart       # Active coupons / deals
│   │   ├── notifications_screen.dart # In-app notification list
│   │   ├── profile_screen.dart      # User profile page
│   │   ├── edit_profile_screen.dart # Edit name, phone, address
│   │   ├── learn_music_screen.dart  # Interactive music learning guides
│   │   ├── about_screen.dart        # App info, contact, share
│   │   ├── services_screen.dart     # Maintenance/consultation request UI
│   │   ├── settings_screen.dart     # App settings
│   │   └── image_viewer_screen.dart # Full-screen zoomable image
│   ├── utils/
│   │   └── app_colors.dart          # Shared color constants
│   └── widgets/
│       └── product_image.dart       # Reusable product image widget with fallback
├── assets/
│   ├── get-products.json            # Static fallback product data (10 products)
│   └── audio/                       # Sound effect MP3 files (8 files)
└── pubspec.yaml
```

---

## 6. Firebase Setup

### Services Used

**Firebase Authentication**
- Provider: Email/Password only
- No social login (Google, Facebook) implemented
- User document is automatically created in Firestore on first registration

**Cloud Firestore**
- NoSQL document database
- Collections used:

| Collection | Purpose |
|------------|---------|
| `users/{uid}` | User profile (name, email, phone, address, role, createdAt) |
| `users/{uid}/favorites/{productId}` | User's favorite product IDs |
| `users/{uid}/cart/{productId}` | User's persisted cart items with product snapshot |
| `products/{productId}` | Full product catalog with stock levels |
| `orders/{orderId}` | Completed orders (userId, items map, totals, status, timestamps) |
| `coupons/{couponId}` | Discount codes with rules and usage tracking |

**Firebase Storage**
- Package `firebase_storage: ^12.2.0` is included in `pubspec.yaml`
- **Not currently active** — the Firebase project is on the Spark (free) plan which does not include Storage
- Images are handled as URLs entered manually by the admin (see Image Handling section)

### AuthGate Routing Logic

The `AuthGate` widget in `main.dart` watches `AppAuthProvider` and routes the user:

```
AuthStatus.initial / loading  →  SplashScreen
AuthStatus.authenticated      →  AdminDashboard  (if user.isAdmin)
                               →  HomeScreen      (if customer)
AuthStatus.unauthenticated    →  HomeScreen      (if guest mode active)
                               →  WelcomeScreen   (default)
AuthStatus.error              →  WelcomeScreen
```

---

## 7. Authentication Logic

### Registration Flow
1. User fills in: Full Name, Email, Password, Confirm Password
2. Client-side validation: all fields required, email format, password min 6 chars, passwords must match
3. `AuthService.registerCustomer()` creates a Firebase Auth account, then writes a user document to Firestore with `role: 'customer'`
4. `_onAuthStateChanged` fires automatically, fetches the user doc, sets `AuthStatus.authenticated`
5. AuthGate reroutes to `HomeScreen`

### Login Flow
1. User fills in Email and Password
2. `AuthService.signIn()` calls `FirebaseAuth.signInWithEmailAndPassword()`
3. `_onAuthStateChanged` fires, fetches user doc from Firestore
4. If user doc is missing (edge case), it is auto-created as a customer
5. AuthGate reroutes to `AdminDashboard` or `HomeScreen` based on role

### Guest Mode
- Tapping "Continue as Guest" on WelcomeScreen calls `auth.continueAsGuest()`
- Sets `_isGuest = true`, no Firebase call
- User can browse products, add to cart (in-memory), and use favorites (in-memory)
- Attempting checkout shows a dialog requiring login

### Sign Out
- `auth.signOut()` calls Firebase sign out, clears `_user`, clears `_isGuest`
- AuthGate reroutes to WelcomeScreen

### Error Handling
Friendly messages are returned for common Firebase error codes:
- `user-not-found` / `wrong-password` / `invalid-credential` → "Invalid email or password."
- `email-already-in-use` → "An account with this email already exists."
- `weak-password` → "Password must be at least 6 characters."
- `network-request-failed` → "No internet connection."

---

## 8. App Roles

### Guest
- Can browse all available products
- Can search and filter by category
- Can view full product details (including videos and images)
- Can add products to cart and manage quantities (in-memory, cleared on app restart)
- Can save favorites (in-memory only, not persisted)
- **Cannot** checkout (login dialog shown)
- **Cannot** view order history
- No profile data stored

### Customer
Everything a guest can do, plus:
- Cart is persisted to Firestore (`users/{uid}/cart/`) — survives app restarts
- Favorites are persisted to Firestore (`users/{uid}/favorites/`)
- Can apply coupons and complete checkout
- Order history stored in Firestore and viewable in My Orders
- Profile page shows name, email, role badge, favorites count, cart count
- Can edit name, phone number, and address
- Can upload a profile photo (stored locally via SharedPreferences, not Firebase Storage)
- Achievements badges (Music Lover, First Purchase, Sound Explorer)

### Admin
- Enters through the same app (no separate admin app)
- Role is stored as `role: 'admin'` in the Firestore user document
- AuthGate routes admin users directly to AdminDashboard after login
- Can view product stats (total, low stock, out of stock)
- Can add new products with full bilingual fields
- Can edit any existing product
- Can enable or disable product availability
- Can delete products
- Can view and manage coupons (add, edit, activate/deactivate, delete)
- Can navigate back to customer HomeScreen via the "Back to Store" link

---

## 9. Admin Dashboard

The Admin Dashboard is the first screen shown to admin users after login.

### Layout
- **App bar:** "Admin Dashboard" title + logout button (with confirm dialog)
- **Stats row:** Three stat cards showing Total Products, Low Stock count, Out of Stock count — each card is tappable and shows a filtered modal list of the relevant products
- **Second stats row:** Active Coupons count (live Firestore stream) + Notifications count
- **Quick nav row:** Three navigation cards → Manage Products, Manage Coupons, Notifications
- **Product list:** Full `StreamBuilder` list of all products (including unavailable), sorted by creation date descending
- **FAB (right):** "Add Product" — opens `ProductFormScreen`
- **FAB (left):** "Manage Coupons" — opens `AdminCouponsScreen`

### Product List Items
Each product card in the admin list shows:
- Product image, name (EN), brand, price
- Stock badge (Available / Low Stock / Out of Stock / Unavailable)
- Three action buttons: Edit, Enable/Disable toggle, Delete (with confirmation dialog)

### Guard
If a non-admin user somehow navigates to this screen, a lock icon and "Admin Access Only" message is shown.

---

## 10. Product Management

### Adding a Product (`ProductFormScreen`)
The admin fills in a comprehensive form:
- **Required:** Product name (EN), Product name (AR), description (EN), description (AR), price, quantity, category, brand (EN), brand (AR), at least one image URL
- **Optional:** Model number, color (EN/AR), weight, dimensions, material (EN/AR), warranty (EN/AR), origin country (EN/AR), condition (EN/AR), specifications (EN/AR), features (EN/AR), multiple additional image URLs, video URL

On save, `FirestoreService.addProduct()` writes the document to the `products` collection with `isAvailable: true` and a server timestamp.

### Editing a Product
Same form, pre-populated with existing data. Saves via `FirestoreService.updateProduct()` with an `updatedAt` server timestamp.

### Enable / Disable
- Sets `isAvailable: false` or `true` in Firestore
- Disabled products are hidden from the customer-facing product stream but still visible in the admin list
- The `streamAvailableProducts()` query filters by `isAvailable == true`

### Deleting a Product
Requires confirmation dialog. Permanently removes the document from Firestore.

### Product Data Source
`ProductProvider` uses a priority system:
1. **Firestore stream** (`streamAvailableProducts()`) — real-time updates, used when products exist
2. **Static JSON fallback** (`assets/get-products.json`) — 10 pre-loaded products used when Firestore returns an empty list or throws an error

This means the app works even without an active internet connection (fallback data shown).

---

## 11. Product Fields and Categories

### Categories

| Key | Display EN | Display AR |
|-----|-----------|-----------|
| `guitar` | Guitar | قيثارة |
| `piano` | Piano | بيانو |
| `drums` | Drums | طبول |
| `oud` | Oud | عود |
| `studio` | Studio | استوديو |
| `studiotools` | Studio Tools | أدوات الاستوديو |

### FirestoreProduct Fields

| Field | Type | Notes |
|-------|------|-------|
| `nameEn` / `nameAr` | String | Bilingual product name |
| `descriptionEn` / `descriptionAr` | String | Bilingual description |
| `brandEn` / `brandAr` | String | Bilingual brand |
| `modelNumber` | String | Model/SKU code |
| `price` | double | Price in JOD |
| `quantity` | int | Stock quantity |
| `category` | String | One of 6 category keys |
| `colorEn` / `colorAr` | String | Bilingual color |
| `weight` | String | e.g., "2.5 kg" |
| `dimensions` | String | e.g., "100x40x10 cm" |
| `materialEn` / `materialAr` | String | Bilingual material |
| `warrantyEn` / `warrantyAr` | String | Bilingual warranty info |
| `originCountryEn` / `originCountryAr` | String | Country of manufacture |
| `conditionEn` / `conditionAr` | String | New / Used / Refurbished |
| `specificationsEn` / `specificationsAr` | String | Tech specs |
| `featuresEn` / `featuresAr` | String | Key feature highlights |
| `imageUrl` | String | Primary image URL |
| `images` | List\<String\> | Additional image URLs |
| `videoUrl` | String | Optional demo video URL |
| `isAvailable` | bool | Visibility flag |
| `createdAt` / `updatedAt` | Timestamp | Server timestamps |

### Stock Status Logic
```
quantity <= 0    → Out of Stock (red badge)
0 < quantity <= 5 → Low Stock (orange badge)
quantity > 5     → Available (green badge)
isAvailable = false → Unavailable (grey badge)
```

---

## 12. Product Details Page

The `DetailsScreen` provides a rich, full view of a single product.

### Content Sections
- **Hero image** with horizontal swipe gallery (multiple images from `allImages` list)
- **Fullscreen viewer** — tapping any image opens `ImageViewerScreen` with pinch-to-zoom
- **Video player** — if `videoUrl` is set, an embedded video player appears with play/pause controls
- **Product name** — localized (EN or AR based on current language)
- **Brand, price (JOD), color, weight, quantity badge**
- **Star rating bar** (`flutter_rating_bar`) — stored in `ProductProvider._ratings` (in-memory, not persisted)
- **Add to Cart button** — shows current quantity in cart, disabled when out of stock
- **Favorite toggle button**
- **Share button** — uses `share_plus` to share product name and price
- **Expandable sections:** Description, Specifications, Features, Material, Warranty, Origin Country, Condition
- All expandable sections show localized (EN/AR) content automatically

### Instrument Sound Preview
When the details page opens, it automatically plays a brief instrument sound based on the product category:
- Guitar → soft guitar chord sample
- Piano → piano chord sample
- Drums → drum loop sample
- Oud → haptic feedback (no audio file mapped)
- Studio / Studio Tools → UI click sound

This is triggered once via `WidgetsBinding.addPostFrameCallback` in `initState`.

---

## 13. Cart and Quantity Logic

The cart is managed by `CartProvider` (ChangeNotifier).

### Data Structure
`CartEntry` holds:
- `Result product` — the product object (including current stock as `quantity`)
- `int quantity` — how many of this product the user wants

### Rules
- Adding a product with zero stock: **silently ignored**
- Adding an existing product increments its quantity by 1
- Quantity is capped at the product's `quantity` (stock) value
- When quantity reaches stock limit, the + button is greyed out and "At Stock Limit" label appears
- Removing the last unit of an item removes the entire cart entry
- When the cart becomes empty, any applied coupon is automatically removed

### Persistence
- **Guest:** Cart is in-memory only. Lost when app is closed.
- **Logged-in user:** Every add/remove/quantity change triggers a fire-and-forget write to `users/{uid}/cart/{productId}` in Firestore. On next login, the cart is reloaded from Firestore. After a successful checkout, `clearUserCart(uid)` is called to wipe the Firestore cart.

### Checkout Flow
1. Guest → login dialog shown, checkout blocked
2. Logged-in user → confirmation dialog with order summary (subtotal, discount, shipping: free, total)
3. On confirm, `FirestoreService.checkout()` runs an **atomic Firestore transaction** that:
   - Re-reads all product documents
   - Re-validates stock availability
   - Re-validates the coupon (if applied) against live Firestore data
   - Deducts stock quantity from each product
   - Increments the coupon's `usedCount`
   - Writes a new document to the `orders` collection
4. On success: `CartProvider.clearCart()` is called, success snackbar shown
5. On failure: `CheckoutException` is thrown with a localized error message

> **Note:** Products loaded from the static JSON fallback (`isFirestoreBacked = false`) are excluded from the Firestore transaction since they have no real documents. Only Firestore-backed products affect stock in the transaction.

---

## 14. Coupons and Discounts

### Coupon Model (`coupon.dart`)
Each coupon has:
- `code` — uppercase alphanumeric string (e.g., `SUMMER10`)
- `discountType` — either `'percentage'` or `'fixed'`
- `discountValue` — the amount or percentage
- `minOrderAmount` — minimum cart subtotal required to apply
- `maxDiscountAmount` — optional cap on percentage discounts
- `validFrom` / `validUntil` — date range
- `isActive` — admin toggle
- `usageLimit` — optional, null = unlimited
- `usedCount` — incremented atomically at checkout
- Bilingual `titleEn`/`titleAr` and `descriptionEn`/`descriptionAr`

### Status Computation
The `status` getter automatically computes:

| Status | Condition |
|--------|-----------|
| `active` | isActive = true, within date range, usage not exceeded |
| `expired` | Past `validUntil` date |
| `notStarted` | Before `validFrom` date |
| `usageLimitReached` | usedCount >= usageLimit |
| `inactive` | isActive = false |

### Discount Calculation
```
Percentage discount:
  discount = subtotal × (discountValue / 100)
  if maxDiscountAmount != null: discount = min(discount, maxDiscountAmount)
  discount = min(discount, subtotal)   // never exceeds cart total

Fixed discount:
  discount = min(discountValue, subtotal)
```

### Applying a Coupon (Customer Flow)
1. User types the coupon code in the cart's text field
2. `CartProvider.applyCoupon(code)` checks: cart not empty, code not empty, calls `CouponService.findByCode(code)` (case-insensitive Firestore query)
3. `CouponService.validateCoupon()` checks: status = active, subtotal >= minOrderAmount
4. If valid: coupon applied, discount shown in order summary
5. If invalid: error snackbar shown with localized key (e.g., `couponExpired`, `couponMinOrderError`)

### Coupon Validation Error Keys
| Key | Meaning |
|----|---------|
| `couponNotFound` | Code does not exist |
| `couponCartEmpty` | Cart is empty |
| `couponExpired` | Past valid date |
| `couponNotStarted` | Not yet valid |
| `couponUsageLimitReached` | Max uses hit |
| `couponMinOrderError` | Order too small |
| `couponInactive` | Admin disabled it |

### Admin Coupon Management
Admins can via `AdminCouponsScreen`:
- View all coupons (streamed in real-time)
- Add a new coupon via `CouponFormScreen`
- Edit an existing coupon
- Toggle active/inactive
- Delete a coupon (with confirmation)

---

## 15. Offers Page

`OffersScreen` is accessible from the Home page's "Offers & Discounts" section.

### Functionality
- Streams all coupons via `CouponService.streamAllCoupons()`
- Filters to show only `CouponStatus.active` coupons
- Each `_CouponCard` displays:
  - Coupon code in a styled chip
  - Discount badge (gradient: percentage or fixed amount)
  - Bilingual title and description
  - Info chips: discount value, minimum order, valid until date, usage count
  - **"Copy Code" button** — copies code to clipboard, shows snackbar
  - **"Apply in Cart" button** — calls `cart.applyCoupon(code)`, plays success/error sound, navigates to `CartPage` on success
- Empty state shown when no active coupons exist

---

## 16. Notifications

### Architecture
Musiqati uses an **in-app only** notification system. There is no Firebase Cloud Messaging (FCM) and no push notifications.

### Data Model (`NotificationModel`)
Each notification has:
- `id` — unique string
- `titleKey` / `bodyKey` — localization keys for pre-defined messages
- `titleEn` / `titleAr` / `bodyEn` / `bodyAr` — direct text for programmatic notifications
- `icon` — IconData
- `color` — display color
- `time` — DateTime
- `isRead` — boolean flag

### Pre-seeded Notifications
`NotificationsProvider` initializes with 4 static notifications:

| ID | Icon | Key |
|----|------|-----|
| `offer_1` | local_offer | `notifOffer` / `notifOfferBody` |
| `order_1` | receipt_long | `notifOrder` / `notifOrderBody` |
| `reminder_1` | music_note | `notifReminder` / `notifReminderBody` |
| `message_1` | chat_bubble | `notifMessage` / `notifMessageBody` |

### Features
- **Mark as Read:** Tap a notification to mark it read (animated highlight → normal)
- **Mark All as Read:** App bar action button (only visible when unread exist)
- **Swipe to Dismiss:** Swipe left on any notification to remove it
- **Clear All:** Button clears all notifications
- **Time formatting:** "Just now", "X min ago", "X h ago", "Yesterday"
- **Unread badge:** Count shown on the bell icon in the home page app bar
- **Deduplication:** `addNotification()` checks by id to prevent duplicates

### Limitation
Notifications are not sent from the server. They are pre-loaded in the `NotificationsProvider` constructor and reset every time the app is restarted. There is no real-time Firestore listener or FCM integration.

---

## 17. Favorites

### Behavior by Role

**Guest:**
- Favorites stored in `ProductProvider._favoriteIds` (a `Set<String>`)
- In-memory only — lost when app is restarted
- Toggle works normally but nothing is persisted

**Logged-in Customer:**
- On login, `ProductProvider.setCurrentUid(uid)` triggers `_loadFavoritesFromFirestore(uid)`
- Fetches the `users/{uid}/favorites/` subcollection, populates `_favoriteIds`
- On `toggleFavorite(id)`: updates the in-memory set immediately (no UI lag), then fires a background write to Firestore (`addFavorite` or `removeFavorite`)
- On logout, `_favoriteIds` is cleared in memory

### Favorites Screen
- Filters `ProductProvider.productList` against the `favorites` set
- `SliverGrid` with 2-column layout
- Each `_FavCard` shows: product image, name (localized), brand, price in JOD, remove button, add-to-cart button
- Empty state plays `SoundType.emptyFavorites` sound once on first appearance

---

## 18. Orders

### Order Creation
Orders are created during `FirestoreService.checkout()` as part of the atomic transaction.

**Order document fields:**
```
orders/{orderId}:
  userId:         String (Firebase Auth UID)
  items:          Map<productId, quantity>
  subtotal:       double
  couponCode:     String? (null if no coupon)
  discountAmount: double
  total:          double
  status:         'pending'
  createdAt:      Timestamp
```

> **Note:** Status is always written as `'pending'`. There is no order status update mechanism in the current app (admin cannot change status to 'completed' or 'cancelled'). This is a known limitation.

### Order History (`MyOrdersScreen`)
- Guest check: shows lock icon with login prompt
- Streams Firestore `orders` collection filtered by `userId == auth.user.uid`, ordered by `createdAt` descending
- Each `_OrderCard` shows:
  - Short order ID (first 8 characters, uppercase)
  - Status badge (pending = amber, completed = green, cancelled = red) — color-coded but status only ever shows 'pending'
  - Creation date
  - Number of line items
  - Subtotal, discount row (if coupon was used, shows the coupon code), total

---

## 19. Profile Page

### Layout
The profile screen uses a `SliverAppBar` with `expandedHeight: 330` for a collapsible header.

**Header section:**
- Avatar with gradient ring. Tapping the camera icon opens `ImagePicker` for gallery selection
- User's display name and email
- Role badge (Admin / Customer / Guest) with appropriate icon
- Three inline stats: Favorites count, Cart item count, Orders (shows 0 — not live from Firestore)

**Body sections:**
- **Achievements** (logged-in users only): Three badge cards — "Music Lover" (unlocked if favorites > 0), "First Purchase" (unlocked if cart > 0), "Sound Explorer" (always unlocked)
- **Quick Links:** My Favorites, My Orders, Language toggle, Theme switch, Sound toggle, Admin Dashboard link (admin only), Logout / Login

### Profile Photo
- Picked from device gallery via `image_picker`
- File path saved to `SharedPreferences` with key `profile_image_{uid}`
- Displayed using `Image.file()` with `errorBuilder` fallback to icon
- **Not uploaded to Firebase Storage** — stored locally on the device only

### Edit Profile
`EditProfileScreen` allows changing: Name, Phone Number, Address.
Email cannot be changed (Firebase limitation without re-authentication).
`AppAuthProvider.updateProfile()` writes changes to Firestore and updates local state.

---

## 20. Sounds

### Overview
`SoundProvider` uses the `audioplayers` package with a single `AudioPlayer` instance.

### UI Sounds (`SoundType` enum)
| Type | Asset File | Trigger |
|------|-----------|---------|
| `click` | interface-button-154180.mp3 | Navigation, general taps |
| `navigation` | interface-button-154180.mp3 | Screen transitions |
| `favorite` | interface-button-154180.mp3 | Add/remove favorite |
| `cart` | add-408457.mp3 | Add to cart |
| `notification` | interface-button-154180.mp3 | Notification interactions |
| `theme` | interface-button-154180.mp3 | Theme toggle |
| `language` | interface-button-154180.mp3 | Language change |
| `couponSuccess` | success-chime-513565.mp3 | Coupon applied successfully |
| `couponError` | interface-button-154180.mp3 | Coupon rejected |
| `emptyCart` | crow-sfx-318131.mp3 | Empty cart state appears |
| `emptyFavorites` | crow-sfx-318131.mp3 | Empty favorites state appears |

### Instrument Sounds (`InstrumentSound` enum)
| Instrument | Asset File | Trigger |
|------------|-----------|---------|
| `guitar` | soft-indie-guitar-456142.mp3 | Open guitar product details |
| `piano` | piano-chords-239967.mp3 | Open piano product details |
| `drums` | war-drum-loop-103870.mp3 | Open drums product details |
| `oud` | (none — haptic only) | Open oud product details |

### Controls
- `play(SoundType)` — also fires `HapticFeedback.lightImpact()`
- `playInstrument(InstrumentSound)` — plays instrument preview
- `toggle()` — enables/disables all sounds
- `isEnabled` state persisted via `SharedPreferences` (`soundEnabled` key)
- If sounds are disabled, `play()` and `playInstrument()` return immediately

---

## 21. Image Handling

### Why URLs Instead of Firebase Storage
The app is on the Firebase Spark (free) plan. Firebase Storage requires the Blaze (pay-as-you-go) plan. Therefore, all product images are entered as **public image URLs** manually by the admin in the product form.

The `firebase_storage` package is present in `pubspec.yaml` as a placeholder for a future upgrade, but no storage reads or writes happen in the current code.

### Image Priority Chain (`FirestoreProduct`)
```
1. allImages list (multiple URLs from 'images' field)
2. imageUrl (single URL from legacy 'imageUrl' field)
3. imageAsset (asset path, for bundled images)
```

### `ProductImageWidget`
A reusable widget (`lib/widgets/product_image.dart`) handles image loading:
- Uses `Image.network()` for URL-based images
- Uses `Image.asset()` for asset-based images
- Shows a music note icon placeholder on error or when URL is empty
- Configurable `fit`, `iconSize`, `iconColor`

### Profile Image
- User picks from gallery via `ImagePicker` (device only)
- File path stored in `SharedPreferences` as `profile_image_{uid}`
- Displayed with `Image.file()` + `errorBuilder` (fallback to person icon)
- Not uploaded anywhere — local to the device

---

## 22. Localization

### System
A fully custom localization system is implemented in `lib/l10n/app_localizations.dart`.

- `AppLocalizations` class holds a `Map<String, Map<String, String>>` for English and Arabic
- `t(String key)` returns the translated string for the current locale, with a **safe fallback** that returns the key itself if not found (no crashes on missing keys)
- `AppLocalizationsDelegate` integrates with Flutter's `MaterialApp.localizationsDelegates`

### RTL Support
- Arabic locale automatically switches to RTL layout via `Directionality` widget
- `flutter_localizations` package provides system-level RTL support
- Most screens use `Directionality.of(context) == TextDirection.rtl` checks for icon/layout flipping

### Supported Languages
| Language | Code |
|----------|------|
| English | `en` |
| Arabic (Jordan) | `ar` |

### Language Toggle
- `LocaleProvider.toggleLocale()` switches between `Locale('en')` and `Locale('ar')`
- Persisted via... **Note:** Language preference is NOT currently persisted between app restarts (no SharedPreferences write for locale).

---

## 23. Theme System

### Light Theme
- Seed color: Raspberry (`#912F56`)
- Scaffold background: Cream (`#FAF0EE`)
- Card color: White
- Button style: Stadium shape (pill)
- Material 3 design

### Dark Theme
- Scaffold background: Deep wine-black (`#0D090A`)
- Surface/card color: Dark plum (`#28141E`)
- Full override for list tiles, switches, icons
- All text uses high-contrast white

### Palette
| Name | Hex | Used For |
|------|-----|---------|
| Raspberry | `#912F56` | Primary action color, badges |
| Plum | `#521945` | App bars, gradients |
| Wine | `#361F27` | Gradient start, dark surface |
| Gold | `#D4A853` | Prices, highlights, badges |
| Sage | `#3D7A6A` | Success states, shipping |

### Persistence
Theme preference is toggled via `ThemeProvider.toggle()`. **Note:** Theme preference is NOT currently persisted between app restarts.

---

## 24. Other Screens

### Services Screen (`services_screen.dart`)
- UI form for two service types: **Maintenance** and **Consultation**
- Fields: instrument type, issue description, contact info, preferred time (Morning/Afternoon/Evening)
- Shows "Request Sent" confirmation
- **Limitation:** No backend connection — form data is not saved anywhere

### Settings Screen (`settings_screen.dart`)
- Basic settings page accessible from the app
- Contains language, theme, and sound controls (same as profile quick links)

### Learn Music Screen (`learn_music_screen.dart`)
- 7 interactive guide cards: Guitar Basics, Piano Basics, Oud Basics, Drums & Rhythm, Music Theory, Tuning Tips, Practice Routine
- Tapping a card opens a `DraggableScrollableSheet` (55–85% of screen height) with bilingual instructional text
- YouTube links section with direct browser launch
- Website links section
- Horizontal scroll of YouTube resource thumbnails
- Sound played before opening browser links (600ms delay)

### About Screen (`about_screen.dart`)
- App logo, name, tagline
- Version badge
- Mission statement
- Features list (4 items with icons)
- Contact info: email (mailto: link), phone (tel: link), website (https: link), address
- Share App button using `share_plus`

### Image Viewer Screen (`image_viewer_screen.dart`)
- Full-screen zoomable image view
- `InteractiveViewer` with pinch-to-zoom
- Opened from product details page by tapping any image

---

## 25. Testing Scenarios

The following scenarios were manually tested during development:

### Authentication
| Scenario | Expected Result |
|----------|----------------|
| Register with valid data | Account created, routed to HomeScreen |
| Register with existing email | "Email already in use" error shown |
| Register with weak password (< 6 chars) | "Password must be at least 6 characters" error |
| Login with wrong password | "Invalid email or password" error |
| Login as admin | Routed to AdminDashboard |
| Continue as guest | HomeScreen shown, no auth |
| Logout | Cleared state, WelcomeScreen shown |

### Cart
| Scenario | Expected Result |
|----------|----------------|
| Add product to cart | Entry added, badge count incremented |
| Add same product twice | Quantity incremented (not duplicate entry) |
| Add product at stock limit | + button greyed, "At Stock Limit" shown |
| Add out-of-stock product | Silently ignored |
| Swipe to dismiss item | Item removed, snackbar shown |
| Remove last item | Cart empties, coupon auto-removed |
| Guest tries to checkout | Login dialog shown |

### Coupons
| Scenario | Expected Result |
|----------|----------------|
| Apply valid coupon | Discount shown, success sound played |
| Apply non-existent code | "Coupon not found" error |
| Apply expired coupon | "Coupon expired" error |
| Apply coupon to empty cart | "Cart is empty" error (guard added in Step 1) |
| Apply coupon below min order | "Minimum order" error |
| Apply coupon at usage limit | "Usage limit reached" error |
| Checkout with coupon | `usedCount` incremented atomically in Firestore |

### Products
| Scenario | Expected Result |
|----------|----------------|
| Admin disables product | Product disappears from customer view |
| Admin adds product | Appears immediately via stream |
| View all products | Shows full unfiltered list (not affected by home filter) |
| Filter by category on home | Only matching products shown |
| Clear filter | Full list restored |

### Persistence
| Scenario | Expected Result |
|----------|----------------|
| Add favorites, log out, log back in | Favorites restored from Firestore |
| Add to cart, log out, log back in | Cart restored from Firestore |
| Complete checkout | Firestore cart cleared, order appears in My Orders |

---

## 26. Challenges and Solutions

### Challenge 1: Category Filter Causing Red Error Widget
**Problem:** On the home page, calling `ProductProvider.filterByCate()` inside a `setState()` callback caused `notifyListeners()` to fire during a Flutter build cycle, producing a one-frame red `ErrorWidget`.

**Solution:** Moved all `ProductProvider` method calls to BEFORE the `setState()` call, separating provider mutations from UI state updates.

---

### Challenge 2: Coupon Applied to Empty Cart
**Problem:** A user could apply a coupon before adding any products, which made no sense logically.

**Solution:** Added an empty-cart guard at the top of `CartProvider.applyCoupon()`. Also added auto-removal of the applied coupon in `removeQuantity()` and `itemRemoveFromCart()` when the cart becomes empty.

---

### Challenge 3: View All Showing Filtered Products
**Problem:** The "View All" button on the home page navigated to `AllProductsScreen`, which used `ProductProvider.productList`. Since `productList` respects the active home-page category filter, View All was showing only the filtered subset.

**Solution:** Added a separate `allProducts` getter to `ProductProvider` that always returns the full, unfiltered list. `AllProductsScreen` was updated to use `allProducts`.

---

### Challenge 4: About Page Header Overflow
**Problem:** On devices with thin status bars, the `SliverAppBar`'s `expandedHeight: 200` was too small to fit the icon, app name, and tagline without overflowing.

**Solution:** Increased `expandedHeight` to `250`, reduced top padding from 50 to 24, and wrapped the title `Text` in a `Flexible` widget to prevent unbounded width errors.

---

### Challenge 5: Firebase Storage Not Available
**Problem:** Storing product images and profile photos requires Firebase Storage, which needs the Blaze plan.

**Solution:** For product images, the admin enters public image URLs manually. For profile photos, the local file path is saved to `SharedPreferences` (device-only storage). The `firebase_storage` package is included in `pubspec.yaml` for a future upgrade.

---

### Challenge 6: Cart Loading Timing
**Problem:** When a user logs in, the cart loads from Firestore. However, the product stream from Firestore may not have loaded yet, making it impossible to match cart items to live `Result` objects.

**Solution:** The Firestore cart document stores a full product snapshot (name, price, image, category, stock quantity, etc.). On load, if the product exists in the live list, the live version is used (fresh stock count). If not yet loaded, the stored snapshot is used to reconstruct a `Result` object. The checkout transaction re-validates stock regardless.

---

### Challenge 7: RTL Layout with Custom Widgets
**Problem:** Many custom-designed cards and rows had hard-coded left/right alignment that broke in Arabic (RTL) mode.

**Solution:** Used `Directionality.of(context) == TextDirection.rtl` checks throughout, and used `CrossAxisAlignment.start` with `Directionality`-aware `Padding` and `Row` layouts. Icon positions in product cards are swapped based on RTL state.

---

## 27. Limitations

| # | Limitation | Reason |
|---|-----------|--------|
| 1 | **Firebase Storage not used** — profile photos stored locally, product images are URLs | Firebase Spark plan does not include Storage |
| 2 | **No push notifications** — notifications are pre-seeded in-memory | Firebase Cloud Messaging not integrated |
| 3 | **Notifications reset on restart** — `NotificationsProvider` re-seeds 4 notifications every cold start | No Firestore persistence for notifications |
| 4 | **Order status is always 'pending'** — admin cannot update to 'completed' or 'cancelled' | Order management UI not implemented |
| 5 | **No order count in profile header** — shows '0' hardcoded instead of querying Firestore | Stream not connected to profile stats |
| 6 | **Product ratings not persisted** — star ratings in `ProductProvider._ratings` are in-memory | No Firestore write for ratings |
| 7 | **Language preference not saved** — resets to English on app restart | No SharedPreferences write for locale |
| 8 | **Theme preference not saved** — resets on app restart | No SharedPreferences write for theme |
| 9 | **Services screen has no backend** — maintenance/consultation forms are UI only | No Firestore collection for service requests |
| 10 | **No real-time inventory sync in cart** — cart loaded once on login, not updated live | Would require listening to product stream changes |
| 11 | **Admin cannot send notifications to users** — no admin notification broadcast | FCM not integrated |
| 12 | **No password reset flow** — "Forgot Password" not implemented | Firebase `sendPasswordResetEmail` not called |
| 13 | **Single admin account model** — any Firestore user with `role: admin` gets admin access; no admin creation UI | Admin accounts must be created by directly editing Firestore |

---

## 28. Future Improvements

| # | Improvement | Impact |
|---|------------|--------|
| 1 | Upgrade to Firebase Blaze plan → enable Firebase Storage for product images and profile photos | High — cleaner admin image upload workflow |
| 2 | Add Firebase Cloud Messaging for real push notifications | High — real-time order updates, promotions |
| 3 | Persist notifications in Firestore per user | Medium — notifications survive restarts |
| 4 | Add order status management for admin (pending → shipped → delivered) | High — complete order lifecycle |
| 5 | Fix profile header order count (query Firestore for real count) | Medium — data accuracy |
| 6 | Persist product ratings to Firestore | Medium — community feedback |
| 7 | Save language + theme preferences in SharedPreferences | Low — quality of life |
| 8 | Connect Services screen to Firestore (`serviceRequests` collection) | Medium — actual business functionality |
| 9 | Add payment gateway (e.g., PayTabs, ClickPay for Jordan) | High — real checkout flow |
| 10 | Add search suggestions / autocomplete | Low — UX improvement |
| 11 | Admin analytics dashboard (sales over time, revenue charts) | Medium — business insights |
| 12 | Add social login (Google Sign-In) | Low — easier registration |
| 13 | Implement "Forgot Password" with Firebase email reset | Medium — essential auth feature |
| 14 | Add product reviews (text + rating) stored in Firestore | Medium — trust building |
| 15 | Add address selection + delivery tracking for orders | High — actual e-commerce completion |
