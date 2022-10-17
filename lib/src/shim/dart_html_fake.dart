// fix: INFO: Avoid using web-only libraries outside Flutter web plugin
// packages.

class HtmlHtmlElement {
  dynamic get style => null;

  dynamic setInnerHtml(String html, {NodeValidator? validator}) {}
}

class NodeValidatorBuilder {
  static dynamic common() {}
}

abstract class NodeValidator {}

abstract class UriPolicy {
  bool allowsUri(String uri);
}
