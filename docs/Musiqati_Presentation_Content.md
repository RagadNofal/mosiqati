# Musiqati — Presentation Slide Content

**Format:** PowerPoint-ready slide-by-slide content
**Total Slides:** 19 + Q&A Section
**App:** Musiqati (موسيقاتي) — Musical Instruments Store App

---

## Slide 1 — Title Slide

**Title:** Musiqati | موسيقاتي
**Subtitle:** A Mobile E-Commerce App for Musical Instruments in Jordan

**Bullet Points:**
- Built with Flutter & Firebase
- Supports English and Arabic
- Three user roles: Guest, Customer, Admin
- Version 2.0 — Course Project

**Speaker Notes:**
> "Good morning/afternoon everyone. My project is called Musiqati, which means 'My Music' in Arabic. It's a mobile app for a musical instruments store in Jordan. I built it using Flutter for the front end and Firebase for the back end. The app works in both English and Arabic, and it has three types of users: a guest, a registered customer, and a store admin. Let me walk you through how everything works."

**Suggested Screenshot:**
> The app's welcome screen showing the MOSIQATI logo with the gradient background (wine → plum → raspberry), and the three buttons: Guest, Login, Register.

---

## Slide 2 — Project Idea

**Title:** What Is Musiqati?

**Bullet Points:**
- An e-commerce mobile app for a musical instruments store in Jordan
- Customers can browse, search, favorite, and buy instruments
- The store admin manages products and discounts from the same app
- Fully bilingual: English and Arabic with RTL support
- Available on Android (and iOS via Flutter)

**Speaker Notes:**
> "The idea is simple — a music store in Jordan that has no mobile app. Musiqati gives that store a digital presence. Customers can browse all the instruments from their phone, save their favorites, add items to their cart, and place an order. The store owner, or admin, can manage the entire product catalog and create discount coupons right from the same mobile app — there's no separate web dashboard needed. The app works in both English and Arabic, and automatically switches to right-to-left layout for Arabic speakers."

**Suggested Screenshot:**
> The home page showing the hero carousel banner, the category row (Oud, Guitar, Piano, etc.), and a few product cards in the 'Most Popular' section.

---

## Slide 3 — Problem Statement

**Title:** The Problem

**Bullet Points:**
- Musical instrument stores in Jordan have no digital catalog
- Customers must visit in person to check availability and prices
- No way to compare products or save a wishlist
- Store owners rely on phone calls and social media — not efficient
- No easy way to offer promotions or track orders

**Speaker Notes:**
> "The problem I'm solving is that most music stores in Jordan, especially small and medium ones, have no app or website. If you want to know if they have a specific guitar or how much a piano costs, you have to call or go to the store. There's no way to browse, compare, or save products online. And from the store owner's side, there's no easy system to manage inventory or send promotions to customers. Musiqati solves both sides of this problem."

**Suggested Screenshot:**
> Side-by-side: the product details page showing a guitar with full info (name, price, brand, description) — to show what 'organized product info' looks like in the app.

---

## Slide 4 — Target Users

**Title:** Who Is This App For?

**Bullet Points:**
- **Customers:** Music enthusiasts, students, and professional musicians in Jordan
- Age range: roughly 15 to 45 years old
- People who are comfortable shopping on mobile apps
- Arabic and English speakers
- **Store Owner / Admin:** Manages products and promotions from the app
- **Guests:** Anyone who wants to browse without creating an account

**Speaker Notes:**
> "There are three types of people who will use this app. First, customers — these are music lovers, students learning an instrument, or professional musicians who want to shop conveniently from their phone. Second, the store admin, which is the store owner or manager, who uses the app to manage the product catalog and coupons. And third, guests — people who just want to look around without registering. They can browse and even add to cart, but they need to log in to actually place an order."

**Suggested Screenshot:**
> The welcome screen showing all three access options: "Continue as Guest", "Login", and "Register" buttons with the brand gradient background.

---

## Slide 5 — Main Features

**Title:** Key Features

**Bullet Points:**
- Browse products by category (Guitar, Piano, Drums, Oud, Studio)
- Search products by name, model, or brand
- Product details with images, videos, bilingual info, and specs
- Shopping cart with quantity controls and stock limit enforcement
- Coupon / discount code system
- Favorites list (persisted per user in Firestore)
- Order history per user
- In-app notifications
- Light and dark theme
- Arabic / English toggle
- Sound effects and instrument sound previews
- Learn Music interactive guides
- Services screen (maintenance + consultation requests)

