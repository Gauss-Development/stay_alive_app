# Росток — арт-директион для генерации ассетов (GAU-416)

Статичные PNG вместо Rive-стейтов: 5 ступеней роста × 4 настроения = 20 ассетов,
генерируются как 5 character-sheet'ов 2×2 (консистентность персонажа внутри
одного изображения гарантирована). «Анимация» — микро-движение на стороне
Flutter (дыхание/баунс/кроссфейд), см. §6.

Ступени маппятся 1:1 на код (`GardenStage` ↔ `GameLevelTable`):
seed(1 Seedling) → sprout(2 Sprout) → sapling(3 Grower) → plant(4 Thriver) → bloom(5 Vitalist).

Палитра бренда: leaf green `#83C63F`, lime `#D2EC3F`, sage `#C8DDBE`,
фон приложения `#EEF0E7` (light) / `#11140B` (dark) — ассеты с прозрачным фоном.

## 1. Персонаж (инвариант всех 20 ассетов)

Росток — пухлое каплевидное тело с вертикальным градиентом от `#83C63F` у
основания к `#D2EC3F` у макушки. Крошечное каваи-лицо в верхней трети тела:
два тёмных глаза-точки (почти чёрный, `#1B1F14`), простой рот. Стоит на
низком округлом земляном холмике цвета sage `#C8DDBE` — холмик один и тот же
на всех ступенях, это общая базовая линия. Без горшка, без рук (руками служат
листья со ступени 3+), без контурной обводки, мягкие матовые тени.
Пропорции лица и холмика не меняются между ступенями — меняется только
«растительная» часть.

## 2. Ступени роста — детально

### Ступень 1 — SEED (уровень 1 «Seedling»)
Силуэт: низкий и круглый, самый маленький в линейке (~55% высоты обычного тела).
Семечко-боб цвета sage `#C8DDBE` с лёгким зелёным румянцем, нижняя треть
утоплена в холмик. Из макушки — один крошечный завиток-петелька leaf green
`#83C63F` (первый намёк на жизнь, как «хвостик»). Лицо — на самом семечке.
Характер: сонное любопытство новорождённого.

### Ступень 2 — SPROUT (уровень 2 «Sprout»)
Канонический вид, совпадающий с логотипом приложения: тело-капля уже зелёное
(градиент `#83C63F`→`#D2EC3F`), короткий стебель из макушки и ДВА круглых
листа-семядоли — один чуть выше другого, асимметрично (как закорючка в лого).
Рост ~75% полного. Характер: наивный энтузиазм.

### Ступень 3 — SAPLING (уровень 3 «Grower»)
Стебель заметно выше, 3–4 листа: пара средних по бокам (работают как «руки»)
и один молодой лист сверху. Листья вытянутые, со срединной жилкой тоном темнее.
Рост ~90%. Осанка увереннее, тело чуть стройнее. Характер: подросток,
которому всё интересно.

### Ступень 4 — PLANT (уровень 4 «Thriver»)
Пышный кустик: 5–6 листьев разного размера образуют округлую плотную крону,
тело наполовину скрыто листвой, лицо выглядывает из зелени. На макушке —
один ЗАКРЫТЫЙ бутон (тизер финальной ступени), кончик бутона lime `#D2EC3F`.
Рост ~100%. Характер: спокойная зрелая сила.

### Ступень 5 — BLOOM (уровень 5 «Vitalist»)
Всё из ступени 4 + распустившийся цветок на макушке: 5–6 округлых лепестков
lime `#D2EC3F` с белой серединкой, лёгкое тёплое свечение вокруг цветка.
Можно 1–2 крошечных белых блика-искорки у цветка. Рост ~108% (самый высокий).
Характер: гордое сияние, «я расцвёл».

## 3. Настроения (4 на каждую ступень; меняются ТОЛЬКО лицо, наклон и листья)

- **happy** — глаза-дуги «∪∪» или блестящие точки, широкая улыбка, корпус в
  лёгком радостном наклоне/подпрыге, листья приподняты вверх.
- **waiting** — круглые открытые глаза смотрят вверх-в сторону, маленький
  нейтральный рот-точка, листья спокойно опущены, поза ровная. Терпеливое
  ожидание с надеждой — НЕ грусть, НЕ упрёк (премиса 3: никакой вины).
- **sleeping** — закрытые глаза-дуги «⌒⌒», крошечный расслабленный рот,
  листья мягко сложены вниз, корпус чуть завален набок. Без «zzz» в ассете
  (добавим кодом при желании).
- **missed_you** — восторг встречи: широко открытые сияющие глаза с бликами,
  открытая улыбка, листья-«руки» раскинуты вверх и в стороны навстречу
  зрителю, корпус подан вперёд. Тёплая радость, никаких слёз.

## 4. Готовые промпты (5 генераций, по одной на ступень)

Общие блоки — вставлять в каждый промпт:

