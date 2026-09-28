import fs from 'node:fs';
import crypto from 'node:crypto';

const file = 'frontend/development-current/index.html';
const html = fs.readFileSync(file, 'utf8');
const failures = [];

const scripts = [...html.matchAll(/<script\b[^>]*>([\s\S]*?)<\/script>/gi)].map((match) => match[1]);
if (!scripts.length) failures.push('No inline scripts found');

scripts.forEach((code, index) => {
  try {
    new Function(code);
  } catch (error) {
    failures.push(`Inline script ${index + 1} has a syntax error: ${error.message}`);
  }
});

const checks = [
  ['profile name sync', html.includes("name=(state.role==='student'?certificateNameFromProfile(p):'')||p.real_name")],
  ['lesson summary escaped', html.includes("esc(l.summary||'')")],
  ['lesson practice escaped', html.includes("esc(l.practice||'')")],
  ['lesson outcome escaped', html.includes("esc(l.outcome||'')")],
  ['raw lesson summary removed', !html.includes('${l.summary}</p>')],
  ['profile values wrap safely', html.includes('.profile-detail strong{display:block;margin-top:4px;overflow-wrap:anywhere}')],
];

for (const [label, ok] of checks) {
  if (!ok) failures.push(`Invariant failed: ${label}`);
}

const sha256 = crypto.createHash('sha256').update(html).digest('hex');
console.log(`Frontend: ${file}`);
console.log(`Characters: ${html.length}`);
console.log(`Inline scripts parsed: ${scripts.length}`);
console.log(`SHA-256: ${sha256}`);

if (failures.length) {
  console.error('\nFrontend verification failed:');
  failures.forEach((failure) => console.error(`- ${failure}`));
  process.exit(1);
}

console.log('Frontend verification passed.');
