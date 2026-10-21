// Lyra Screen Builder — generates the app's screens as native Figma frames.
const W = 390, H = 844;
const TEAL = { r: 0.051, g: 0.580, b: 0.533 };      // #0D9488
const MINT = { r: 0.176, g: 0.831, b: 0.749 };      // #2DD4BF
const BG_SOFT = { r: 0.914, g: 0.969, b: 0.957 };   // #E9F7F4
const INK = { r: 0.118, g: 0.161, b: 0.231 };       // #1E293B
const SLATE = { r: 0.392, g: 0.455, b: 0.545 };     // #64748B
const WHITE = { r: 1, g: 1, b: 1 };
const FIELD = { r: 0.945, g: 0.961, b: 0.976 };     // #F1F5F9

const DIAG = [[0.5, 0.5, 0], [-0.5, 0.5, 0.5]];
const VERT = [[1, 0, 0], [0, 1, 0]];

function tealGrad() {
  return [{ type: 'GRADIENT_LINEAR', gradientTransform: DIAG, gradientStops: [
    { position: 0, color: { ...TEAL, a: 1 } }, { position: 1, color: { ...MINT, a: 1 } }] }];
}
function bgGrad() {
  return [{ type: 'GRADIENT_LINEAR', gradientTransform: VERT, gradientStops: [
    { position: 0, color: { ...WHITE, a: 1 } }, { position: 1, color: { ...BG_SOFT, a: 1 } }] }];
}
function solid(c, a = 1) { return [{ type: 'SOLID', color: c, opacity: a }]; }
function shadow() {
  return [{ type: 'DROP_SHADOW', color: { r: 0.059, g: 0.463, b: 0.431, a: 0.12 },
    offset: { x: 0, y: 6 }, radius: 10, spread: 0, visible: true, blendMode: 'NORMAL' }];
}

function rect(parent, x, y, w, h, { fill = WHITE, r = 0, grad = null, fx = null, o = 1 } = {}) {
  const n = figma.createRectangle();
  parent.appendChild(n);
  n.x = x; n.y = y; n.resize(w, h);
  if (r) n.cornerRadius = r;
  n.fills = grad ? grad : solid(fill);
  if (fx) n.effects = fx;
  if (o !== 1) n.opacity = o;
  return n;
}
function ell(parent, cx, cy, r, fill, o = 1) {
  const n = figma.createEllipse();
  parent.appendChild(n);
  n.x = cx - r; n.y = cy - r; n.resize(r * 2, r * 2);
  n.fills = solid(fill); n.opacity = o;
  return n;
}
async function txt(parent, x, y, s, { size = 13, color = INK, weight = 'Regular', align = 'LEFT' } = {}) {
  const t = figma.createText();
  await figma.loadFontAsync({ family: 'Inter', style: weight });
  t.fontName = { family: 'Inter', style: weight };
  t.characters = s; t.fontSize = size; t.fills = solid(color);
  t.textAlignHorizontal = align;
  parent.appendChild(t); t.x = x; t.y = y;
  if (align === 'CENTER') t.x = x - t.width / 2;
  return t;
}
function card(parent, x, y, w, h, r = 20) {
  return rect(parent, x, y, w, h, { fill: WHITE, r, fx: shadow() });
}