**Speaker Notes:**
> "Let me list the main features quickly. The app has a full product catalog with search and filtering, a shopping cart, coupon support, favorites, orders, and in-app notifications. It also has some extra features that improve the experience: sound effects for actions like adding to cart, instrument sound previews when you open a product, a Learn Music section with guides for beginners, and a dark mode and language toggle. I'll go through the most important ones in detail in the next slides."

**Suggested Screenshot:**
> A collage or the home page showing the category filter chips, product grid, and the bottom navigation — to give a visual overview of the app.

---

## Slide 6 — App Roles: Guest, Customer, Admin

**Title:** Three User Roles

| | Guest | Customer | Admin |
|--|-------|----------|-------|
| Browse products | ✓ | ✓ | ✓ |
| View product details | ✓ | ✓ | ✓ |
| Add to cart | ✓ (in-memory) | ✓ (persisted) | — |
| Favorites | ✓ (in-memory) | ✓ (persisted) | — |
| Checkout | ✗ | ✓ | — |
| Order history | ✗ | ✓ | — |
| Manage products | ✗ | ✗ | ✓ |
| Manage coupons | ✗ | ✗ | ✓ |

**Bullet Points:**
- Role stored as `role: 'admin'` or `role: 'customer'` in Firestore user document
- App reads role on login and routes accordingly
- Admin → Admin Dashboard; Customer → Home Screen
- Guest uses the app without any login

**Speaker Notes:**
> "The app has three roles. A guest can browse and add to cart, but their data is not saved — if they close the app, the cart is gone. A customer gets everything saved to Firestore — favorites, cart, and orders all persist. An admin gets a different home screen: the Admin Dashboard. The role is stored in a Firestore user document as either 'admin' or 'customer'. When someone logs in, the app reads their role and routes them to the right screen automatically."

**Suggested Screenshot:**
> Show the Admin Dashboard on one side and the Customer Home Screen on the other — to visually contrast the two role experiences.

---

## Slide 7 — Customer Flow

**Title:** How a Customer Uses the App

**Bullet Points:**
1. Open app → Welcome Screen (Guest / Login / Register)
2. Register or login → routed to Home Screen
3. Browse products by category or search
4. Open product detail → view info, images, video, add to favorites
5. Add to cart → manage quantities, apply coupon
6. Proceed to checkout → confirm order dialog
7. Order confirmed → order saved to Firestore, cart cleared
8. View order history → My Orders screen

**Speaker Notes:**
> "This is the typical flow for a customer. They start at the welcome screen and choose to log in or register. After that they land on the home page where they can browse by category or search. They can open a product to see full details — there are images, an optional video, specifications, and they can add it to favorites or to the cart. In the cart they can adjust quantities and enter a coupon code for a discount. When they're ready, they tap checkout, confirm the order in a dialog, and the order is saved to Firestore. They can then see that order in their My Orders history."

**Suggested Screenshot:**
> A sequence: Home page → Product detail page → Cart screen with a coupon applied → Order confirmation snackbar.

---

## Slide 8 — Admin Flow

**Title:** How the Admin Uses the App

**Bullet Points:**
1. Login with admin account → routed directly to Admin Dashboard
2. View stats: Total Products, Low Stock, Out of Stock, Active Coupons
3. Tap low-stock card → see list of low-stock products
4. Add new product → fill bilingual form, add image URLs, save
5. Edit or disable/enable existing product
6. Navigate to Manage Coupons → add, edit, activate/deactivate, delete coupons
7. Can go back to the store as a customer via profile link

**Speaker Notes:**
> "For the admin, after logging in they go straight to the Admin Dashboard. The first thing they see is a stats overview — how many products are in the system, how many are low on stock, how many are out of stock, and how many active coupons there are. They can tap any stat card to see the specific products. From there they can add a new product by filling in a detailed form — everything is bilingual, they fill in the English and Arabic names and descriptions. They can also manage coupons, setting discount types, minimum order amounts, and validity dates."

**Suggested Screenshot:**
> The Admin Dashboard screen showing the stats cards and the product list below, with the two FABs visible (Add Product and Manage Coupons).

---

## Slide 9 — Firebase and Database Structure

**Title:** Firebase & Data Structure

**Bullet Points:**
- **Firebase Auth:** Email/Password login and registration
- **Cloud Firestore:** NoSQL database (all app data)
- **Firebase Storage:** Not active (Spark/free plan limitation)

