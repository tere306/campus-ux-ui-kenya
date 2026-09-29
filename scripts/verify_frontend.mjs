import fs from 'node:fs';
import crypto from 'node:crypto';

const file = 'frontend/development-current/index.html';
const html = fs.readFileSync(file, 'utf8');
const failures = [];

const brandFiles = {
  'frontend/development-current/zavra-logo-black.png': 'a720dd56c8d5c0e226a239be35a7c4c4ef810f6c1062a6dd7da55e1ecc1f4f1c',
  'frontend/development-current/zavra-logo-white.png': 'fc16b864bec32a2416d917b75de39091f2fefa4255415524459052db7c21dc18',
  'frontend/development-current/zavra-logo-black-tagline.png': '5566affb278928c54d7799919c666d67a8d1eb23edd5e550e56f916745540a43',
};

for (const [brandFile, expectedHash] of Object.entries(brandFiles)) {
  if (!fs.existsSync(brandFile)) {
    failures.push(`Missing brand asset: ${brandFile}`);
    continue;
  }
  const actualHash = crypto.createHash('sha256').update(fs.readFileSync(brandFile)).digest('hex');
  if (actualHash !== expectedHash) failures.push(`Brand asset hash mismatch: ${brandFile}`);
}

const publishDir = 'frontend/development-current';
const localAssetRefs = [...html.matchAll(/\\bsrc=(['"])([^'"]+)\\1/gi)]
  .map((match) => match[2])
  .filter((ref) => !/^(?:https?:|data:|blob:|\\/\\/)/i.test(ref) && !ref.includes('${'));

for (const ref of new Set(localAssetRefs)) {
  const assetPath = `${publishDir}/${ref.replace(/^\\.\\//, '')}`;
  if (!fs.existsSync(assetPath)) failures.push(`Missing local asset referenced by HTML: ${assetPath}`);
}

for (const requiredFile of [`${publishDir}/_headers`, `${publishDir}/_redirects`]) {
  if (!fs.existsSync(requiredFile)) failures.push(`Missing publish control file: ${requiredFile}`);
}

const scripts = [...html.matchAll(/<script\b[^>]*>([\s\S]*?)<[/]script>/gi)].map((match) => match[1]);
if (!scripts.length) failures.push('No inline scripts found');

scripts.forEach((code, index) => {
  try {
    new Function(code);
  } catch (error) {
    failures.push(`Inline script ${index + 1} has a syntax error: ${error.message}`);
  }
});

const versionMatch = html.match(/<!-- Campus UX[/]UI · (?:development|release) v(\d+) -->/);
if (!versionMatch) failures.push('Missing frontend version marker');

const implicitButtons = [...html.matchAll(/<button\b(?![^>]*\btype=)[^>]*>/gi)];
if (implicitButtons.length) failures.push(`${implicitButtons.length} button(s) without explicit type`);

const javascriptUrls = [...html.matchAll(/(?:href|src)=(['"])javascript:/gi)];
if (javascriptUrls.length) failures.push(`${javascriptUrls.length} javascript: URL(s) found`);

const checks = [
  ['profile name sync', html.includes("name=(state.role==='student'?certificateNameFromProfile(p):'')||p.real_name")],
  ['lesson summary escaped', html.includes("esc(l.summary||'')")],
  ['lesson practice escaped', html.includes("esc(l.practice||'')")],
  ['lesson outcome escaped', html.includes("esc(l.outcome||'')")],
  ['raw lesson summary removed', !html.includes('${l.summary}</p>')],
  ['profile values wrap safely', html.includes('.profile-detail strong{display:block;margin-top:4px;overflow-wrap:anywhere}')],
  ['layout resilience marker', html.includes('/* v83 · resiliencia de layout y contenido largo */')],
  ['grid children can shrink', html.includes('.main,.pagehead>*,.grid>*,.card>*')],
  ['long labels wrap', html.includes('.btn,.tag,.filter-chip{white-space:normal;overflow-wrap:anywhere}')],
  ['mobile lesson resources stack', html.includes('.lesson-resource{flex-direction:column}')],
  ['legacy v80 marker removed', !html.includes('release v80')],
  ['no service-role credential marker', !html.includes('service_role')],
  ['no Supabase secret key marker', !html.includes('sb_secret_')],
  ['frontend uses publishable Supabase key', html.includes("publishableKey:'sb_publishable_")],
  ['mobile profile identity layout', html.includes('/* v84 · perfil móvil con identidad legible */')],
  ['legacy campus logo removed', !html.includes('campus-logo.webp')],
  ['dark-surface ZAVRA logo referenced', html.includes('zavra-logo-white.png')],
  ['light-surface ZAVRA logo referenced', html.includes('zavra-logo-black.png')],
  ['login ZAVRA tagline logo referenced', html.includes('zavra-logo-black-tagline.png')],
  ['v86 visual polish marker', html.includes('/* v86 · pulido visual tras QA real */')],
  ['no escaped newline between auth boot and login', !html.includes('</div></div>\\\\n<div id="login"')],
];

for (const [label, ok] of checks) {
  if (!ok) failures.push(`Invariant failed: ${label}`);
}

const sha256 = crypto.createHash('sha256').update(html).digest('hex');
console.log(`Frontend: ${file}`);
console.log(`Version marker: v${versionMatch?.[1] ?? 'unknown'}`);
console.log(`Characters: ${html.length}`);
console.log(`Inline scripts parsed: ${scripts.length}`);
console.log(`SHA-256: ${sha256}`);

if (failures.length) {
  console.error('\nFrontend verification failed:');
  failures.forEach((failure) => console.error(`- ${failure}`));
  process.exit(1);
}

console.log('Frontend verification passed.');
