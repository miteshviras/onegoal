# Design System: Mindful Daily Goal Planner (OneGoal)
**Project ID:** 16722238107092378204

## 1. Visual Theme & Atmosphere

OneGoal embodies a **calm, intentional, behavior-first personal sanctuary** designed to feel like a high-craft human coach rather than an overwhelming corporate task list. The interface prioritizes **breathing room, serene focus, and tangible daily progress**.

The design philosophy is:
- **One Goal. One Day. One Next Step.**
- Never overwhelm users with bloated backlogs or anxiety-inducing notification badges.
- Always guide attention to the single most important actionable step right now.

**Key Aesthetic Principles:**
- Deep, tranquil dark backgrounds (#18181B / #131E3D) with elevated dark surface containers.
- Calibrated focus blue (#1E3A8A / #00236F / #2563EB) signaling deep work and presence.
- Emerald green (#059669 / #10B981) for grounding completion states and peaceful celebration.
- Soft amber (#D97706 / #F59E0B) for gentle warnings without panic.
- Quiet typography using Manrope with high-contrast hierarchical scale.

---

## 2. Color Palette & Functional Roles

### Foundation Colors
- **Dark Graphite Canvas** (`#18181B`) – Deep primary surface and background, avoiding stark pure blacks.
- **Deep Navy Tint** (`#131E3D`) – Brand accent background used for splash screens and adaptive icons.
- **Surface Container Low** (`#1F1F23`) – Floating card container background.
- **Surface Container High** (`#2A2A30`) – Elevated interactive elements, chips, and badge capsules.
- **Dark Outline** (`#757682`) – Subtle borders and secondary metadata.

### Accent & Focus
- **Focus Deep Blue** (`#1E3A8A` / `#00236F`) – Primary action color, mission capsules, and timer progress rings.
- **Vibrant Accent Blue** (`#2563EB`) – Active navigation state and primary interactive focus indicators.
- **Quiet Purple Gradient** (`#7C3AED` to `#4F46E5`) – Reserved strictly for motivation moments, confetti celebration, and Pomodoro focus start triggers.

### Semantic Status
- **Success Emerald** (`#059669` / `#10B981`) – Completed steps, streaks, and peaceful milestones.
- **Soft Amber** (`#D97706` / `#F59E0B`) – Time buffer alerts and gentle pacing indicators.
- **Muted Coral** (`#DC2626` / `#EF4444`) – Low-alarm deletion or destructive confirmation states.

---

## 3. Typography & Hierarchy (Manrope)

- **Headline XL / Hero** (32px–40px, Weight 800, -0.025em letter spacing): Today's Mission & greeting.
- **Headline Large** (24px–28px, Weight 700): Section headers and card titles.
- **Headline Medium** (18px–22px, Weight 600): In-focus step titles.
- **Body Large / Medium** (14px–16px, Weight 400–500): Micro-step descriptions and guidance copy.
- **Label Small / Badges** (11px–12px, Weight 600, 0.04em letter spacing): Status chips, countdowns, and streak counts.
- **Countdown Display** (48px, Weight 800): Focus Pomodoro timer numbers.

---

## 4. Component Geometry & Elevation

- **Pill Badges**: `BorderRadius.circular(24)` for active category chips, mission tags, and primary CTAs.
- **Floating Cards**: `BorderRadius.circular(16)` with subtle outline borders (`#c5c5d3` with 0.15 opacity) and soft black drop shadows (`blurRadius: 12, offset: (0, 4)`).
- **Dialogs & Sheets**: `BorderRadius.circular(20)` to `BorderRadius.circular(24)` with tactile grab handles.
- **Concentric Triple Rings**: Smooth custom painters rendering Mission, Flow, and Evening reflection completion arcs.

---

## 5. UI Optimization Loop Checklist

When auditing and improving screens:
1. **Calm Hierarchy**: Is there exactly one primary focal point on the screen?
2. **Tactile Feedback**: Do buttons trigger subtle haptic vibrations (`HapticFeedback.selectionClick()` / `mediumImpact()`)?
3. **No Overflows**: Are all text labels in Rows wrapped in `Expanded` or `Flexible`?
4. **Preserved State**: Do bottom sheets and dialogs preserve existing user input on configuration changes?
5. **Zero Empty States Without Direction**: Do empty states provide an immediate, inspiring one-tap action?