**Firestore Collections:**
```
users/{uid}
  └── favorites/{productId}
  └── cart/{productId}
products/{productId}
orders/{orderId}
coupons/{couponId}
```

**Speaker Notes:**
> "I'm using two Firebase services: Authentication for login and registration, and Cloud Firestore as the database. Firebase Storage is in my pubspec.yaml but it's not active because it requires upgrading to the paid plan — I'll explain the workaround in a later slide. For the database structure, I have five main areas. The 'users' collection stores user profiles, and each user has two subcollections: 'favorites' for their saved products, and 'cart' for their persisted cart items. Then there's 'products' for the product catalog, 'orders' for purchase history, and 'coupons' for discount codes."

**Suggested Screenshot:**
> A screenshot of the Firebase Console showing the Firestore collections list — or draw a simple diagram of the collection structure on the slide.

---

## Slide 10 — Product Management

**Title:** Product Management (Admin)

**Bullet Points:**
- Products stored in Firestore `products` collection
- Customer view: only `isAvailable: true` products shown (real-time stream)
- Admin view: all products, including unavailable ones
- Fallback: if Firestore is empty or offline, 10 static products load from a local JSON file
- Admin actions: Add, Edit, Enable/Disable, Delete
- Stock badges: Available / Low Stock (≤5) / Out of Stock / Unavailable

**Speaker Notes:**
> "Products are stored in Firestore. For customers, only products where 'isAvailable' is true are shown — these update in real-time, so if the admin adds or disables a product, it appears or disappears for customers immediately without refreshing the app. The admin sees all products including disabled ones. I also built a fallback: if Firestore is empty or there's no internet, the app loads 10 products from a JSON file bundled inside the app. This means the app shows something useful even offline."

**Suggested Screenshot:**
> The Admin Dashboard product list with the colored stock badges (green = Available, orange = Low Stock, red = Out of Stock) and the Edit/Disable/Delete buttons.

---

## Slide 11 — Cart and Quantity Logic

**Title:** Cart and Quantity Logic

**Bullet Points:**
- Each item stored as: product + quantity
- Rules: quantity capped at stock level; adding at limit is ignored
- When last unit removed: cart entry deleted, coupon auto-cleared
- Guest cart: in-memory only (cleared on app restart)
- Customer cart: persisted in Firestore `users/{uid}/cart/`
- Checkout uses Firestore **atomic transaction** to:
  - Re-validate stock
  - Re-validate coupon
  - Deduct stock
  - Increment coupon usage count
  - Save order document

**Speaker Notes:**
> "The cart has some important logic built in. First, you can never add more items than what's in stock — the plus button is greyed out when you reach the limit. If you remove the last item from the cart, any coupon you applied is automatically removed too. For logged-in customers, the cart is saved to Firestore, so if they close the app and come back, their cart is still there. When they checkout, I use a Firestore transaction — this is important because it checks stock and coupon validity one more time at the moment of purchase to prevent race conditions, like two people buying the last unit at the same time."

**Suggested Screenshot:**
> The cart screen showing items with the quantity stepper (+/-), the "At Stock Limit" label, and the coupon input field at the bottom.

---

## Slide 12 — Coupons and Offers

**Title:** Coupons and Discount System

**Bullet Points:**
- Two discount types: Percentage (%) and Fixed amount (JOD)
- Coupon rules: minimum order amount, optional maximum discount cap, date range, usage limit
- Status: Active / Expired / Not Started / Limit Reached / Inactive
- Admin creates and manages coupons from the app
- Customer enters code in cart or taps "Apply in Cart" from Offers screen
- Validation happens both client-side and inside the checkout transaction

**Coupon Error States:**
- Coupon not found, Cart empty, Already expired, Not yet started, Usage limit reached, Minimum order not met

**Speaker Notes:**
> "The coupon system supports two types of discounts: a percentage discount like 10% off, or a fixed amount like 5 JOD off. The admin can set rules like a minimum order amount — for example, 'must spend at least 50 JOD to use this code'. They can also set an expiry date, a maximum number of uses, and a cap on the maximum discount for percentage coupons. The Offers screen shows all active coupons so customers can browse them and apply directly to their cart. The coupon is validated twice: once when the customer enters the code, and again inside the checkout transaction to prevent any issues at the last moment."

**Suggested Screenshot:**
> The Offers screen showing a coupon card with the gradient discount badge, coupon code, description, "Copy Code" and "Apply in Cart" buttons.

---

## Slide 13 — Notifications

