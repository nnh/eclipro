import translations from "./translations.json"

export default class I18n {
  static t(key) {
    const t2 = translations[I18n.locale || I18n.default_locale];
    return t2[key];
  }
}

I18n.default_locale = 'en';
I18n.locale = null;
