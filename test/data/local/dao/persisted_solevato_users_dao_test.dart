import 'dart:io';

import 'package:solevato_client_sdk_flutter/data/local/dao/solevato_user_dao.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group("Persisted Solevato User Dao Tests", () {
    late PersistedSolevatoUserDao dao;
    late Box<String> mockClientInstanceKeyToUserBox;
    late Box<SolevatoUser> mockUserBox;
    final testClientInstanceKey = "testKey";

    final testUser = SolevatoUser(
        identifier: "identifier",
        identifierHash: "identifierHash",
        name: "name",
        email: "email",
        avatarUrl: "avatarUrl",
        customAttributes: {});

    setUpAll(() {
      return Future(() async {
        final hiveTestPath = Directory.current.path + '/test/hive_testing_path';
        Hive
          ..init(hiveTestPath)
          ..registerAdapter(SolevatoUserAdapter());
      });
    });

    setUp(() {
      return Future(() async {
        mockUserBox = await Hive.openBox(SolevatoUserBoxNames.USERS.toString());
        mockClientInstanceKeyToUserBox = await Hive.openBox(
            SolevatoUserBoxNames.CLIENT_INSTANCE_TO_USER.toString());

        dao = PersistedSolevatoUserDao(
            mockUserBox, mockClientInstanceKeyToUserBox, testClientInstanceKey);
      });
    });

    test(
        'Given user is successfully deleted when deleteUser is called, then getUser should return null',
        () async {
      //GIVEN
      await dao.saveUser(testUser);

      //WHEN
      await dao.deleteUser();

      //THEN
      expect(dao.getUser(), null);
    });

    test(
        'Given user is successfully save when saveUser is called, then getUser should return saved user',
        () async {
      //WHEN
      await dao.saveUser(testUser);

      //THEN
      expect(dao.getUser(), testUser);
    });

    test(
        'Given user is successfully retrieved when getUser is called, then retrieved user should not be null',
        () async {
      //GIVEN
      await dao.saveUser(testUser);

      //WHEN
      final retrievedUser = dao.getUser();

      //THEN
      expect(retrievedUser, testUser);
    });

    test(
        'Given users are successfully cleared when clearAll is called, then retrieving a user should be null',
        () async {
      //GIVEN
      await dao.saveUser(testUser);

      //WHEN
      await dao.clearAll();

      //THEN
      expect(dao.getUser(), null);
    });

    tearDown(() {
      return Future(() async {
        try {
          await mockUserBox.clear();
          await mockClientInstanceKeyToUserBox.clear();
        } on HiveError catch (e) {
          print(e);
        }
      });
    });

    tearDownAll(() {
      return Future(() async {
        await mockUserBox.close();
        await mockClientInstanceKeyToUserBox.close();
      });
    });
  });
}
