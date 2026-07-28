import { writeFileSync, mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { RiveFile, hex, PropertyKey } from '@stevysmith/rive-generator';

const __dirname = dirname(fileURLToPath(import.meta.url));
const outputPath = join(__dirname, '../../assets/animations/green_sprout.riv');

const GREEN = hex('#83C63F');
const STEM = hex('#5FA82E');
const HIGHLIGHT = hex('#A8D86A');

const riv = new RiveFile();

const artboard = riv.addArtboard({
  name: 'GreenSprout',
  width: 120,
  height: 120,
});

// Root group — animated for the grow effect.
const sprout = riv.addNode(artboard, {
  name: 'Sprout',
  x: 60,
  y: 78,
  rotation: -0.26,
});

// Soil mound.
const soilShape = riv.addShape(artboard, { name: 'Soil', x: 60, y: 98 });
riv.addEllipse(soilShape, { width: 52, height: 14, x: -26, y: -7 });
const soilFill = riv.addFill(soilShape);
riv.addSolidColor(soilFill, hex('#D8DCCF'));

// Stem.
const stemShape = riv.addShape(sprout, { name: 'Stem', x: 0, y: -6 });
riv.addRectangle(stemShape, {
  width: 6,
  height: 18,
  x: -3,
  y: -18,
  cornerRadius: 3,
});
const stemFill = riv.addFill(stemShape);
riv.addSolidColor(stemFill, STEM);

// Main leaf — asymmetric rounded rect matching SproutIcon proportions.
const leafShape = riv.addShape(sprout, { name: 'Leaf', x: 0, y: -30 });
const leafPath = riv.addPointsPath(leafShape, { name: 'LeafPath', closed: true });

// 40×40 leaf with TL/TR/BR radius 20, BL radius 8.
const w = 40;
const h = 40;
const rTL = 20;
const rTR = 20;
const rBR = 20;
const rBL = 8;
const left = -w / 2;
const top = -h / 2;

riv.addCubicVertex(leafPath, {
  x: left + rTL,
  y: top,
  inX: left + rTL,
  inY: top,
  outX: left,
  outY: top,
});
riv.addCubicVertex(leafPath, {
  x: left,
  y: top + rTL,
  inX: left,
  inY: top,
  outX: left,
  outY: top + rTL,
});
riv.addCubicVertex(leafPath, {
  x: left,
  y: top + h - rBL,
  inX: left,
  inY: top + h - rBL,
  outX: left,
  outY: top + h,
});
riv.addCubicVertex(leafPath, {
  x: left + rBL,
  y: top + h,
  inX: left,
  inY: top + h,
  outX: left + rBL,
  outY: top + h,
});
riv.addCubicVertex(leafPath, {
  x: left + w - rBR,
  y: top + h,
  inX: left + w - rBR,
  inY: top + h,
  outX: left + w,
  outY: top + h,
});
riv.addCubicVertex(leafPath, {
  x: left + w,
  y: top + h - rBR,
  inX: left + w,
  inY: top + h,
  outX: left + w,
  outY: top + h - rBR,
});
riv.addCubicVertex(leafPath, {
  x: left + w,
  y: top + rTR,
  inX: left + w,
  inY: top + rTR,
  outX: left + w,
  outY: top,
});
riv.addCubicVertex(leafPath, {
  x: left + w - rTR,
  y: top,
  inX: left + w,
  inY: top,
  outX: left + w - rTR,
  outY: top,
});

const leafFill = riv.addFill(leafShape);
riv.addSolidColor(leafFill, GREEN);

// Soft highlight on the leaf.
const highlightShape = riv.addShape(sprout, { name: 'Highlight', x: -6, y: -34 });
riv.addEllipse(highlightShape, { width: 10, height: 16, x: -5, y: -8 });
const highlightFill = riv.addFill(highlightShape);
riv.addSolidColor(highlightFill, HIGHLIGHT);

// Growth animation — sprout scales up from the soil.
const grow = riv.addLinearAnimation(artboard, {
  name: 'grow',
  fps: 60,
  duration: 90,
  loop: 'loop',
});

const keyed = riv.addKeyedObject(grow, sprout);

const scaleX = riv.addKeyedProperty(keyed, PropertyKey.scaleX);
riv.addKeyFrameDouble(scaleX, { frame: 0, value: 0, interpolation: 'cubic' });
riv.addKeyFrameDouble(scaleX, { frame: 45, value: 1.08, interpolation: 'cubic' });
riv.addKeyFrameDouble(scaleX, { frame: 60, value: 1, interpolation: 'cubic' });
riv.addKeyFrameDouble(scaleX, { frame: 90, value: 1, interpolation: 'hold' });

const scaleY = riv.addKeyedProperty(keyed, PropertyKey.scaleY);
riv.addKeyFrameDouble(scaleY, { frame: 0, value: 0, interpolation: 'cubic' });
riv.addKeyFrameDouble(scaleY, { frame: 45, value: 1.12, interpolation: 'cubic' });
riv.addKeyFrameDouble(scaleY, { frame: 60, value: 1, interpolation: 'cubic' });
riv.addKeyFrameDouble(scaleY, { frame: 90, value: 1, interpolation: 'hold' });

const yPos = riv.addKeyedProperty(keyed, PropertyKey.y);
riv.addKeyFrameDouble(yPos, { frame: 0, value: 88, interpolation: 'cubic' });
riv.addKeyFrameDouble(yPos, { frame: 45, value: 76, interpolation: 'cubic' });
riv.addKeyFrameDouble(yPos, { frame: 60, value: 78, interpolation: 'cubic' });
riv.addKeyFrameDouble(yPos, { frame: 90, value: 78, interpolation: 'hold' });

// Gentle sway after growth.
const rotation = riv.addKeyedProperty(keyed, PropertyKey.rotation);
riv.addKeyFrameDouble(rotation, { frame: 0, value: -0.26, interpolation: 'linear' });
riv.addKeyFrameDouble(rotation, { frame: 60, value: -0.26, interpolation: 'cubic' });
riv.addKeyFrameDouble(rotation, { frame: 75, value: -0.18, interpolation: 'cubic' });
riv.addKeyFrameDouble(rotation, { frame: 90, value: -0.26, interpolation: 'cubic' });

mkdirSync(dirname(outputPath), { recursive: true });
writeFileSync(outputPath, riv.export());

console.log(`Created ${outputPath}`);
