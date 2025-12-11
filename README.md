# paw_around

A new Flutter project.

//Plugins

🏛️ Core App Setup
Purpose	Plugin
State Management	flutter_riverpod
 (or Bloc if you prefer stricter architecture)
Local Database	hive
 + hive_flutter

Authentication	firebase_auth

Backend & Data	firebase_core
, cloud_firestore

Storage (Photos & Files)	firebase_storage
📍 Location & Maps
Purpose	Plugin
Google Maps	google_maps_flutter

Current User Location	geolocator

Places Search (vets, groomers)	google_place
 (uses Google Places API)
📸 Media
Purpose	Plugin
Image Picker	image_picker

Fast Image Loading & Caching	cached_network_image

SVG Icons	flutter_svg
🔔 Notifications
Purpose	Plugin
Push Notifications	firebase_messaging

Local Notifications & Reminders	flutter_local_notifications
📊 Analytics & Crash Reporting
Purpose	Plugin
Analytics	firebase_analytics

Crash Reporting	firebase_crashlytics
💳 Monetization
Purpose	Plugin
Premium Subscriptions / One-time Purchases	in_app_purchase

Ads (optional)	google_mobile_ads
🖌️ UI & UX Helpers
Purpose	Plugin
App Onboarding Screens	introduction_screen

Charts & Stats	fl_chart

Animations (optional)	flutter_animate




// Flow 

Splash / Intro
   ↓
Onboarding (3 slides)
   ↓
Login / Sign Up → Location Permission
   ↓
Home (Bottom Tabs)
   ├─ Dashboard
   ├─ Services Map
   ├─ Lost & Found
   └─ Profile
        ├─ Add/Edit Pet
        └─ Premium Upsell


// My Build Flow

Set up Core

Project structure, theme, Firebase, Hive.

2️⃣ Build Home Dashboard (fully functional)

Pet card (add/edit pet, Hive save).

Upcoming vaccines (local notifications).

Lost & Found preview (Firestore).

Featured services (Google Places).

3️⃣ Services Map

Map view + list toggle + user add service.

4️⃣ Lost & Found / Community Feed

Firestore posts, image upload.

5️⃣ Profile & Settings

Pet profiles list + premium paywall.

6️⃣ Premium Features

In-app purchase, ad-free toggle.