**Title:** In-App Notifications

**Bullet Points:**
- In-app notification system (not push notifications)
- 4 pre-seeded notifications: Offer, Order update, Reminder, Message
- Notifications shown as a list with: icon, title, body, time, unread dot
- Features: mark as read (tap), mark all as read, swipe-to-dismiss, clear all
- Unread count shown as badge on bell icon in home app bar
- Time shown relative: "Just now", "X min ago", "X h ago", "Yesterday"
- Bilingual: notifications show in the current app language

**Speaker Notes:**
> "The notification system is in-app only — there are no push notifications because that requires Firebase Cloud Messaging which I didn't integrate. What I built is an in-memory notification list that's pre-loaded with 4 example notifications when the app starts. These represent common scenarios: a new offer, an order update, a reminder, and a store message. Users can tap a notification to mark it as read, swipe it left to delete it, or mark all as read at once. The bell icon in the app bar shows a badge with the unread count. This is a functional UI system but it resets every time the app is restarted — noted as a limitation."

**Suggested Screenshot:**
> The notifications screen showing the list with one unread notification highlighted (the animated colored border) and one read notification, plus the bell badge on the home app bar.

---

## Slide 14 — Profile, Favorites, and Orders

**Title:** Profile, Favorites & Order History

**Bullet Points:**

**Favorites:**
- Toggle heart icon on any product or in product details
- Guest: in-memory only
- Customer: persisted to Firestore subcollection `users/{uid}/favorites/`
- Favorites screen: 2-column grid, add to cart from card, sound plays on empty state

**Orders:**
- Created atomically during checkout
- Stored in Firestore `orders/` with userId, items, totals, coupon code, status
- My Orders screen: real-time stream filtered by current user
- Shows order ID, date, item count, subtotal, discount, total

**Profile:**
- Photo: picked from gallery, stored locally (SharedPreferences) — not uploaded
- Edit profile: name, phone, address
- Achievements badges: Music Lover, First Purchase, Sound Explorer
- Quick links: Favorites, Orders, Language, Theme, Sound, Logout

**Speaker Notes:**
> "Favorites are saved per user in Firestore, so they persist between sessions. Guests can still use favorites but they'll disappear when the app is closed. Orders are saved to Firestore during the checkout transaction, and the My Orders screen reads them in real-time. The profile page has a collapsible header with the user's photo, name, email, and role badge. The photo is picked from the phone's gallery — I couldn't upload it to Firebase Storage because of the plan limitation, so I save the file path locally using SharedPreferences. This means the photo works on the same device but won't sync to other devices."

**Suggested Screenshot:**
> Show the Profile screen with the avatar, role badge, stats (favorites/cart count), and the Quick Links section visible.

---

## Slide 15 — UI/UX Design

**Title:** UI/UX Design Choices

**Bullet Points:**
- Custom color palette: Raspberry, Plum, Wine, Gold, Sage
- Material Design 3 with custom theme overrides
- Light mode: cream background, white cards
- Dark mode: deep wine-black background, plum cards
- Smooth animations: FadeTransition, SlideTransition on screen entry
- Collapsible SliverAppBar headers on main screens
- Staggered list animations for products and notifications
- RTL-aware layouts for Arabic (icon positions, padding flipped)
- Bouncing scroll physics for natural feel
- Haptic feedback on key actions (add to cart, favorite, checkout)
- Bilingual text throughout, no mixed languages in a single widget

**Speaker Notes:**
> "For the design, I built a custom color palette around deep music-inspired colors — raspberry pink for primary actions, wine red for backgrounds, gold for prices and highlights, and sage green for success states. The app supports both light and dark modes. I used Flutter's Material Design 3 as the base and customized it heavily. All screens have entrance animations — a fade and slide transition when the screen loads. The product lists have staggered animations so cards appear one by one instead of all at once. And for Arabic users, the entire layout flips to right-to-left, including icon positions in cards."

**Suggested Screenshot:**
> Side by side: the home screen in light mode and dark mode — or the product card showing the gold price badge and the gradient add-to-cart button.

---

## Slide 16 — Testing

**Title:** Testing Approach

**Bullet Points:**
- Manual testing on Android emulator and physical device
- `device_preview` package used to test different screen sizes
- Scenarios tested:
  - Authentication: register, login, guest mode, logout, wrong password
  - Cart: add, remove, quantity limits, empty cart, coupon auto-clear
  - Coupons: valid, expired, wrong code, empty cart, minimum order
  - Admin: add product, disable product, add coupon, delete coupon
  - Persistence: logout and login, check favorites and cart restore
  - Checkout: atomic transaction, stock deduction, order saved
  - Language: toggle EN/AR, RTL layout checks
  - Theme: toggle light/dark

