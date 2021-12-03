import 'package:dcli/dcli.dart';
import 'package:docker2/docker2.dart';
import 'package:test/test.dart';

void main() {
  test('volumes create/find/delete', () async {
    final volume = Volume.create();
    testVolume(volume);

    withTempFile((path) {
      final name = basename(path);
      final t2 = Volume.create(name: name);
      testVolume(t2);
    });
  });

  test('container volumes', () async {
    final volume = Volume.create();
    testVolume(volume);

    withTempFile((path) {
      final name = basename(path);
      final t2 = Volume.create(name: name);
      testVolume(t2);
    });
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
