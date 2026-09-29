import fs from 'node:fs';
import path from 'node:path';
import { chromium } from '@playwright/test';

const baseUrl = process.env.QA_URL || 'http://127.0.0.1:4173/';
const outDir = process.env.QA_ARTIFACT_DIR || 'qa-artifacts';
fs.mkdirSync(outDir, { recursive: true });

const browser = await chromium.launch({ headless: true });
const failures = [];
const results = [];

const scenarios = [
  { mode: 'login', pages: ['login'] },
  { mode: 'student', pages: ['home', 'program', 'classroom', 'deliverables', 'library', 'portfolio', 'progress', 'profile'] },
  { mode: 'admin', pages: ['adminHome', 'students', 'reviews', 'content', 'settings'] },
];

const viewports = [
  { name: 'mobile-320', width: 320, height: 800 },
  { name: 'mobile-390', width: 390, height: 844 },
  { name: 'tablet', width: 768, height: 1024 },
  { name: 'desktop', width: 1440, height: 1000 },
];

async function injectMockSession(page, mode, pageName) {
  await page.evaluate(({ mode, pageName }) => {
    if (typeof state === 'undefined') throw new Error('Global state is unavailable');
    if (typeof runtimeAuth === 'undefined') throw new Error('runtimeAuth is unavailable');
    if (typeof render !== 'function') throw new Error('render() is unavailable');

    state.logged = true;
    state.role = mode;
    state.page = pageName;

    runtimeAuth.mode = 'remote';
    runtimeAuth.status = 'authenticated';
    runtimeAuth.userId = '00000000-0000-4000-8000-000000000001';
    runtimeAuth.roles = mode === 'admin' ? ['admin', 'student'] : ['student'];
    runtimeAuth.programId = runtimeAuth.programId || '00000000-0000-4000-8000-000000000002';
    runtimeAuth.enrollment = {
      status: 'active',
      versionLabel: '4.14D-12x48-full',
      curriculumVersionId: '00000000-0000-4000-8000-000000000003',
    };
    runtimeAuth.profile = {
      user_id: runtimeAuth.userId,
      real_name: 'Alejandra María de los Ángeles de la Vega Montenegro',
      first_name: 'Alejandra María de los Ángeles',
      last_name_1: 'de la Vega',
      last_name_2: 'Montenegro',
      phone: '+34 600 000 000',
      email: 'qa.visual.con.nombre.muy.largo+campus@example.test',
      role: mode,
      student_code: 'QA-VISUAL-0001',
      active: true,
      certificate_name_confirmed: false,
      avatar_path: null,
      updated_at: new Date().toISOString(),
    };

    if (Array.isArray(state.students) && state.students.length) {
      state.activeStudent = state.students[0].id;
      state.students[0].name = 'Alejandra María de los Ángeles de la Vega Montenegro';
    }

    render();
  }, { mode, pageName });
}

async function measure(page, mode) {
  return page.evaluate((mode) => {
    const root = document.documentElement;
    const body = document.body;
    const innerWidth = window.innerWidth;
    const scrollWidth = Math.max(root.scrollWidth, body?.scrollWidth || 0);

    const offenders = [...document.querySelectorAll('body *')]
      .filter((el) => {
        if (!(el instanceof HTMLElement)) return false;
        const style = getComputedStyle(el);
        if (style.display === 'none' || style.visibility === 'hidden') return false;
        if (el.closest('.table-wrap')) return false;
        const rect = el.getBoundingClientRect();
        if (!rect.width || !rect.height) return false;
        return rect.right > innerWidth + 2 || rect.left < -2;
      })
      .slice(0, 12)
      .map((el) => {
        const rect = el.getBoundingClientRect();
        return {
          tag: el.tagName.toLowerCase(),
          id: el.id || '',
          className: typeof el.className === 'string' ? el.className.slice(0, 120) : '',
          left: Math.round(rect.left),
          right: Math.round(rect.right),
          width: Math.round(rect.width),
        };
      });

    const visibleCards = [...document.querySelectorAll('.card')]
      .filter((el) => {
        const rect = el.getBoundingClientRect();
        return rect.width > 0 && rect.height > 0;
      }).length;

    const brokenImages = [...document.images]
      .filter((img) => {
        const rect = img.getBoundingClientRect();
        return rect.width > 0 && rect.height > 0 && (!img.complete || img.naturalWidth === 0);
      })
      .map((img) => ({ src: img.getAttribute('src') || '', alt: img.alt || '' }));

    const isVisible = (el) => {
      if (!(el instanceof HTMLElement)) return false;
      const style = getComputedStyle(el);
      const rect = el.getBoundingClientRect();
      return style.display !== 'none' && style.visibility !== 'hidden' && rect.width > 0 && rect.height > 0;
    };

    const ids = [...document.querySelectorAll('[id]')].map((el) => el.id).filter(Boolean);
    const duplicateIds = [...new Set(ids.filter((id, index) => ids.indexOf(id) !== index))];

    const unlabeledControls = [...document.querySelectorAll('input, textarea, select')]
      .filter((el) => {
        if (!isVisible(el)) return false;
        if (el instanceof HTMLInputElement && ['hidden', 'button', 'submit', 'reset', 'image'].includes(el.type)) return false;
        if (el.getAttribute('aria-label')?.trim()) return false;
        if (el.getAttribute('aria-labelledby')?.trim()) return false;
        if (el.closest('label')) return false;
        if (el.id && document.querySelector(`label[for="${CSS.escape(el.id)}"]`)) return false;
        return true;
      })
      .map((el) => ({ tag: el.tagName.toLowerCase(), id: el.id || '', name: el.getAttribute('name') || '' }));

    const heading = mode === 'login'
      ? [...document.querySelectorAll('.login h1')].find(isVisible)
      : [...document.querySelectorAll('#main h1')].find(isVisible);

    return {
      innerWidth,
      scrollWidth,
      overflow: scrollWidth > innerWidth + 2,
      offenders,
      visibleCards,
      brokenImages,
      duplicateIds,
      unlabeledControls,
      title: document.title,
      h1: heading?.textContent?.trim() || '',
    };
  }, mode);
}