**Speaker Notes:**
> "I tested the app manually by going through all the key user flows. I used an Android emulator and a physical device. I also used the `device_preview` package which lets me see the app layout on different phone sizes without needing multiple devices. The most important tests were around the cart and coupon logic — making sure edge cases like adding a product at stock limit, applying a coupon to an empty cart, or trying to checkout as a guest all show the correct behavior. I also tested the Firestore persistence by logging out and back in to confirm that favorites and cart items were correctly restored."

**Suggested Screenshot:**
> The app running with `device_preview` showing multiple device frames — or show a simple before/after: the cart with a coupon applied, then after checkout, My Orders showing the new order.

---

## Slide 17 — Challenges and Solutions

**Title:** Challenges I Faced

**Bullet Points:**

**Challenge 1: Firebase Storage not available (Spark plan)**
→ Solution: Product images as public URLs; profile photo stored locally via SharedPreferences

**Challenge 2: Category filter causing red error widget**
→ Solution: Moved Provider calls outside setState() to avoid notifyListeners during build

**Challenge 3: View All showing filtered products**
→ Solution: Added a separate `allProducts` getter that bypasses the active filter

**Challenge 4: Coupon applied to empty cart**
→ Solution: Added empty-cart guard in applyCoupon(); auto-clear coupon when cart empties

**Challenge 5: Cart loading before products arrive**
→ Solution: Store full product snapshot in Firestore cart document; prefer live product, fall back to snapshot

**Speaker Notes:**
> "I faced several challenges during development. The biggest one was Firebase Storage not being available on the free plan. I solved this by having admins enter image URLs and saving profile photos locally. Another tricky bug was a red error widget that appeared for one frame when filtering products — it was caused by calling notifyListeners during a Flutter build cycle. Moving the provider calls before setState fixed it. There was also an issue with the View All screen showing only filtered products instead of all of them — I fixed that by adding a separate getter in ProductProvider. And I had to add a guard to prevent applying coupons to an empty cart."

**Suggested Screenshot:**
> Show the product details page with a product image loaded from a URL, and the admin product form showing the "Image URL" input field — to visually show the URL-based image solution.

---

## Slide 18 — Future Work

**Title:** What I Would Add Next

**Bullet Points:**
1. **Firebase Storage** (upgrade to Blaze plan) — proper image uploads for products and profiles
2. **Push notifications** via Firebase Cloud Messaging — real-time order updates
3. **Order status management** for admin (Pending → Shipped → Delivered)
4. **Payment gateway** (PayTabs or ClickPay for Jordan) — actual online payments
5. **Persist notifications** in Firestore — survive app restarts
6. **Product reviews** — text + star rating stored in Firestore
7. **Save language + theme** preferences in SharedPreferences
8. **Forgot Password** flow using Firebase password reset email
9. **Admin analytics** — sales charts, revenue over time
10. **Service requests backend** — connect maintenance/consultation forms to Firestore

**Speaker Notes:**
> "If I had more time — or after upgrading the Firebase plan — these are the things I would add. The most important ones are Firebase Storage for proper image uploads, push notifications so customers get real updates, and a payment gateway so the checkout actually processes a real payment. Order status management is also important — right now orders are always 'pending', the admin can't mark them as shipped or delivered. I'd also fix smaller things like saving the language and theme preferences so they don't reset every time the app opens."

**Suggested Screenshot:**
> The My Orders screen showing the order cards with status badges — to highlight the 'order status management' as a future improvement that's visually present but not fully functional.

---

## Slide 19 — Conclusion

**Title:** Summary

**Bullet Points:**
- Musiqati is a fully functional Flutter e-commerce app for a Jordanian music store
- Built with Flutter 3.41.9, Dart 3.11.5, Firebase Auth + Firestore
- Three roles: Guest, Customer, Admin — all managed in one app
- Real-time product catalog, full cart + coupon system, order history
- Favorites and cart persisted per user in Firestore
- Bilingual (EN/AR) with RTL support and light/dark themes
- Main limitation: Firebase Storage not used — images are URLs, profile photos are local
- Multiple areas for future improvement identified

