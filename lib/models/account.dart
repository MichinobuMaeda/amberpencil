import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firestore_utils.dart';

class Account {
  final String id;
  final String name;
  final String? email;
  final String group;
  final bool valid;
  final bool admin;
  final bool tester;
  final int themeMode;
  final DateTime createdAt;
  final String? createdBy;
  final DateTime updatedAt;
  final String? updatedBy;
  final DateTime? deletedAt;
  final String? deletedBy;

  Account({
    required this.id,
    required this.name,
    this.email,
    required this.group,
    required this.valid,
    required this.admin,
    required this.tester,
    required this.themeMode,
    required this.createdAt,
    this.createdBy,
    required this.updatedAt,
    this.updatedBy,
    this.deletedAt,
    this.deletedBy,
  });

  Account.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap)
      : id = snap.id,
        name = getFieldValue<String>(snap, 'name') ?? '',
        email = getFieldValue<String>(snap, 'email'),
        group = getFieldValue<String>(snap, 'group'),
        valid = getFieldValue<bool>(snap, 'valid') ?? false,
        admin = getFieldValue<bool>(snap, 'admin') ?? false,
        tester = getFieldValue<bool>(snap, 'tester') ?? false,
        themeMode = getFieldValue<int>(snap, 'themeMode') ?? 0,
        createdAt = getFieldValue<DateTime>(snap, 'createdAt') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        createdBy = getFieldValue<DateTime>(snap, 'createdBy'),
        updatedAt = getFieldValue<DateTime>(snap, 'updatedAt') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        updatedBy = getFieldValue<DateTime>(snap, 'updatedBy'),
        deletedAt = getFieldValue<DateTime>(snap, 'deletedAt'),
        deletedBy = getFieldValue<DateTime>(snap, 'deletedBy');

  @override
  bool operator ==(Object other) =>
      other is Account &&
      other.id == id &&
      other.name == name &&
      other.email == email &&
      other.group == group &&
      other.valid == valid &&
      other.admin == admin &&
      other.tester == tester &&
      other.themeMode == themeMode &&
      other.createdAt == createdAt &&
      other.createdBy == createdBy &&
      other.updatedAt == updatedAt &&
      other.updatedBy == updatedBy &&
      other.deletedAt == deletedAt &&
      other.deletedBy == deletedBy;

  @override
  int get hashCode => hashValues(
        id,
        name,
        email,
        group,
        valid,
        admin,
        tester,
        themeMode,
        createdAt,
        createdBy,
        updatedAt,
        updatedBy,
        deletedAt,
        deletedBy,
      );
}
