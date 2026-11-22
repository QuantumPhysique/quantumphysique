/// BCP-47 language wrapper used by QP apps.
library;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/widgets.dart';

/// Wrapper around a [Locale] representing a user-selectable language.
class QPLanguage {
  /// Creates a [QPLanguage] from a BCP-47 tag.
  QPLanguage(String tag) : _locale = _localeFromTag(tag);

  /// Creates a [QPLanguage] from an existing [Locale].
  QPLanguage.fromLocale(Locale locale) : _locale = locale;

  /// Creates a [QPLanguage] representing the system default.
  QPLanguage.system()
    : _locale = const Locale.fromSubtags(languageCode: systemDefault);

  final Locale _locale;

  /// The locale this language represents.
  Locale get locale => _locale;

  /// The BCP-47 tag for this language (e.g. "zh-Hans", "en").
  String get language => _toTag(_locale);

  /// Native names of every ISO 639-1 language, keyed by BCP-47 tag.
  ///
  /// The names are the endonyms of Wikipedia's "List of ISO 639 language
  /// codes", in the script in current use.
  ///
  /// Entries with a script (`zh-Hans`) win over the bare language code (`zh`),
  /// which is why both live in one map: [displayName] looks up the full tag
  /// first and falls back to the language code.
  ///
  /// A language without a two-letter code, such as `fil`, needs an entry of
  /// its own before an app ships it.
  static const Map<String, String> nativeNames = <String, String>{
    'zh-Hans': '简体中文',
    'zh-Hant': '繁體中文',
    'aa': 'Qafar af',
    'ab': 'Аҧсуа',
    'ae': 'Upastawakaēna',
    'af': 'Afrikaans',
    'ak': 'Ákán',
    'am': 'አማርኛ',
    'an': 'Aragonés',
    'ar': 'العربية',
    'as': 'অসমীয়া',
    'av': 'Авар мацӏ',
    'ay': 'Aymara',
    'az': 'Azərbaycan dili',
    'ba': 'Башҡорт теле',
    'be': 'Беларуская мова',
    'bg': 'Български',
    'bi': 'Bislama',
    'bm': 'Bamanankan',
    'bn': 'বাংলা',
    'bo': 'བོད་སྐད་',
    'br': 'Brezhoneg',
    'bs': 'Bosanski',
    'ca': 'Català',
    'ce': 'Нохчийн мотт',
    'ch': "Finu' Chamoru",
    'co': 'Corsu',
    'cr': 'ᓀᐦᐃᔭᐁᐧᐃᐧᐣ',
    'cs': 'Čeština',
    'cu': 'Славе́нскїй ѧ҆зы́къ',
    'cv': 'Чӑвашла',
    'cy': 'Cymraeg',
    'da': 'Dansk',
    'de': 'Deutsch',
    'dv': 'ދިވެހި',
    'dz': 'རྫོང་ཁ་',
    'ee': 'Èʋegbe',
    'el': 'Νέα Ελληνικά',
    'en': 'English',
    'eo': 'Esperanto',
    'es': 'Español',
    'et': 'Eesti keel',
    'eu': 'Euskara',
    'fa': 'فارسی',
    'ff': 'Fulfulde',
    'fi': 'Suomi',
    'fj': 'Na Vosa Vakaviti',
    'fo': 'Føroyskt',
    'fr': 'Français',
    'fy': 'Frysk',
    'ga': 'Gaeilge',
    'gd': 'Gàidhlig',
    'gl': 'Galego',
    'gn': "Avañe'ẽ",
    'gu': 'ગુજરાતી',
    'gv': 'Gaelg',
    'ha': 'Hausa',
    'he': 'עברית',
    'hi': 'हिन्दी',
    'ho': 'Hiri Motu',
    'hr': 'Hrvatski',
    'ht': 'Kreyòl ayisyen',
    'hu': 'Magyar nyelv',
    'hy': 'Հայերեն',
    'hz': 'Otjiherero',
    'ia': 'Interlingua',
    'id': 'Bahasa Indonesia',
    'ie': 'Interlingue',
    'ig': 'Ásụ̀sụ́ Ìgbò',
    'ii': 'ꆈꌠꉙ',
    'ik': 'Iñupiaq',
    'io': 'Ido',
    'is': 'Íslenska',
    'it': 'Italiano',
    'iu': 'ᐃᓄᒃᑎᑐᑦ',
    'ja': '日本語',
    'jv': 'Basa Jawa',
    'ka': 'ქართული',
    'kg': 'Kikongo',
    'ki': 'Gĩgĩkũyũ',
    'kj': 'Oshikwanyama',
    'kk': 'Қазақша',
    'kl': 'Kalaallisut',
    'km': 'ខេមរភាសា',
    'kn': 'ಕನ್ನಡ',
    'ko': '한국어',
    'kr': 'Kànùrí',
    'ks': 'كأشُر',
    'ku': 'کوردی',
    'kv': 'Коми кыв',
    'kw': 'Kernowek',
    'ky': 'Кыргыз',
    'la': 'Latinum',
    'lb': 'Lëtzebuergesch',
    'lg': 'Luganda',
    'li': 'Limburgisch',
    'ln': 'Lingála',
    'lo': 'ພາສາລາວ',
    'lt': 'Lietuvių',
    'lu': 'Kiluba',
    'lv': 'Latviešu',
    'mg': 'Malagasy',
    'mh': 'Kajin M̧ajel‌̧',
    'mi': 'Reo Māori',
    'mk': 'Македонски',
    'ml': 'മലയാളം',
    'mn': 'Монгол хэл',
    'mr': 'मराठी',
    'ms': 'Bahasa Melayu',
    'mt': 'Malti',
    'my': 'မြန်မာစာ',
    'na': 'Dorerin Naoe',
    'nb': 'Norsk Bokmål',
    'nd': 'isiNdebele saseNyakatho',
    'ne': 'नेपाली भाषा',
    'ng': 'Ndonga',
    'nl': 'Nederlands',
    'nn': 'Norsk Nynorsk',
    'no': 'Norsk',
    'nr': 'isiNdebele sakwaNdzundza',
    'nv': 'Diné bizaad',
    'ny': 'Chichewa',
    'oc': 'Occitan',
    'oj': 'ᐊᓂᔑᓈᐯᒧᐎᓐ',
    'om': 'Afaan Oromoo',
    'or': 'ଓଡ଼ିଆ',
    'os': 'Ирон Ӕвзаг',
    'pa': 'ਪੰਜਾਬੀ',
    'pi': 'Pāli',
    'pl': 'Polski',
    'ps': 'پښتو',
    'pt': 'Português',
    'qu': 'Runa simi',
    'rm': 'Rumantsch',
    'rn': 'Ikirundi',
    'ro': 'Română',
    'ru': 'Русский язык',
    'rw': 'Ikinyarwanda',
    'sa': 'संस्कृतम्',
    'sc': 'Sardu',
    'sd': 'سنڌي',
    'se': 'Davvisámegiella',
    'sg': 'Yângâ tî Sängö',
    'si': 'සිංහල',
    'sk': 'Slovenčina',
    'sl': 'Slovenščina',
    'sm': 'Gagana Sāmoa',
    'sn': 'chiShona',
    'so': 'Soomaali',
    'sq': 'Shqip',
    'sr': 'Српски',
    'ss': 'siSwati',
    'st': 'Sesotho',
    'su': 'Basa Sunda',
    'sv': 'Svenska',
    'sw': 'Kiswahili',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
    'tg': 'Тоҷикӣ',
    'th': 'ภาษาไทย',
    'ti': 'ትግርኛ',
    'tk': 'Türkmençe',
    'tl': 'Wikang Tagalog',
    'tn': 'Setswana',
    'to': 'Lea faka-Tonga',
    'tr': 'Türkçe',
    'ts': 'Xitsonga',
    'tt': 'Татар теле',
    'tw': 'Twi',
    'ty': 'Reo Tahiti',
    'ug': 'ئۇيغۇر تىلى',
    'uk': 'Українська',
    'ur': 'اردو',
    'uz': 'Ózbekça',
    've': 'Tshivenḓa',
    'vi': 'Tiếng Việt',
    'vo': 'Volapük',
    'wa': 'Walon',
    'wo': 'Wolof',
    'xh': 'isiXhosa',
    'yi': 'ייִדיש',
    'yo': 'Èdè Yorùbá',
    'za': 'Vahcuengh',
    'zh': '中文',
    'zu': 'isiZulu',
  };

