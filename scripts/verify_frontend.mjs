import fs from 'node:fs';
import crypto from 'node:crypto';

const file = 'frontend/development-current/index.html';
const html = fs.readFileSync(file, 'utf8');
const failures = [];

const scripts = [...html.matchAll(/<script\\b[^>]*>([\\s\\S]*?)<\\/script>/gi)].map((match) => match[1]);
if (!scripts.length) failures.push('No inline scripts found');

scripts.forEach((code, index) => {
  try {
    new Function(code);
  } catch (error) {
    failures.push(`Inline script ${index + 1} has a syntax error: ${error.message}`);
  }
});

const versionMatch = html.match(/<!-- Campus UX\\/UI · (?:development|release) v(\\d+) -->/);
if (!versionMatch) failures.push('Missing frontend version marker');

const implicitButtons = [...html.matchAll(/<button\\b(?![^>]*\\btype=)[^>]*>/gi)];
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
  console.error('\\nFrontend verification failed:');
  failures.forEach((failure) => console.error(`- ${failure}`));
  process.exit(1);
}

console.log('Frontend verification passed.');
