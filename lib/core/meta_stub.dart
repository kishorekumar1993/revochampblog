// lib/core/meta_stub.dart

// ignore_for_file: camel_case_types

class html {
  static final window = _Window();
  static final document = _Document();
}

// ---------------- WINDOW ----------------
class _Window {
  final location = _Location();
}

class _Location {
  String get origin => '';
}

// ---------------- DOCUMENT ----------------
class _Document {
  dynamic head;

  void append(dynamic _) {}

  dynamic querySelector(String _) => null;

  dynamic getElementById(String _) => null;
}

// ---------------- ELEMENT TYPES ----------------
class ScriptElement {
  String? id;
  String? type;
  String? text;
}

class LinkElement {
  String? rel;
  String? href;
}

class MetaElement {
  String? content;

  void setAttribute(String _, String __) {}
}