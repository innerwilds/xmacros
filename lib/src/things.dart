import 'dart:async';

import 'package:collection/collection.dart';
import 'package:macros/macros.dart';

extension XDeclarationPhaceIntrospector on DeclarationPhaseIntrospector {
  FutureOr<ClassDeclaration?> maybeClassOf(MemberDeclaration decl) async {
    final type = await typeDeclarationOf(decl.definingType);

    if (type is ClassDeclaration) {
      return type;
    }

    return null;
  }

  FutureOr<MethodDeclaration?> getterOf(TypeDeclaration decl, String name) async {
    final methods = await methodsOf(decl);
    return methods.firstWhereOrNull((method) {
      return method.isGetter && method.identifier.name == name;
    });
  }

  FutureOr<List<MethodDeclaration>> gettersOf(TypeDeclaration decl) async {
    final methods = await methodsOf(decl);
    return methods.where((method) => method.isGetter).toList();
  }

  FutureOr<List<MethodDeclaration>> settersOf(TypeDeclaration decl) async {
    final methods = await methodsOf(decl);
    return methods.where((method) => method.isSetter).toList();
  }

  FutureOr<MethodDeclaration?> setterOf(TypeDeclaration decl, String name) async {
    final methods = await methodsOf(decl);
    return methods.firstWhereOrNull((method) {
      return method.isSetter && method.identifier.name == name;
    });
  }

  FutureOr<MethodDeclaration?> operatorOf(TypeDeclaration decl, String name) async {
    final methods = await methodsOf(decl);
    return methods.firstWhereOrNull((method) {
      return method.isOperator && method.identifier.name == name;
    });
  }

  FutureOr<List<FieldDeclaration>> allFieldsOf(TypeDeclaration decl, {
    bool includePrivate = true,
  }) async {
    return [
      for (final field in await fieldsOf(decl))
        if (includePrivate || !field.identifier.name.startsWith('_'))
          field,
    ];
  }

  FutureOr<MethodDeclaration?> methodOf(TypeDeclaration type, String methodName) async {
    final methods = await methodsOf(type);
    return methods.firstWhereOrNull((e) =>
      e.identifier.name == methodName &&
      !e.isGetter && !e.isSetter);
  }

  FutureOr<ConstructorDeclaration?> constructorOf(TypeDeclaration type, String name) async {
    return (await constructorsOf(type)).firstWhereOrNull((ctor) {
      return ctor.identifier.name == name;
    });
  }
}

extension XBuilder on Builder {
  void error(String m, [DiagnosticTarget? target]) {
    report(Diagnostic(DiagnosticMessage(m, target: target), Severity.error));
  }
  void info(String m, [DiagnosticTarget? target]) {
    report(Diagnostic(DiagnosticMessage(m, target: target), Severity.info));
  }
  void warn(String m, [DiagnosticTarget? target]) {
    report(Diagnostic(DiagnosticMessage(m, target: target), Severity.warning));
  }
}

extension XFieldDeclaration on FieldDeclaration {
  bool get isPrivate => identifier.name.startsWith('_');
  bool get isPublic => !isPrivate;
}