// ---- icons drawn from primitives ----
function icon(parent, cx, cy, s, name, color = WHITE) {
  const g = [];
  const add = n => g.push(n);
  switch (name) {
    case 'heart': {
      const sc = s / 12;
      add(ell(parent, cx - 5 * sc, cy - 3 * sc, 5 * sc, color));
      add(ell(parent, cx + 5 * sc, cy - 3 * sc, 5 * sc, color));
      const t = rect(parent, cx - 7 * sc, cy - 3 * sc, 14 * sc, 14 * sc, { fill: color, r: 1 });
      t.rotation = 45; t.y += 2 * sc; add(t);
      break;
    }
    case 'person': {
      add(ell(parent, cx, cy - s * 0.4, s * 0.42, color));
      const b = rect(parent, cx - s * 0.7, cy + s * 0.05, s * 1.4, s * 0.9, { fill: color, r: s * 0.4 });
      b.constraints = { horizontal: 'SCALE', vertical: 'SCALE' }; add(b);
      break;
    }
    case 'user_md': {
      add(ell(parent, cx, cy - s * 0.4, s * 0.42, color));
      add(rect(parent, cx - s * 0.7, cy + s * 0.05, s * 1.4, s * 0.9, { fill: color, r: s * 0.4 }));
      add(rect(parent, cx - 1, cy + s * 0.2, 2, s * 0.5, { fill: TEAL }));
      add(rect(parent, cx - s * 0.25, cy + s * 0.35, s * 0.5, 2, { fill: TEAL }));
      break;
    }
    case 'doc': {
      add(rect(parent, cx - s * 0.65, cy - s * 0.8, s * 1.3, s * 1.6, { fill: color, r: s * 0.2 }));
      add(rect(parent, cx - s * 0.4, cy - s * 0.4, s * 0.8, 2, { fill: TEAL }));
      add(rect(parent, cx - s * 0.4, cy - s * 0.05, s * 0.8, 2, { fill: TEAL }));
      add(rect(parent, cx - s * 0.4, cy + s * 0.3, s * 0.5, 2, { fill: TEAL }));
      break;
    }
    case 'pill': {
      const p = rect(parent, cx - s * 0.8, cy - s * 0.35, s * 1.6, s * 0.7, { fill: color, r: s * 0.35 });
      p.rotation = -45; add(p);
      break;
    }
    case 'chart': {
      add(rect(parent, cx - s * 0.75, cy + s * 0.1, s * 0.45, s * 0.7, { fill: color, r: 1.5 }));
      add(rect(parent, cx - s * 0.2, cy - s * 0.5, s * 0.45, s * 1.3, { fill: color, r: 1.5 }));
      add(rect(parent, cx + s * 0.35, cy + s * 0.3, s * 0.45, s * 0.5, { fill: color, r: 1.5 }));
      break;
    }
    case 'chat': {
      add(rect(parent, cx - s * 0.8, cy - s * 0.6, s * 1.6, s * 1.1, { fill: color, r: s * 0.3 }));
      add(rect(parent, cx - s * 0.35, cy + s * 0.45, s * 0.45, s * 0.45, { fill: color }));
      break;
    }
    case 'cal': {
      const b = rect(parent, cx - s * 0.75, cy - s * 0.65, s * 1.5, s * 1.4, { fill: color, r: s * 0.25 });
      add(b);
      add(rect(parent, cx - s * 0.75, cy - s * 0.3, s * 1.5, s * 1.05, { fill: TEAL, r: s * 0.2 }));
      add(rect(parent, cx - s * 0.3, cy - s * 0.9, 3, s * 0.35, { fill: color, r: 1 }));
      add(rect(parent, cx + s * 0.3, cy - s * 0.9, 3, s * 0.35, { fill: color, r: 1 }));
      break;
    }
    case 'arrow': {
      const l1 = rect(parent, cx - 2, cy - s * 0.45, 3, s * 0.65, { fill: color, r: 1.5 }); l1.rotation = -40; add(l1);
      const l2 = rect(parent, cx - 2, cy - s * 0.05, 3, s * 0.65, { fill: color, r: 1.5 }); l2.rotation = 40; l2.y += s * 0.25; add(l2);
      break;
    }
    case 'add': {
      add(rect(parent, cx - s * 0.7, cy - 1.5, s * 1.4, 3, { fill: color, r: 1.5 }));
      add(rect(parent, cx - 1.5, cy - s * 0.7, 3, s * 1.4, { fill: color, r: 1.5 }));
      break;
    }
    case 'search': {
      const c = figma.createEllipse(); parent.appendChild(c);
      c.x = cx - s * 0.7; c.y = cy - s * 0.7; c.resize(s * 1.4, s * 1.4);
      c.fills = []; c.strokes = solid(color); c.strokeWeight = 2; add(c);
      const l = rect(parent, cx + s * 0.4, cy + s * 0.4, 3, s * 0.7, { fill: color, r: 1.5 });
      l.rotation = -45; add(l);
      break;
    }
    case 'dots': {
      for (const dx of [-s * 0.6, 0, s * 0.6]) add(ell(parent, cx + dx, cy, s * 0.18, color));
      break;
    }
  }
  if (g.length) { const grp = figma.group(g, parent); grp.name = 'icon/' + name; return grp; }
  return null;
}
function badge(parent, cx, cy, r, name) {
  rect(parent, cx - r, cy - r, r * 2, r * 2, { grad: tealGrad(), r: r * 0.6 });
  icon(parent, cx, cy, r * 0.5, name, WHITE);
}
async function btn(parent, x, y, w, label) {
  rect(parent, x, y, w, 52, { grad: tealGrad(), r: 26 });
  await txt(parent, x + w / 2, y + 31, label, { size: 15, color: WHITE, weight: 'Semi Bold', align: 'CENTER' });
}

