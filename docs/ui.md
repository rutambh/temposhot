# UI & 3D Tactile Design System — TempoShot

## Color Palette
| Token | Hex Value | Usage |
|---|---|---|
| `bg` | `#18181B (Range Polymer Matte)` | Core UI Token |
| `card` | `#27272A` | Core UI Token |
| `accent` | `#EAB308 (Tactical Yellow)` | Core UI Token |
| `lcd_backlight` | `#84CC16 (High-Contrast LCD Green)` | Core UI Token |
| `lcd_digits` | `#14532D (Deep LCD Segment Phosphor)` | Core UI Token |

## 3D Tactile & Skeuomorphic Components
- **Main 3D Visualizer**: `TactileTimerChassis3D (polymer hex-bolted bezel), BacklitLcdDisplay3D (embossed segmented LCD with glass glare), AudioEnvelopeOscilloscope3D, TactilePusherButton3D`
- **Design Philosophy**: High physical realism, depth extrusion, realistic ray-traced shadows, metallic/glass bevels, and tactile button depression on touch.

## Touch Target & Accessibility Standards
- Minimum touch target: `48dp x 48dp` (primary controls: `64dp`).
- High contrast compliant with WCAG AAA for dark/light themes.
- Reduced-motion support with snappy feedback transitions (< 150ms).