for (const viewport of viewports) {
  for (const scenario of scenarios) {
    for (const pageName of scenario.pages) {
      const context = await browser.newContext({
        viewport: { width: viewport.width, height: viewport.height },
        reducedMotion: 'reduce',
      });
      const page = await context.newPage();
      const pageErrors = [];
      page.on('pageerror', (error) => pageErrors.push(String(error?.message || error)));

      await page.route('https://azacjdyxgknfqarcemhi.supabase.co/**', async (route) => {
        await route.fulfill({
          status: 401,
          contentType: 'application/json',
          body: JSON.stringify({ message: 'visual-smoke-mocked-auth' }),
        });
      });

      await page.goto(baseUrl, { waitUntil: 'domcontentloaded' });
      await page.waitForTimeout(350);
      pageErrors.length = 0;

      if (scenario.mode !== 'login') {
        await injectMockSession(page, scenario.mode, pageName);
        await page.waitForTimeout(80);
      }

      const metrics = await measure(page, scenario.mode);
      const label = `${scenario.mode}-${pageName}-${viewport.name}`;
      const screenshotPath = path.join(outDir, `${label}.png`);
      await page.screenshot({ path: screenshotPath, fullPage: true });

      const record = { label, ...metrics, pageErrors };
      results.push(record);

      if (metrics.overflow) {
        failures.push(`${label}: horizontal overflow ${metrics.scrollWidth}px > ${metrics.innerWidth}px; offenders=${JSON.stringify(metrics.offenders)}`);
      }
      if (pageErrors.length) {
        failures.push(`${label}: page errors: ${pageErrors.join(' | ')}`);
      }
      if (metrics.brokenImages.length) {
        failures.push(`${label}: broken visible images: ${JSON.stringify(metrics.brokenImages)}`);
      }
      if (metrics.duplicateIds.length) {
        failures.push(`${label}: duplicate IDs: ${metrics.duplicateIds.join(', ')}`);
      }
      if (metrics.unlabeledControls.length) {
        failures.push(`${label}: visible form controls without accessible label: ${JSON.stringify(metrics.unlabeledControls)}`);
      }
      if (!metrics.h1) {
        failures.push(`${label}: missing page heading`);
      }

      await context.close();
    }
  }
}

await browser.close();
fs.writeFileSync(path.join(outDir, 'visual-smoke-results.json'), JSON.stringify(results, null, 2));

for (const result of results) {
  console.log(`${result.label}: width=${result.innerWidth}, scrollWidth=${result.scrollWidth}, cards=${result.visibleCards}, brokenImages=${result.brokenImages.length}, duplicateIds=${result.duplicateIds.length}, unlabeledControls=${result.unlabeledControls.length}, h1="${result.h1}"`);
}

if (failures.length) {
  console.error('\nVisual smoke failures:');
  failures.forEach((failure) => console.error(`- ${failure}`));
  process.exit(1);
}

console.log(`\nVisual smoke passed: ${results.length} scenarios.`);
