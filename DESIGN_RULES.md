# ApexFlow Design Rules

Goal: calm, industrial, premium UI/UX that feels designed by a product designer.

## Layout + Spacing
- Use an 8pt spacing system only (8, 16, 24, 32...).
- Avoid dense horizontal rows on phones; stack under compact breakpoints.
- Ensure no text/button overflow at common phone widths (360-430).

## Shape
- Border radius: 4-6 only for components (e.g. text inputs, buttons, custom panels).
- Card layouts and specialized containers (e.g. `RiderIdCard` and dialog sheets) may use a border radius of 12-16 to ensure a premium, modern feel.
- Avoid floating sections; use full-width bands or simple panels.

## Color + Effects
- No glow, no glassmorphism, no oversized/blurred shadows.
- Use color sparingly; cyan is an accent, not a blanket tint.
- **Rider Card Theme Gradients**: Left-edge highlight borders are used on compact card lists to dynamically project user customization (colors, badges, and tiers) without cluttering.

## Typography
- Use Turkish-compatible fonts across the app (TR glyphs must render correctly).
- Keep hierarchy calm: avoid huge hero blocks inside operational screens.
- Avoid aggressive warning language; prefer neutral guidance.

## Custom Animation & Interactions
- **Pulse Radar Effects**: Used in location-based scanner dialogs (`_NearbyRidersScreen`) to give users immediate feedback during search/sync activities.
- Touch targets should remain usable on small screens.
- Empty states must be purposeful and emotionally neutral.
