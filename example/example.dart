/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:docker2/docker2.dart';

void main(List<String> args) {
  final image = Docker().findImageByName('alpine');
  if (image != null) {
    image.delete();
  }

  /// If we don't have the image pull it.
  final alpineImage = Docker().pull('alpine');

  /// If the container exists then lets delete it so we can recreate it.
  final existing = Docker().findContainerByName('alpine_sleep_inifinity');
  if (existing != null) {
    existing.delete();
  }

  /// create container named alpine_sleep_inifinity
  final container =
      alpineImage.create('alpine_sleep_inifinity', argString: 'sleep infinity');

  if (Docker().findContainerByName('alpine_sleep_inifinity') == null) {
    // cli script
    // ignore: avoid_print
    print('Huston we have a container');
  }

  // start the container.
  container.start();
  sleep(2);

  /// stop the container.
  container.stop();

  while (container.isRunning) {
    sleep(1);
  }
  container.delete();
}
