/// Decodifica entidades HTML comuns em português que podem
/// vir corrompidas no banco de dados.
String decodeHtmlEntities(String input) {
  if (input.isEmpty) return input;
  return input
      // minúsculas acentuadas
      .replaceAll('&aacute;', 'á')
      .replaceAll('&eacute;', 'é')
      .replaceAll('&iacute;', 'í')
      .replaceAll('&oacute;', 'ó')
      .replaceAll('&uacute;', 'ú')
      .replaceAll('&agrave;', 'à')
      .replaceAll('&egrave;', 'è')
      .replaceAll('&atilde;', 'ã')
      .replaceAll('&otilde;', 'õ')
      .replaceAll('&ntilde;', 'ñ')
      .replaceAll('&acirc;', 'â')
      .replaceAll('&ecirc;', 'ê')
      .replaceAll('&icirc;', 'î')
      .replaceAll('&ocirc;', 'ô')
      .replaceAll('&ucirc;', 'û')
      .replaceAll('&ccedil;', 'ç')
      .replaceAll('&auml;', 'ä')
      .replaceAll('&euml;', 'ë')
      .replaceAll('&iuml;', 'ï')
      .replaceAll('&ouml;', 'ö')
      .replaceAll('&uuml;', 'ü')
      // maiúsculas acentuadas
      .replaceAll('&Aacute;', 'Á')
      .replaceAll('&Eacute;', 'É')
      .replaceAll('&Iacute;', 'Í')
      .replaceAll('&Oacute;', 'Ó')
      .replaceAll('&Uacute;', 'Ú')
      .replaceAll('&Agrave;', 'À')
      .replaceAll('&Atilde;', 'Ã')
      .replaceAll('&Otilde;', 'Õ')
      .replaceAll('&Ntilde;', 'Ñ')
      .replaceAll('&Acirc;', 'Â')
      .replaceAll('&Ecirc;', 'Ê')
      .replaceAll('&Icirc;', 'Î')
      .replaceAll('&Ocirc;', 'Ô')
      .replaceAll('&Ccedil;', 'Ç')
      // caracteres especiais
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', '\'')
      .replaceAll('&apos;', '\'')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&mdash;', '—')
      .replaceAll('&ndash;', '–')
      .replaceAll('&laquo;', '«')
      .replaceAll('&raquo;', '»')
      .replaceAll('&copy;', '©')
      .replaceAll('&reg;', '®')
      // numéricos comuns
      .replaceAll('&#160;', ' ')
      .replaceAll('&#8211;', '–')
      .replaceAll('&#8212;', '—')
      .replaceAll('&#8220;', '\u201C')
      .replaceAll('&#8221;', '\u201D')
      .replaceAll('&#8216;', '\u2018')
      .replaceAll('&#8217;', '\u2019');
}

/// Extrai texto limpo removendo tags HTML e decodificando entidades.
String cleanHtmlText(String input) {
  if (input.isEmpty) return input;
  return decodeHtmlEntities(
    input.replaceAll(RegExp(r'<[^>]*>'), ''),
  ).trim();
}
