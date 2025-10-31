// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:implementation_imports, file_names, unnecessary_new
// ignore_for_file:unnecessary_brace_in_string_interps, directives_ordering
// ignore_for_file:argument_type_not_assignable, invalid_assignment
// ignore_for_file:prefer_single_quotes, prefer_generic_function_type_aliases
// ignore_for_file:comment_references

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:intl/src/intl_helpers.dart';

import 'messages_ar_SA.dart' as messages_ar_sa;
import 'messages_de_DE.dart' as messages_de_de;
import 'messages_en.dart' as messages_en;
import 'messages_es_ES.dart' as messages_es_es;
import 'messages_fr_FR.dart' as messages_fr_fr;
import 'messages_hi_IN.dart' as messages_hi_in;
import 'messages_ja_JP.dart' as messages_ja_jp;
import 'messages_kn_IN.dart' as messages_kn_in;
import 'messages_ko_KR.dart' as messages_ko_kr;
import 'messages_ru_RU.dart' as messages_ru_ru;
import 'messages_ta_IN.dart' as messages_ta_in;
import 'messages_te_IN.dart' as messages_te_in;
import 'messages_th_TH.dart' as messages_th_th;
import 'messages_ur_PK.dart' as messages_ur_pk;
import 'messages_zh_CN.dart' as messages_zh_cn;

typedef Future<dynamic> LibraryLoader();
Map<String, LibraryLoader> _deferredLibraries = {
  'ar_SA': () => new SynchronousFuture(null),
  'de_DE': () => new SynchronousFuture(null),
  'en': () => new SynchronousFuture(null),
  'es_ES': () => new SynchronousFuture(null),
  'fr_FR': () => new SynchronousFuture(null),
  'hi_IN': () => new SynchronousFuture(null),
  'ja_JP': () => new SynchronousFuture(null),
  'kn_IN': () => new SynchronousFuture(null),
  'ko_KR': () => new SynchronousFuture(null),
  'ru_RU': () => new SynchronousFuture(null),
  'ta_IN': () => new SynchronousFuture(null),
  'te_IN': () => new SynchronousFuture(null),
  'th_TH': () => new SynchronousFuture(null),
  'ur_PK': () => new SynchronousFuture(null),
  'zh_CN': () => new SynchronousFuture(null),
};

MessageLookupByLibrary? _findExact(String localeName) {
  switch (localeName) {
    case 'ar_SA':
      return messages_ar_sa.messages;
    case 'de_DE':
      return messages_de_de.messages;
    case 'en':
      return messages_en.messages;
    case 'es_ES':
      return messages_es_es.messages;
    case 'fr_FR':
      return messages_fr_fr.messages;
    case 'hi_IN':
      return messages_hi_in.messages;
    case 'ja_JP':
      return messages_ja_jp.messages;
    case 'kn_IN':
      return messages_kn_in.messages;
    case 'ko_KR':
      return messages_ko_kr.messages;
    case 'ru_RU':
      return messages_ru_ru.messages;
    case 'ta_IN':
      return messages_ta_in.messages;
    case 'te_IN':
      return messages_te_in.messages;
    case 'th_TH':
      return messages_th_th.messages;
    case 'ur_PK':
      return messages_ur_pk.messages;
    case 'zh_CN':
      return messages_zh_cn.messages;
    default:
      return null;
  }
}

/// User programs should call this before using [localeName] for messages.
Future<bool> initializeMessages(String localeName) {
  var availableLocale = Intl.verifiedLocale(
      localeName, (locale) => _deferredLibraries[locale] != null,
      onFailure: (_) => null);
  if (availableLocale == null) {
    return new SynchronousFuture(false);
  }
  var lib = _deferredLibraries[availableLocale];
  lib == null ? new SynchronousFuture(false) : lib();
  initializeInternalMessageLookup(() => new CompositeMessageLookup());
  messageLookup.addLocale(availableLocale, _findGeneratedMessagesFor);
  return new SynchronousFuture(true);
}

bool _messagesExistFor(String locale) {
  try {
    return _findExact(locale) != null;
  } catch (e) {
    return false;
  }
}

MessageLookupByLibrary? _findGeneratedMessagesFor(String locale) {
  var actualLocale =
      Intl.verifiedLocale(locale, _messagesExistFor, onFailure: (_) => null);
  if (actualLocale == null) return null;
  return _findExact(actualLocale);
}
