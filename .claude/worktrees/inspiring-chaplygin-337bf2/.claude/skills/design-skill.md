---
name: mobile-app-design
description: Design and build production-grade mobile app UIs using React Native, Expo, or Flutter. Use this skill whenever the user wants to create, prototype, or improve a mobile app interface — including screens, navigation flows, components, onboarding, tab bars, bottom sheets, or any native mobile UI. Trigger on mentions of "mobile app", "React Native", "Expo", "Flutter", "iOS", "Android", "app screen", "app design", or requests to make a UI that runs on a phone. Also trigger when user wants to convert a web design to mobile, build a cross-platform app, or create a polished app prototype.
---

# Mobile App Design Skill

Guides creation of production-grade, visually distinctive mobile app UIs. Covers React Native/Expo (primary) and Flutter. Avoid generic app templates — every app should have a clear visual identity.

## Step 1: Understand the App

Before writing any code, clarify:

- **Platform target**: iOS only, Android only, or cross-platform?
- **Tech stack**: React Native + Expo (default), bare React Native, or Flutter?
- **Screen/feature scope**: Single screen, a flow, or full app skeleton?
- **Design vibe**: Reference apps? Brand colors? Dark/light?
- **State management needs**: Local state, Zustand, Redux, or none?

If the user hasn't specified a stack, **default to Expo (managed workflow)** — it's the fastest path to a working prototype.

---

## Step 2: Choose a Design Direction

Commit to a clear aesthetic before coding. Mobile design has distinct flavors:

| Direction | Characteristics | Good for |
|---|---|---|
| **iOS Native-ish** | SF Pro, blur effects, clean whitespace | Productivity, finance, health |
| **Material You** | Dynamic color, rounded cards, elevation | Android-first, social, tools |
| **Dark & Moody** | Deep backgrounds, neon accents, glow | Gaming, music, crypto |
| **Soft & Minimal** | Pastel palette, generous padding, subtle shadows | Wellness, journaling, lifestyle |
| **Bold Editorial** | Strong type, high contrast, grid-breaking | Media, news, portfolio |
| **Glassmorphism** | Frosted panels, gradients, blur overlays | Modern SaaS, dashboards |

**Pick one direction and execute it with full commitment.** Avoid mixing aesthetics.

---

## Step 3: Stack-Specific Implementation

### React Native + Expo (default path)

**Styling**: Use `StyleSheet.create()` for performance. Use `styled-components/native` for complex theming.

**Key packages** (all Expo-compatible):
```bash
npx expo install expo-router           # File-based navigation (preferred)
npx expo install expo-linear-gradient  # Gradients
npx expo install expo-blur             # Blur effects (iOS native quality)
npx expo install expo-haptics          # Tactile feedback
npx expo install react-native-reanimated # Smooth animations (60fps)
npx expo install react-native-gesture-handler
npx expo install @shopify/flash-list   # High-perf lists (replace FlatList)
npx expo install expo-font @expo-google-fonts/inter  # Custom fonts
```

**Navigation structure** (expo-router):
```
app/
├── _layout.tsx          # Root layout (fonts, theme)
├── (tabs)/
│   ├── _layout.tsx      # Tab bar config
│   ├── index.tsx        # Home tab
│   ├── explore.tsx
│   └── profile.tsx
├── modal.tsx            # Modal screen
└── [id].tsx             # Dynamic route
```

**Theme setup pattern**:
```tsx
// constants/theme.ts
export const theme = {
  colors: {
    primary: '#6C63FF',
    background: '#0A0A0F',
    surface: '#16161F',
    surfaceAlt: '#1E1E2E',
    text: '#F0F0FF',
    textMuted: '#8888AA',
    accent: '#FF6B9D',
    border: 'rgba(255,255,255,0.08)',
  },
  spacing: { xs: 4, sm: 8, md: 16, lg: 24, xl: 32, xxl: 48 },
  radius: { sm: 8, md: 12, lg: 16, xl: 24, full: 9999 },
  fonts: { regular: 'Inter_400Regular', medium: 'Inter_500Medium', bold: 'Inter_700Bold' },
}
```

**Safe area handling** (always required):
```tsx
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';
// Wrap root in SafeAreaProvider
// Use SafeAreaView or useSafeAreaInsets() in screens
```

**Animation patterns** (Reanimated 2):
```tsx
import Animated, { FadeInDown, FadeInUp, SlideInRight } from 'react-native-reanimated';

// Staggered list entrance
{items.map((item, i) => (
  <Animated.View key={item.id} entering={FadeInDown.delay(i * 80).springify()}>
    <ItemCard item={item} />
  </Animated.View>
))}
```