**Speaker Notes:**
> "To summarize: Musiqati is a complete mobile e-commerce app for a musical instruments store in Jordan. It's built with Flutter and Firebase, supports English and Arabic with RTL, and has three user roles all handled in one app. The key technical achievements are the real-time Firestore product stream, the atomic checkout transaction, the per-user Firestore persistence for cart and favorites, and the bilingual layout with RTL support. The main limitation is that Firebase Storage is not active, which means product images are entered as URLs and profile photos are only stored locally. I have a clear list of improvements that would make this production-ready. Thank you."

**Suggested Screenshot:**
> The app's home screen in both light and dark mode side by side — or the welcome screen as a clean final visual.

---

---

# Possible Committee Questions and Answers

---

**Q1. Why did you choose Flutter for this project?**
> Flutter lets me build one app that works on both Android and iOS using the same code. It also has a rich set of widgets and it's fast — the UI is rendered using its own engine, so it looks the same on all devices. For a course project, it was a practical choice to save time while still producing a professional-looking app.

---

**Q2. Why did you use Firebase instead of a custom backend?**
> Firebase gives me Authentication, a real-time database, and hosting — all managed by Google with no server setup needed. For a student project, this is ideal because I don't need to write backend code or manage a server. Firestore also provides real-time data syncing, which means product changes by the admin appear instantly for customers.

---

**Q3. How does the app know if a user is an admin or a customer?**
> When a user registers, their account is created in Firebase Auth and a document is also written to the Firestore `users` collection with `role: 'customer'`. If I want to make someone an admin, I go into the Firebase Console and manually change that field to `role: 'admin'`. When someone logs in, the app reads their user document and checks the role field — admins are sent to the Admin Dashboard, customers to the Home Screen.

---

**Q4. What can the admin do in the app?**
> The admin has access to the Admin Dashboard. From there they can: view product stats (total, low stock, out of stock), add new products with full bilingual details, edit existing products, enable or disable product visibility, delete products, add and manage discount coupons (create, edit, activate/deactivate, delete), and see how many active coupons and notifications exist.

---

**Q5. What can a customer do?**
> A customer can browse all available products, filter by category, search by name or brand, view full product details (images, video, specs), add products to their cart, save favorites, apply coupon codes, complete checkout, and view their order history. Their cart and favorites are saved to Firestore and restored every time they log back in.

---

**Q6. What can a guest do?**
> A guest can browse all available products, search, filter, view product details, add to cart, and use favorites. The difference is that none of their data is saved — the cart and favorites only exist in memory while the app is open. If they try to checkout, a dialog appears asking them to log in.

---

**Q7. Where are the products stored?**
> Products are stored in Cloud Firestore in a collection called `products`. Each document has all the product fields including bilingual names, price, stock quantity, image URLs, and an `isAvailable` flag. There's also a fallback: if Firestore is empty or the device is offline, the app loads 10 products from a static JSON file bundled inside the app.

---

**Q8. How does the category filter work?**
> On the home page there's a horizontal row of category chips (Oud, Guitar, Piano, etc.). When you tap one, `ProductProvider.filterByCate(key)` is called, which filters the product list to only show products where `category == key`. Tapping the same category again clears the filter and shows all products. The filter does not affect the "View All Products" screen which always shows the full list.

---

**Q9. How does the cart quantity logic work?**
> Each cart entry has a product reference and a quantity number. When you tap the + button, quantity goes up by 1. When you tap -, it goes down by 1. If quantity reaches 0, the item is removed from the cart. The quantity can never go above the product's stock level — the + button is disabled and a "At Stock Limit" label appears. Adding an out-of-stock product is silently ignored.

---

**Q10. What happens if the stock runs out while a product is in someone's cart?**
> The cart itself doesn't automatically update if stock changes. However, when the user tries to checkout, the Firestore transaction re-reads the live stock quantities. If the stock is now insufficient, a `CheckoutException` is thrown and the user sees an error like "Only 1 unit left for [product name]." The order is not placed.

---

**Q11. How do coupons work?**
> The customer types a coupon code in the cart screen and taps Apply. The app queries Firestore to find the coupon by code (case-insensitive). It then checks if the coupon is active, not expired, not past its usage limit, and if the cart subtotal meets the minimum order amount. If all checks pass, the discount is applied. During checkout, all of this is re-validated inside the atomic Firestore transaction to prevent abuse.

---