```
STYLE: cute minimal flat vector illustration, kawaii mascot, smooth rounded
shapes, soft subtle gradient shading, no outlines, matte colors, palette:
leaf green #83C63F, lime accent #D2EC3F, muted sage #C8DDBE soil mound,
plain solid white background, no text, no watermark, high resolution

CHARACTER: a friendly little sprout mascot — plump teardrop-shaped body with
vertical gradient from #83C63F at the base to #D2EC3F at the top, tiny
minimalist face on the upper third (two small dark dot eyes, simple mouth),
standing on a low rounded sage-green soil mound #C8DDBE; identical
proportions, face and mound in every panel

GRID: character sheet, 2x2 grid, the SAME character in four expressions:
top-left HAPPY (arc-shaped smiling eyes, wide smile, leaves raised, slight
joyful bounce), top-right WAITING (round open eyes looking up sideways, tiny
neutral dot mouth, leaves relaxed down, calm hopeful pose), bottom-left
SLEEPING (peacefully closed arc eyes, tiny relaxed mouth, leaves folded down,
body leaning slightly, no zzz letters), bottom-right OVERJOYED REUNION (wide
sparkling eyes with highlights, open happy smile, leaf-arms spread wide toward
the viewer, body leaning forward)

NEGATIVE: photorealistic, 3d render, plastic, glossy, outline stroke, text,
letters, watermark, background scenery, flower pot, human hands, extra
characters, drop shadow on background
```

Ступеневые вставки (заменяют строку STAGE):

1. `STAGE: a tiny seed stage — small round sage-green (#C8DDBE) seed body with a gentle green blush, lower third buried in the soil mound, a single tiny curled green tendril loop (#83C63F) on top of its head, the smallest and roundest form`
2. `STAGE: a young sprout stage — green teardrop body, short stem on top of the head with TWO round cotyledon leaves placed asymmetrically one slightly above the other, simple and iconic`
3. `STAGE: a sapling stage — taller stem, 3-4 elongated leaves with a darker midrib: a middle-sized pair on the sides acting as little arms and one young leaf on top, slightly slimmer confident body`
4. `STAGE: a lush plant stage — 5-6 leaves of varied sizes forming a round dense crown, body half-hidden by foliage, face peeking out of the greenery, ONE closed flower bud on top with a lime (#D2EC3F) tip`
5. `STAGE: a blooming stage — same lush crown plus ONE fully open flower on top: 5-6 rounded lime (#D2EC3F) petals with a white center, soft warm glow around the flower, one or two tiny white sparkles, the tallest proudest form`

Советы по инструментам: Midjourney — добавь `--v 6 --style raw --no text,watermark,outline`;
SDXL/Flux — NEGATIVE в negative prompt; DALL·E/gpt-image — вставляй как есть.
Зафиксируй seed между ступенями, если модель позволяет. Если сетка «плывёт» —
генерируй по одному настроению, но всегда с полным CHARACTER-блоком.

## 5. Тех-спека ассетов

- Sheet: 2048×2048 → нарезка на 4 панели 1024×1024
- Фон: убрать (rembg / любой background remover) → PNG с альфой
- Композиция панели: персонаж ~78% высоты, холмик на базовой линии ~10% от
  низа, центр по горизонтали, одинаково во всех 20 файлах (масштаб ступеней
  задаёт КОД — `GardenState.displayScale`, арт размер не кодирует, кроме
  естественных пропорций из §2)
- Имена: `assets/sprout/{stage}_{mood}.png`, stage ∈ {seed, sprout, sapling,
  plant, bloom}, mood ∈ {happy, waiting, sleeping, missed_you}
- Регистрация в `pubspec.yaml`: `- assets/sprout/`
- Бюджет: ~150–300 KB/файл после `pngquant` → ≤5 MB суммарно

## 6. Анимация на стороне Flutter (когда ассеты готовы)

Точка замены: `GardenSprout` → вместо `GreenSproutRiveEmblem` — `Image.asset`
по ключу `(stage, mood)`:

- Смена настроения/ступени: `AnimatedSwitcher` (fade + scale, 300 мс)
- Idle-«дыхание»: scale 1.0↔1.022, синус ~2.8 с, repeat (sleeping — 4.5 с)
- Отметил порцию: bounce 1.0→1.08→1.0, `Curves.easeOutBack`, 420 мс
  (паттерн уже в `GardenSprout.AnimatedScale`)
- `missed_you`: вход с overshoot + существующий `GamificationCelebrationHost`
- Wilt-тинт (`ColorFiltered`) удаляется — по GAU-416 росток не вянет
- `green_sprout.riv` и rive-зависимость можно удалить после замены

## 7. Чеклист приёмки арта

- [ ] Один и тот же персонаж на всех 20 панелях (лицо/холмик/пропорции)
- [ ] Ступени различимы силуэтом даже в 48 px (виджет!)
- [ ] `waiting` не читается как грусть, `missed_you` — как слёзы
- [ ] Альфа чистая, без белого ореола на тёмном фоне `#11140B`
- [ ] Базовая линия совпадает во всех файлах (проверить наложением)