### Flutter (when requested)

Read `references/flutter.md` for Flutter-specific patterns and widget conventions.

---

## Step 4: Component Patterns

### Bottom Sheet
```tsx
// Use @gorhom/bottom-sheet
import BottomSheet, { BottomSheetView } from '@gorhom/bottom-sheet';
const snapPoints = useMemo(() => ['40%', '75%'], []);
```

### Tab Bar (custom styled)
```tsx
// In expo-router tabs layout
<Tabs screenOptions={{
  tabBarStyle: {
    backgroundColor: theme.colors.surface,
    borderTopColor: theme.colors.border,
    height: 60 + insets.bottom,
  },
  tabBarActiveTintColor: theme.colors.primary,
  tabBarInactiveTintColor: theme.colors.textMuted,
}} />
```

### Card Component
```tsx
const Card = ({ children, style }) => (
  <View style={[styles.card, style]}>
    {children}
  </View>
);

const styles = StyleSheet.create({
  card: {
    backgroundColor: theme.colors.surface,
    borderRadius: theme.radius.lg,
    padding: theme.spacing.md,
    borderWidth: 1,
    borderColor: theme.colors.border,
    // iOS shadow
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 12,
    // Android shadow
    elevation: 4,
  }
});
```

### Pressable with haptics
```tsx
import * as Haptics from 'expo-haptics';

const HapticButton = ({ onPress, children, style }) => (
  <Pressable
    onPress={() => {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      onPress?.();
    }}
    style={({ pressed }) => [
      styles.button,
      pressed && { opacity: 0.75, transform: [{ scale: 0.97 }] },
      style
    ]}
  >
    {children}
  </Pressable>
);
```

---

## Step 5: Screen Design Principles

### Typography scale
```tsx
const typography = {
  largeTitle: { fontSize: 34, fontFamily: theme.fonts.bold, letterSpacing: -0.5 },
  title1:     { fontSize: 28, fontFamily: theme.fonts.bold, letterSpacing: -0.3 },
  title2:     { fontSize: 22, fontFamily: theme.fonts.bold },
  title3:     { fontSize: 20, fontFamily: theme.fonts.medium },
  headline:   { fontSize: 17, fontFamily: theme.fonts.medium },
  body:       { fontSize: 17, fontFamily: theme.fonts.regular },
  callout:    { fontSize: 16, fontFamily: theme.fonts.regular },
  subhead:    { fontSize: 15, fontFamily: theme.fonts.regular },
  footnote:   { fontSize: 13, fontFamily: theme.fonts.regular },
  caption:    { fontSize: 12, fontFamily: theme.fonts.regular },
}
```

### Spacing rhythm
- Screen horizontal padding: **16–20px**
- Section gaps: **24–32px**
- Card internal padding: **16px**
- List item height: **56–72px** (thumb-friendly)
- Touch targets: **minimum 44×44px** (Apple HIG), **48×48dp** (Material)

### Scroll patterns
- Use `ScrollView` for short, static content
- Use `FlashList` (or `FlatList`) for any list > 20 items
- Always add `contentContainerStyle={{ paddingBottom: insets.bottom + 16 }}` to avoid content hiding behind tab bar

---

## Step 6: Polish Checklist

Before delivering, verify:

- [ ] Safe areas handled on all screens
- [ ] Dark/light mode: at minimum, dark mode works correctly
- [ ] Loading states (skeleton screens or spinners) for async data
- [ ] Empty states designed (not just blank screens)
- [ ] Error states handled
- [ ] Keyboard avoiding views on forms
- [ ] Haptic feedback on key interactions
- [ ] Entrance animations on screen mounts
- [ ] Accessible: minimum contrast ratios, `accessibilityLabel` on icon buttons
- [ ] Tested on both small (SE) and large (Pro Max) screen sizes via `Dimensions`

---

## Step 7: Output Format

Deliver code as:
1. **Full screen components** (not fragments) — ready to drop into a project
2. **theme.ts** — always include this as a foundation
3. **App structure overview** — folder layout comment at top of main file
4. **Install command** — one-liner with all required packages

If creating multiple screens, output each as a separate file with clear filenames.

---

## Reference Files

- `references/flutter.md` — Flutter widget patterns, theming, navigation (GoRouter)
- `references/components.md` — Extended component library (charts, maps, camera, auth flows)

Read these when the user's request requires Flutter-specific output or advanced component patterns not covered above.