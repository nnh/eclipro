import en from '../../../config/locales/views/js.en.yml'
import ja from '../../../config/locales/views/js.ja.yml'
const translations = Object.assign(en, ja);

export default class I18n {
  static t(key) {
    const t2 = translations[I18n.locale || I18n.default_locale];
    const keys = key.split('.');
    let data = t2;
    for (let i = 0; i < keys.length; i++) {
      data = data[keys[i]];
    }
    return data;
  }
}

I18n.default_locale = 'en';
I18n.locale = null;
