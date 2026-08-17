import 'package:html/dom.dart' as html_dom;
import 'package:html/parser.dart' as html_parser;

bool ecoUnityLooksLikeHtml(String value) {
  for (int index = 0; index < value.length - 2; index += 1) {
    if (value.codeUnitAt(index) != 0x3C) {
      continue;
    }
    final int next = value.codeUnitAt(index + 1);
    final bool plausibleTag =
        _isAsciiLetter(next) || next == 0x2F || next == 0x21;
    if (plausibleTag && value.indexOf('>', index + 2) != -1) {
      return true;
    }
  }
  return false;
}

String ecoUnityPlainText(String value, {int? maxLength}) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '';
  }

  final String extracted = ecoUnityLooksLikeHtml(trimmed)
      ? _extractHtmlText(trimmed)
      : trimmed;
  final String normalized = _collapseWhitespace(extracted);
  if (maxLength == null || normalized.length <= maxLength) {
    return normalized;
  }
  if (maxLength <= 0) {
    return '';
  }
  if (maxLength <= 3) {
    return normalized.substring(0, maxLength);
  }

  final int targetLength = maxLength - 3;
  int endIndex = normalized.lastIndexOf(' ', targetLength);
  if (endIndex < targetLength ~/ 2) {
    endIndex = targetLength;
  }
  return '${normalized.substring(0, endIndex).trimRight()}...';
}

String _extractHtmlText(String html) {
  final html_dom.DocumentFragment fragment = html_parser.parseFragment(html);
  final StringBuffer buffer = StringBuffer();
  for (final html_dom.Node node in fragment.nodes) {
    _writeNodeText(node, buffer);
  }
  return buffer.toString();
}

void _writeNodeText(html_dom.Node node, StringBuffer buffer) {
  if (node is html_dom.Text) {
    buffer.write(node.data);
    return;
  }

  if (node is html_dom.Element) {
    final String tagName = node.localName?.toLowerCase() ?? '';
    if (_ignoredTextTags.contains(tagName)) {
      return;
    }
    if (tagName == 'br' || tagName == 'hr') {
      _appendSpace(buffer);
      return;
    }

    final bool separatesText = _blockTextTags.contains(tagName);
    if (separatesText) {
      _appendSpace(buffer);
    }
    for (final html_dom.Node child in node.nodes) {
      _writeNodeText(child, buffer);
    }
    if (separatesText) {
      _appendSpace(buffer);
    }
    return;
  }

  for (final html_dom.Node child in node.nodes) {
    _writeNodeText(child, buffer);
  }
}

void _appendSpace(StringBuffer buffer) {
  if (buffer.isEmpty) {
    return;
  }
  final String current = buffer.toString();
  if (!_isWhitespace(current.runes.last)) {
    buffer.write(' ');
  }
}

String _collapseWhitespace(String value) {
  final StringBuffer buffer = StringBuffer();
  bool pendingSpace = false;
  bool wroteText = false;

  for (final int rune in value.runes) {
    if (_isWhitespace(rune)) {
      if (wroteText) {
        pendingSpace = true;
      }
      continue;
    }
    if (pendingSpace) {
      buffer.write(' ');
      pendingSpace = false;
    }
    buffer.writeCharCode(rune);
    wroteText = true;
  }

  return buffer.toString();
}

bool _isWhitespace(int rune) {
  return rune <= 0x20 ||
      rune == 0xA0 ||
      rune == 0x1680 ||
      rune == 0x2000 ||
      rune == 0x2001 ||
      rune == 0x2002 ||
      rune == 0x2003 ||
      rune == 0x2004 ||
      rune == 0x2005 ||
      rune == 0x2006 ||
      rune == 0x2007 ||
      rune == 0x2008 ||
      rune == 0x2009 ||
      rune == 0x200A ||
      rune == 0x2028 ||
      rune == 0x2029 ||
      rune == 0x202F ||
      rune == 0x205F ||
      rune == 0x3000;
}

bool _isAsciiLetter(int codeUnit) {
  return (codeUnit >= 0x41 && codeUnit <= 0x5A) ||
      (codeUnit >= 0x61 && codeUnit <= 0x7A);
}

const Set<String> _ignoredTextTags = <String>{'noscript', 'script', 'style'};

const Set<String> _blockTextTags = <String>{
  'address',
  'article',
  'aside',
  'blockquote',
  'dd',
  'details',
  'div',
  'dl',
  'dt',
  'figcaption',
  'figure',
  'footer',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'header',
  'li',
  'main',
  'nav',
  'ol',
  'p',
  'pre',
  'section',
  'table',
  'tbody',
  'td',
  'tfoot',
  'th',
  'thead',
  'tr',
  'ul',
};