  /// Display name for this language, or `null` when [nativeNames] has none.
  ///
  /// [defaultLabel] is the string to show for the system-default option (e.g.
  /// "System default"). Pass it from [QPStrings.defaultLangLabel].
  ///
  /// Returning `null` rather than a placeholder is what lets an app assert in
  /// a test that every language it ships can actually be named.
  String? displayName(String defaultLabel) {
    if (_locale.languageCode == systemDefault) {
      return defaultLabel;
    }
    return nativeNames[language] ?? nativeNames[_locale.languageCode];
  }

  /// Human-readable display name for this language.
  ///
  /// Falls back to the BCP-47 tag when no name is known, so a language whose
  /// name was forgotten reads as "fil" instead of as an error message.
  String languageLong(String defaultLabel) =>
      displayName(defaultLabel) ?? language;

  @override
  String toString() => 'QPLanguage($language)';

  /// Convert to [Locale].
  Locale toLocale() => _locale;

  /// Compare with [other]; returns `true` when they represent the same language.
  bool compareTo(QPLanguage other) => other.language == language;

  /// IANA "undetermined" code — used for the system-default entry.
  static const String systemDefault = 'und';

  /// Mutable list of supported languages; set at app startup.
  static List<QPLanguage> supportedLanguages = <QPLanguage>[
    QPLanguage.system(),
  ];
}

// ── BCP-47 tag helpers ────────────────────────────────────────────────────────

String _toTag(Locale l) {
  final List<String> parts = <String>[
    l.languageCode,
    if (l.scriptCode != null && l.scriptCode!.isNotEmpty) l.scriptCode!,
    if (l.countryCode != null && l.countryCode!.isNotEmpty) l.countryCode!,
  ];
  return parts.join('-');
}

Locale _localeFromTag(String tag) {
  final List<String> p = tag.split('-');
  String? script;
  String? region;
  if (p.length >= 2) {
    if (p[1].length == 4) {
      script = p[1];
      if (p.length >= 3) {
        region = p[2];
      }
    } else {
      region = p[1];
    }
  }
  return Locale.fromSubtags(
    languageCode: p[0],
    scriptCode: script,
    countryCode: region,
  );
}

// ── String / Locale parsing extensions ───────────────────────────────────────

/// Parse a [String] (BCP-47 tag) to a [QPLanguage].
extension QPLanguageStringParsing on String {
  /// Returns a [QPLanguage] from this BCP-47 tag.
  QPLanguage toQPLanguage() => QPLanguage(this);
}

/// Parse a [Locale] to a [QPLanguage].
extension QPLanguageLocaleParsing on Locale {
  /// Returns a [QPLanguage] wrapping this locale.
  QPLanguage toQPLanguage() => QPLanguage.fromLocale(this);
}