function frame(name, x) {
  const f = figma.createFrame();
  f.name = name; f.resize(W, H); f.x = x; f.y = 0;
  f.fills = bgGrad(); f.clipsContent = true;
  return f;
}
async function statusbar(f, dark = true) {
  const c = dark ? INK : WHITE;
  await txt(f, 30, 14, '9:41', { size: 14, color: c, weight: 'Semi Bold' });
  for (let i = 0; i < 3; i++) rect(f, 330 + i * 5, 26 - i * 2, 3, 6 + i * 2, { fill: c, r: 1 });
  const b = rect(f, 350, 20, 18, 10, { fill: WHITE, r: 2 });
  b.fills = []; b.strokes = solid(c); b.strokeWeight = 1;
  rect(f, 352, 22, 11, 6, { fill: c, r: 1 });
}

// ---------- screens ----------
async function splash(x) {
  const f = frame('01 – Splash', x);
  f.fills = tealGrad();
  ell(f, 60, 80, 90, WHITE, 0.06); ell(f, 350, 720, 120, WHITE, 0.06);
  rect(f, 135, 300, 120, 120, { fill: WHITE, r: 36, fx: shadow() });
  icon(f, 195, 360, 46, 'heart', TEAL);
  await txt(f, 195, 445, 'Lyra', { size: 40, color: WHITE, weight: 'Bold', align: 'CENTER' });
  await txt(f, 195, 488, 'Fertility care, connected', { size: 15, color: { r: 0.84, g: 0.96, b: 0.94 }, align: 'CENTER' });
  rect(f, 155, 600, 80, 4, { fill: WHITE, r: 2, o: 0.35 });
  rect(f, 155, 600, 34, 4, { fill: WHITE, r: 2 });
}
async function roleSelect(x) {
  const f = frame('02 – Role Select', x); await statusbar(f);
  rect(f, 24, 60, 342, 130, { grad: tealGrad(), r: 24, fx: shadow() });
  await txt(f, 48, 100, 'Welcome to Lyra', { size: 22, color: WHITE, weight: 'Bold' });
  await txt(f, 48, 128, 'We help you to be complete', { size: 13, color: { r: 0.84, g: 0.96, b: 0.94 } });
  const cards = [['Doctor', 'user_md', 'Sign in to continue'], ['Patient', 'person', 'View your care']];
  for (let i = 0; i < 2; i++) {
    const y = 230 + i * 130;
    card(f, 24, y, 342, 105);
    badge(f, 70, y + 52, 26, cards[i][1]);
    await txt(f, 112, y + 38, cards[i][0], { size: 17, weight: 'Semi Bold' });
    await txt(f, 112, y + 62, cards[i][2], { size: 12, color: SLATE });
    rect(f, 316, y + 36, 34, 34, { grad: tealGrad(), r: 17 });
    icon(f, 333, y + 53, 8, 'arrow', WHITE);
  }
  await txt(f, 195, 560, 'Select your role to continue', { size: 12, color: SLATE, align: 'CENTER' });
}
async function drLogin(x) {
  const f = frame('03 – Doctor Login', x); await statusbar(f);
  badge(f, 195, 150, 40, 'user_md');
  await txt(f, 195, 215, 'Doctor Login', { size: 24, weight: 'Bold', align: 'CENTER' });
  await txt(f, 195, 244, 'Sign in to manage patients', { size: 13, color: SLATE, align: 'CENTER' });
  card(f, 24, 290, 342, 290, 24);
  rect(f, 44, 320, 302, 52, { fill: FIELD, r: 14 });
  await txt(f, 62, 351, 'User ID', { size: 13, color: SLATE });
  rect(f, 44, 388, 302, 52, { fill: FIELD, r: 14 });
  await txt(f, 62, 419, 'Password', { size: 13, color: SLATE });
  await btn(f, 44, 460, 302, 'LOGIN');
  await txt(f, 195, 545, 'Forgot Password?', { size: 13, color: TEAL, weight: 'Semi Bold', align: 'CENTER' });
}
async function drDash(x) {
  const f = frame('04 – Doctor Dashboard', x); await statusbar(f);
  await txt(f, 24, 48, 'Lyra', { size: 20, color: TEAL, weight: 'Bold' });
  ell(f, 352, 44, 18, BG_SOFT); icon(f, 352, 44, 10, 'person', TEAL);
  rect(f, 24, 88, 342, 110, { grad: tealGrad(), r: 22, fx: shadow() });
  await txt(f, 48, 120, 'Patient Care', { size: 19, color: WHITE, weight: 'Bold' });
  await txt(f, 48, 146, "Track every patient's journey", { size: 12, color: { r: 0.84, g: 0.96, b: 0.94 } });
  icon(f, 330, 143, 22, 'heart', WHITE);
  const tiles = [['Patients', 'person'], ['Add Patient', 'add'], ['My Profile', 'doc'], ['Logout', 'arrow']];
  for (let i = 0; i < 4; i++) {
    const y = 232 + i * 88;
    card(f, 24, y, 342, 72);
    rect(f, 40, y + 16, 40, 40, { fill: BG_SOFT, r: 12 });
    icon(f, 60, y + 36, 11, tiles[i][1], TEAL);
    await txt(f, 96, y + 41, tiles[i][0], { size: 15, weight: 'Semi Bold' });
    icon(f, 344, y + 36, 8, 'arrow', SLATE);
  }
}
async function patList(x) {
  const f = frame('05 – Patient List', x); await statusbar(f);
  await txt(f, 24, 48, 'Patients', { size: 20, weight: 'Bold' });
  rect(f, 24, 80, 342, 52, { fill: FIELD, r: 14 });
  await txt(f, 44, 113, 'Search patients', { size: 13, color: SLATE });
  icon(f, 346, 106, 8, 'search', SLATE);
  const names = [['Gayathri', 'ID 361'], ['Geetha', 'ID 205'], ['Shivani', 'ID 365'], ['Prathiba', 'ID 374']];
  for (let i = 0; i < names.length; i++) {
    const y = 152 + i * 84;
    card(f, 24, y, 342, 68);
    ell(f, 58, y + 34, 22, BG_SOFT); icon(f, 58, y + 34, 12, 'person', TEAL);
    await txt(f, 92, y + 26, names[i][0], { size: 15, weight: 'Semi Bold' });
    await txt(f, 92, y + 46, names[i][1], { size: 12, color: SLATE });
    icon(f, 344, y + 34, 8, 'arrow', SLATE);
  }
}
async function patDetail(x) {
  const f = frame('06 – Patient Detail', x); await statusbar(f);
  ell(f, 195, 120, 42, TEAL); const av = ell(f, 195, 120, 42, TEAL); av.fills = tealGrad();
  icon(f, 195, 120, 24, 'person', WHITE);
  await txt(f, 195, 172, 'Gayathri', { size: 20, weight: 'Bold', align: 'CENTER' });
  await txt(f, 195, 196, 'Patient ID: 361', { size: 12, color: SLATE, align: 'CENTER' });
  card(f, 24, 232, 342, 150);
  await txt(f, 44, 252, 'Basic Details', { size: 15, color: TEAL, weight: 'Bold' });
  const rows = [['Age', '28  ·  Female'], ['Blood Group', 'O+ve'], ['Contact', '+91 98XXX XXX21']];
  for (let i = 0; i < rows.length; i++) {
    await txt(f, 44, 282 + i * 30, rows[i][0], { size: 12, color: SLATE });
    await txt(f, 200, 282 + i * 30, rows[i][1], { size: 12, weight: 'Semi Bold' });
  }
  card(f, 24, 398, 342, 130);
  await txt(f, 44, 418, 'Medical History', { size: 15, color: TEAL, weight: 'Bold' });
  await txt(f, 44, 446, 'LMP: 02 Oct 2026  ·  Flow: Regular', { size: 12, color: SLATE });
  await txt(f, 44, 468, 'Obstetric: G0 P0  ·  Surgical: Nil', { size: 12, color: SLATE });
  await txt(f, 44, 490, 'Consanguineous: No', { size: 12, color: SLATE });
  card(f, 24, 544, 342, 100);
  await txt(f, 44, 564, 'Quick Actions', { size: 15, color: TEAL, weight: 'Bold' });
  const acts = [['Reports', 'doc'], ['Medicines', 'pill'], ['Advice', 'chat'], ['Graph', 'chart'], ['Cycle', 'cal']];
  for (let i = 0; i < acts.length; i++) {
    const cx = 60 + i * 68;
    rect(f, cx - 22, 592, 44, 44, { fill: BG_SOFT, r: 14 });
    icon(f, cx, 614, 11, acts[i][1], TEAL);
  }
}
async function patDash(x) {
  const f = frame('07 – Patient Dashboard', x); await statusbar(f);
  await txt(f, 24, 48, 'Lyra', { size: 20, color: TEAL, weight: 'Bold' });
  ell(f, 352, 44, 18, BG_SOFT); icon(f, 352, 44, 10, 'person', TEAL);
  card(f, 24, 88, 342, 240, 24);
  await txt(f, 195, 110, 'Cycle Tracker', { size: 15, color: SLATE, weight: 'Semi Bold', align: 'CENTER' });
  const ring1 = figma.createEllipse(); f.appendChild(ring1);
  ring1.x = 195 - 72; ring1.y = 212 - 72; ring1.resize(144, 144);
  ring1.fills = []; ring1.strokes = solid(BG_SOFT); ring1.strokeWeight = 14;
  const arc = figma.createEllipse(); f.appendChild(arc);
  arc.x = 195 - 72; arc.y = 212 - 72; arc.resize(144, 144);
  arc.fills = []; arc.strokes = [{ type: 'GRADIENT_LINEAR', gradientTransform: DIAG, gradientStops: [
    { position: 0, color: { ...TEAL, a: 1 } }, { position: 1, color: { ...MINT, a: 1 } }] }];
  arc.strokeWeight = 14; arc.arcData = { startingAngle: -Math.PI / 2, endingAngle: Math.PI / 2 + Math.PI * 0.4, innerRadius: 0 };
  await txt(f, 195, 196, 'DAY', { size: 13, color: SLATE, weight: 'Semi Bold', align: 'CENTER' });
  await txt(f, 195, 216, '12', { size: 34, color: TEAL, weight: 'Bold', align: 'CENTER' });
  rect(f, 130, 296, 130, 30, { fill: BG_SOFT, r: 15 });
  await txt(f, 195, 316, 'Fertile: Oct 14–19', { size: 11, color: TEAL, weight: 'Semi Bold', align: 'CENTER' });
  const grid = [['Reports', 'doc'], ['Advice', 'chat'], ['Graphs', 'chart'], ['Medicines', 'pill']];
  for (let i = 0; i < 4; i++) {
    const gx = 24 + (i % 2) * 175, gy = 356 + Math.floor(i / 2) * 130;
    card(f, gx, gy, 167, 110);
    badge(f, gx + 40, gy + 46, 22, grid[i][1]);
    await txt(f, gx + 83.5, gy + 82, grid[i][0], { size: 14, weight: 'Semi Bold', align: 'CENTER' });
  }
  card(f, 24, 640, 342, 70, 18);
  icon(f, 60, 675, 12, 'chat', TEAL);
  await txt(f, 92, 662, 'Need help?', { size: 14, weight: 'Semi Bold' });
  await txt(f, 92, 682, 'Chat with the clinic on WhatsApp', { size: 11, color: SLATE });
}
async function addPatient(x) {
  const f = frame('08 – Add Patient', x); await statusbar(f);
  await txt(f, 24, 48, 'Add Patient', { size: 20, weight: 'Bold' });
  const c = ell(f, 195, 128, 34, BG_SOFT);
  c.fills = solid(BG_SOFT); c.strokes = solid(TEAL); c.strokeWeight = 2; c.dashPattern = [5, 4];
  icon(f, 195, 128, 16, 'add', TEAL);
  await txt(f, 195, 170, 'Patient Photo', { size: 11, color: SLATE, align: 'CENTER' });
  card(f, 24, 206, 342, 200);
  await txt(f, 44, 226, 'Basic Details', { size: 15, color: TEAL, weight: 'Bold' });
  const mkF = async (fx, fy, fw, lab) => { rect(f, fx, fy, fw, 52, { fill: FIELD, r: 14 }); await txt(f, fx + 18, fy + 31, lab, { size: 13, color: SLATE }); };
  await mkF(44, 254, 140, 'Name'); await mkF(198, 254, 140, 'Age');
  await mkF(44, 318, 140, 'Contact No'); await mkF(198, 318, 140, 'Blood Group ▾');
  card(f, 24, 422, 342, 180);
  await txt(f, 44, 442, 'Medical History', { size: 15, color: TEAL, weight: 'Bold' });
  await mkF(44, 470, 140, 'LMP'); await mkF(198, 470, 140, 'Flow ▾');
  await txt(f, 44, 540, 'Consanguineous', { size: 11, color: SLATE });
  rect(f, 44, 552, 90, 30, { grad: tealGrad(), r: 15 });
  await txt(f, 89, 572, 'Yes', { size: 12, color: WHITE, weight: 'Semi Bold', align: 'CENTER' });
  rect(f, 140, 552, 90, 30, { fill: BG_SOFT, r: 15 });
  await txt(f, 185, 572, 'No', { size: 12, color: SLATE, weight: 'Semi Bold', align: 'CENTER' });
  await btn(f, 24, 660, 342, 'CONTINUE  →');
}
async function addReport(x) {
  const f = frame('09 – Add Report', x); await statusbar(f);
  await txt(f, 24, 48, 'Add Report', { size: 20, weight: 'Bold' });
  rect(f, 24, 80, 342, 54, { grad: tealGrad(), r: 16 });
  icon(f, 58, 107, 12, 'cal', WHITE);
  await txt(f, 84, 101, '14 Oct 2026', { size: 15, color: WHITE, weight: 'Semi Bold' });
  const mkF = async (fx, fy, fw, lab) => { rect(f, fx, fy, fw, 52, { fill: FIELD, r: 14 }); await txt(f, fx + 18, fy + 31, lab, { size: 13, color: SLATE }); };
  card(f, 24, 152, 342, 150);
  await txt(f, 44, 172, 'Scan Report', { size: 15, color: TEAL, weight: 'Bold' });
  await mkF(44, 196, 140, 'Endometrium (mm)'); await mkF(198, 196, 140, 'Follicle (mm)');
  await mkF(44, 260, 140, 'RI'); await mkF(198, 260, 140, 'PSV');
  card(f, 24, 318, 342, 210);
  await txt(f, 44, 338, 'Blood Investigations', { size: 15, color: TEAL, weight: 'Bold' });
  await mkF(44, 362, 140, 'FSH'); await mkF(198, 362, 140, 'LH');
  await mkF(44, 426, 140, 'TSH'); await mkF(198, 426, 140, 'Prolactin');
  await mkF(44, 490, 140, 'AMH');
  const dz = rect(f, 24, 556, 342, 90, { fill: BG_SOFT, r: 20 });
  dz.strokes = solid(TEAL); dz.strokeWeight = 1.5; dz.dashPattern = [6, 5];
  icon(f, 195, 590, 14, 'add', TEAL);
  await txt(f, 195, 612, 'Tap to upload scan image', { size: 12, color: SLATE, align: 'CENTER' });
  await btn(f, 24, 680, 342, 'SAVE REPORT');
}

(async () => {
  const screens = [splash, roleSelect, drLogin, drDash, patList, patDetail, patDash, addPatient, addReport];
  for (let i = 0; i < screens.length; i++) {
    await screens[i](i * (W + 80));
  }
  figma.viewport.scrollAndZoomIntoView(figma.currentPage.children);
  figma.notify('Lyra screens generated — 9 frames');
  figma.closePlugin();
})();