**Q12. What are the two discount types for coupons?**
> Percentage — for example, 10% off. If there's a maximum cap, the discount won't exceed that amount. Fixed — for example, 5 JOD off the total. In both cases, the discount can never exceed the cart subtotal (you can't get a negative total).

---

**Q13. Why are product images entered as URLs instead of being uploaded?**
> Firebase Storage requires the Firebase Blaze (paid) plan. My Firebase project is on the Spark (free) plan, so Storage is not available. As a workaround, the admin enters a public image URL when adding a product. The app then loads the image using `Image.network()`. The `firebase_storage` package is already in `pubspec.yaml` for when the plan is upgraded.

---

**Q14. How is the profile photo handled?**
> The user picks a photo from their device gallery using the `image_picker` package. The file path of the selected image is saved to `SharedPreferences` with a key that includes the user's UID. The app loads the image using `Image.file()`. This means the photo is only stored on that specific device — it's not uploaded to any server. If the user switches devices, they need to pick the photo again.

---

**Q15. How does the checkout transaction work?**
> When the user confirms checkout, `FirestoreService.checkout()` runs a Firestore transaction. In a single atomic operation, it reads all product documents, checks stock levels, re-validates the coupon if one is applied, deducts the purchased quantity from each product's stock, increments the coupon's `usedCount`, and writes a new order document. If any step fails — like insufficient stock — the entire transaction is rolled back and an error is shown.

---

**Q16. What is the difference between `productList` and `allProducts` in ProductProvider?**
> `productList` returns the filtered list — if a category is selected on the home page, it returns only products in that category. `allProducts` always returns the full unfiltered list. The "View All Products" screen uses `allProducts` to make sure it always shows everything regardless of what filter is active on the home page.

---

**Q17. How are notifications implemented?**
> Notifications are in-app only — no Firebase Cloud Messaging or push notifications. The `NotificationsProvider` is initialized with 4 hardcoded notification objects when the app starts. These are shown in the Notifications screen. The system supports marking as read, swipe to dismiss, and mark all as read. The limitation is that these 4 notifications re-appear every time the app is restarted because they're not saved anywhere.

---

**Q18. Why are notifications not persisted?**
> This is a known limitation. To persist notifications, I would need to either store them in Firestore per user, or use local storage. I focused on the core e-commerce features first. Adding notification persistence is listed as a future improvement.

---

**Q19. How does the app support Arabic and English?**
> I built a custom localization system in `app_localizations.dart`. It holds two maps — one for English, one for Arabic. Every string in the app is looked up using `l.t('key')` which returns the correct translation for the current locale. If a key is missing, the key itself is returned as a fallback so the app never crashes. The `LocaleProvider` handles switching between `Locale('en')` and `Locale('ar')`. Flutter's built-in RTL support automatically flips the layout when Arabic is selected.

---

**Q20. How does the RTL layout work for Arabic?**
> Flutter automatically mirrors the layout direction when the locale is set to Arabic. I also added manual checks in places where I needed fine control — for example, `Directionality.of(context) == TextDirection.rtl` is used in product cards to decide which corner to put the category badge or favorite button in. The gradient directions and padding values are also adjusted in some places for a proper RTL feel.

---

**Q21. How are orders stored in Firestore?**
> Each order is a document in the `orders` collection with fields: `userId`, `items` (a map of productId → quantity), `subtotal`, `couponCode`, `discountAmount`, `total`, `status` (always 'pending' currently), and `createdAt` timestamp. The `MyOrdersScreen` queries this collection filtered by the current user's UID, sorted by date.

---

**Q22. Can the admin change the order status?**
> Not in the current version. All orders are written with status 'pending' and there's no UI for the admin to update them. The order status badges in My Orders support pending/completed/cancelled visually, but in practice they'll always show 'pending'. This is listed as a future improvement.

---

**Q23. How does the app sound system work?**
> `SoundProvider` uses the `audioplayers` package with a single `AudioPlayer` instance. There are two categories: UI sounds (like adding to cart, applying a coupon, empty cart) and instrument sounds (guitar, piano, drums). Each action maps to a specific MP3 file in the `assets/audio/` folder. The user can toggle sounds on/off from the profile page, and that setting is saved with `SharedPreferences`.

---

**Q24. What happens when you open a product details page?**
> After the screen builds, `WidgetsBinding.addPostFrameCallback` fires and calls `_playProductSound()`. This checks the product's category and plays the appropriate instrument sound — a guitar chord for guitar products, a piano chord for piano products, a drum loop for drums, and for oud products it gives haptic feedback only (no audio file mapped). Studio products play a generic click sound.

---

**Q25. How is state managed in this app?**
> I used the Provider pattern with `ChangeNotifier`. There are 7 providers registered in `MultiProvider` at the top of the app: `AppAuthProvider`, `ProductProvider`, `CartProvider`, `NotificationsProvider`, `SoundProvider`, `ThemeProvider`, and `LocaleProvider`. Screens use `context.watch<T>()` to rebuild when state changes and `context.read<T>()` for one-time reads without rebuilding.

---

**Q26. How does the cart persist between sessions for logged-in users?**
> Every time the cart changes (item added, removed, quantity changed), a background write is made to Firestore at `users/{uid}/cart/{productId}`. This stores a snapshot of the product data and quantity. When the user logs back in, `CartProvider.loadCartFromFirestore()` reads that subcollection and rebuilds the cart. After a successful checkout, `clearUserCart()` deletes all those documents.

---

**Q27. How does the `_AuthSync` widget work?**
> `_AuthSync` is a `StatefulWidget` that sits just below the `MultiProvider` in the widget tree. It listens to `AppAuthProvider` for any changes. Whenever the user logs in or out, it calls `ProductProvider.setCurrentUid()` and `CartProvider.setCurrentUid()` with the new UID. These providers then load or clear their Firestore data accordingly. This keeps all three providers synchronized without tight coupling.

---

**Q28. What is the static JSON fallback?**
> There's a file at `assets/get-products.json` that contains 10 pre-defined products (guitars, pianos, oud, drums, studio equipment). If Firestore returns an empty list or the device is offline, `ProductServices.fetchProducts()` loads this file using Flutter's `rootBundle`. These products have `isFirestoreBacked = false`, so they're excluded from the stock deduction during checkout.

---

**Q29. Why does the app have a Services screen?**
> The Services screen provides a UI for customers to request maintenance or book a consultation for their instrument. It has input fields for instrument type, issue description, contact info, and preferred time. However, this screen is UI-only — the form data is not saved anywhere because I didn't build a backend for it yet. It's listed as a future improvement to connect it to Firestore.

---

**Q30. What are the main limitations of the current app?**
> The main limitations are:
> 1. Firebase Storage is not used — product images are URLs, profile photos are local only
> 2. No push notifications — notifications are pre-seeded in-memory and reset on restart
> 3. Order status is always 'pending' — no admin update flow
> 4. Product ratings are in-memory — not saved to Firestore
> 5. Language and theme settings reset on app restart
> 6. No password reset functionality
> 7. Services screen form data is not saved anywhere

---

**Q31. How does the coupon copy-and-apply flow on the Offers screen work?**
> On the Offers screen, each active coupon has two buttons. "Copy Code" uses the Flutter Clipboard to copy the coupon code to the device clipboard and shows a snackbar confirmation. "Apply in Cart" directly calls `CartProvider.applyCoupon(code)`, plays the appropriate sound (success or error), shows a snackbar, and if the coupon was applied successfully, automatically navigates the user to the Cart screen.

---

**Q32. How does the bilingual product model work?**
> The `FirestoreProduct` model has separate EN and AR fields for every text property: `nameEn`/`nameAr`, `descriptionEn`/`descriptionAr`, `brandEn`/`brandAr`, etc. Helper methods like `displayName(lang)` return the right field based on the current language code. The `Result` model (for static JSON products) uses lookup tables like `_arNames` and `_arBrands` that map product IDs and brand names to their Arabic equivalents.

---

**Q33. What is `device_preview` and how was it used?**
> `device_preview` is a Flutter package that wraps your app in a simulated device frame. It lets you switch between different phone models, screen sizes, and orientations without running multiple emulators. I used it during development to check that the layouts looked correct on both small and large phones and to test the RTL layout without switching the system language.

---

**Q34. Is there a settings screen separate from the profile page?**
> Yes, there is a `settings_screen.dart` in the project. It contains language, theme, and sound controls — the same controls that are also accessible from the Quick Links section of the Profile page. It provides an alternative entry point to these settings.

---

**Q35. How does the Learn Music section work?**
> The Learn Music screen has 7 interactive guide cards: Guitar Basics, Piano Basics, Oud Basics, Drums and Rhythm, Music Theory, Tuning Tips, and Practice Routine. Tapping any card opens a `DraggableScrollableSheet` — a bottom sheet that slides up and can be dragged between 55% and 85% of the screen height. Inside is bilingual instructional text in both English and Arabic. The screen also has a YouTube links section and a website resources section that open in the device's browser.

---
