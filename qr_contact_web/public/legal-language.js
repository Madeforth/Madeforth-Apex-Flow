const supportedLanguages = ['tr', 'en', 'de'];

function normalizeLanguage(value) {
  const code = String(value || '').toLowerCase().split('-')[0];
  return supportedLanguages.includes(code) ? code : null;
}

function initialLanguage() {
  const queryLanguage = normalizeLanguage(
    new URLSearchParams(window.location.search).get('lang'),
  );
  if (queryLanguage) return queryLanguage;

  let savedLanguage = null;
  try {
    savedLanguage = normalizeLanguage(localStorage.getItem('apexflow-legal-language'));
  } catch (_) {
    // Storage may be unavailable in hardened/private browser modes.
  }
  if (savedLanguage) return savedLanguage;

  for (const language of navigator.languages || [navigator.language]) {
    const normalized = normalizeLanguage(language);
    if (normalized) return normalized;
  }
  return 'en';
}

function applyLanguage(language, updateUrl = true) {
  const selected = normalizeLanguage(language) || 'en';
  document.documentElement.lang = selected;
  try {
    localStorage.setItem('apexflow-legal-language', selected);
  } catch (_) {
    // The selector still works for this page when persistence is blocked.
  }

  document.querySelectorAll('[data-language]').forEach((panel) => {
    panel.hidden = panel.dataset.language !== selected;
  });

  document.querySelectorAll('[data-language-button]').forEach((button) => {
    const active = button.dataset.languageButton === selected;
    button.classList.toggle('active', active);
    button.setAttribute('aria-pressed', String(active));
  });

  const activePanel = document.querySelector(`[data-language="${selected}"]`);
  if (activePanel?.dataset.title) document.title = activePanel.dataset.title;

  document.querySelectorAll('[data-preserve-language]').forEach((link) => {
    const url = new URL(link.getAttribute('href'), window.location.origin);
    url.searchParams.set('lang', selected);
    link.setAttribute('href', `${url.pathname}${url.search}${url.hash}`);
  });

  if (updateUrl) {
    const url = new URL(window.location.href);
    url.searchParams.set('lang', selected);
    window.history.replaceState({}, '', url);
  }
}

document.querySelectorAll('[data-language-button]').forEach((button) => {
  button.addEventListener('click', () => applyLanguage(button.dataset.languageButton));
});

applyLanguage(initialLanguage());
