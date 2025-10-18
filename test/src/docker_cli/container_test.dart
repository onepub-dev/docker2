/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:docker2/docker2.dart';
import 'package:docker2/src/docker_cli/exceptions.dart';
import 'package:test/test.dart';

void main() {
  test('container create', () {
    final images = Images().findAllByName('hello-world:latest');

    Image? hellow;
    if (images.isNotEmpty) {
      for (final image in images.skip(1)) {
        image.delete();
      }
      hellow = images.first;
    } else {
      hellow = Images().pull(fullname: 'hello-world:latest');
      expect(hellow != null, isTrue);
    }

    final container = Container.create(hellow!);
    expect(container.image == hellow, isTrue);

    container.delete();
  });

  test('container create with volume', () {
    final images = Images().findAllByName('hello-world:latest');

    Image? hellow;
    if (images.isNotEmpty) {
      for (final image in images.skip(1)) {
        image.delete();
      }
      hellow = images.first;
    } else {
      hellow = Images().pull(fullname: 'hello-world:latest');
      expect(hellow != null, isTrue);
    }
    // create volume.
    final volume = Volume.create(name: 'hello_world_volume');
    const mountPoint = '/home/hellow';
    final container =
        Container.create(hellow!, volumes: [VolumeMount(volume, mountPoint)]);
    expect(container.image == hellow, isTrue);
    final volumes = container.volumes;
    expect(volumes.length == 1, isTrue);
    final theOne = volumes.first;
    expect(theOne == volume, isTrue);
    expect(theOne.name == 'hello_world_volume', isTrue);
    expect(theOne.mountpoint == volume.mountpoint, isTrue);

    container.delete();
  });

  test('Delete non existant container', () {
    final hellow = Images().pull(fullname: 'hello-world:latest');
    expect(hellow != null, isTrue);
    final container = Container.create(hellow!)..delete();
    expect(container.delete, throwsA(isA<DockerCommandFailed>()));
  });
}
