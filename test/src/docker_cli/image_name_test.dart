/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:docker2/docker2.dart';
import 'package:test/test.dart';

void main() {
  test('image name ...', () {
    var imageName = ImageName.fromName('ubuntu');
    expect(imageName.registry, isNull);
    expect(imageName.repository, isNull);
    expect(imageName.name, equals('ubuntu'));
    expect(imageName.tag, isNull);
    expect(imageName.fullname, 'ubuntu');

    imageName = ImageName.fromName('canonical/ubuntu');
    expect(imageName.registry, isNull);
    expect(imageName.repository, equals('canonical'));
    expect(imageName.name, equals('ubuntu'));
    expect(imageName.tag, isNull);
    expect(imageName.fullname, 'canonical/ubuntu');

    imageName = ImageName.fromName('docker.io/canonical/ubuntu');
    expect(imageName.name, equals('ubuntu'));
    expect(imageName.repository, equals('canonical'));
    expect(imageName.registry, equals('docker.io'));
    expect(imageName.tag, isNull);
    expect(imageName.fullname, 'docker.io/canonical/ubuntu');

    imageName = ImageName.fromName('docker.io/canonical/ubuntu:latest');
    expect(imageName.name, equals('ubuntu'));
    expect(imageName.repository, equals('canonical'));
    expect(imageName.registry, equals('docker.io'));
    expect(imageName.tag, equals('latest'));
    expect(imageName.fullname, 'docker.io/canonical/ubuntu:latest');

    imageName = ImageName.fromName('docker.io/canonical/ubuntu:22.04');
    expect(imageName.name, equals('ubuntu'));
    expect(imageName.repository, equals('canonical'));
    expect(imageName.registry, equals('docker.io'));
    expect(imageName.tag, equals('22.04'));
    expect(imageName.fullname, 'docker.io/canonical/ubuntu:22.04');

    imageName = ImageName.fromName('docker.io/ubuntu:22.04');
    expect(imageName.name, equals('ubuntu'));
    expect(imageName.repository, isNull);
    expect(imageName.registry, equals('docker.io'));
    expect(imageName.tag, equals('22.04'));
    expect(imageName.fullname, 'docker.io/ubuntu:22.04');

    imageName = ImageName.fromName('docker.io/ubuntu');
    expect(imageName.name, equals('ubuntu'));
    expect(imageName.repository, isNull);
    expect(imageName.registry, equals('docker.io'));
    expect(imageName.tag, isNull);
    expect(imageName.fullname, 'docker.io/ubuntu');
  });
}
