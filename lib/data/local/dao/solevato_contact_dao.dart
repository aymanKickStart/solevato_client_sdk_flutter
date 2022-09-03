import 'package:hive_flutter/hive_flutter.dart';

import '../entity/solevato_contact.dart';

///Data access object for retriving solevato contact from local storage
abstract class SolevatoContactDao {
  Future<void> saveContact(SolevatoContact contact);
  SolevatoContact? getContact();
  Future<void> deleteContact();
  Future<void> onDispose();
  Future<void> clearAll();
}

//Only used when persistence is enabled
enum SolevatoContactBoxNames { CONTACTS, CLIENT_INSTANCE_TO_CONTACTS }

class PersistedSolevatoContactDao extends SolevatoContactDao {
  //box containing all persisted contacts
  Box<SolevatoContact> _box;

  //_box with one to one relation between generated client instance id and conversation id
  final Box<String> _clientInstanceIdToContactIdentifierBox;

  final String _clientInstanceKey;

  PersistedSolevatoContactDao(this._box,
      this._clientInstanceIdToContactIdentifierBox, this._clientInstanceKey);

  @override
  Future<void> deleteContact() async {
    final contactIdentifier =
        _clientInstanceIdToContactIdentifierBox.get(_clientInstanceKey);
    await _clientInstanceIdToContactIdentifierBox.delete(_clientInstanceKey);
    await _box.delete(contactIdentifier);
  }

  @override
  Future<void> saveContact(SolevatoContact contact) async {
    await _clientInstanceIdToContactIdentifierBox.put(
        _clientInstanceKey, contact.contactIdentifier!);
    await _box.put(contact.contactIdentifier, contact);
  }

  @override
  SolevatoContact? getContact() {
    if (_box.values.length == 0) {
      return null;
    }

    final contactIdentifier =
        _clientInstanceIdToContactIdentifierBox.get(_clientInstanceKey);

    if (contactIdentifier == null) {
      return null;
    }

    return _box.get(contactIdentifier, defaultValue: null);
  }

  @override
  Future<void> onDispose() async {}

  Future<void> clearAll() async {
    await _box.clear();
    await _clientInstanceIdToContactIdentifierBox.clear();
  }

  static Future<void> openDB() async {
    await Hive.openBox<SolevatoContact>(
        SolevatoContactBoxNames.CONTACTS.toString());
    await Hive.openBox<String>(
        SolevatoContactBoxNames.CLIENT_INSTANCE_TO_CONTACTS.toString());
  }
}

class NonPersistedSolevatoContactDao extends SolevatoContactDao {
  SolevatoContact? _contact;

  @override
  Future<void> deleteContact() async {
    _contact = null;
  }

  @override
  SolevatoContact? getContact() {
    return _contact;
  }

  @override
  Future<void> onDispose() async {
    _contact = null;
  }

  @override
  Future<void> saveContact(SolevatoContact contact) async {
    _contact = contact;
  }

  Future<void> clearAll() async {
    _contact = null;
  }
}
