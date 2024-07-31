/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:docker2/docker2.dart';
import 'package:docker2/src/docker_cli/exceptions.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('volumes create/find/delete', () async {
    final volume = Volume.create();
    testVolume(volume);

    await withTempFileAsync((path) async {
      final name = basename(path);
      final t2 = Volume.create(name: name);
      testVolume(t2);
    });
  });

  test('container volumes', () async {
    final volume = Volume.create();
    testVolume(volume);

    await withTempFileAsync((path) async {
      final name = basename(path);
      final t2 = Volume.create(name: name);
      testVolume(t2);
    });
  });

  test('volume - failed delete', () {
    final images = Images().findAllByName('hello-world:latest');
    final Image image;
    if (images.isEmpty) {
      image = Docker().pull('hello-world:latest');
    } else {
      image = images.first;
    }

    final volume = Volume.create();

    final container =
        Container.create(image, volumes: [VolumeMount(volume, '/data')]);

    expect(volume.delete, throwsA(isA<DockerCommandFailed>()));

    container.delete();
    volume.delete();

    expect(Volumes().findByName(volume.name) == null, isTrue);
  });
}

void testVolume(Volume volume) {
  final found = Volumes().findByName(volume.name);
  expect(found != null, isTrue);
  expect(found == volume, isTrue);
  expect(found!.scope == 'local', isTrue);
  expect(found.driver == 'local', isTrue);

  found.delete();
  expect(Volumes().findByName(volume.name) == null, isTrue);
}
