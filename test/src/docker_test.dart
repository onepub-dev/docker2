@Timeout(Duration(seconds: 45))
import 'package:dcli/dcli.dart' hide equals;
import 'package:docker2/docker2.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    'docker rm hello-world'.start(nothrow: true, progress: Progress.devNull());
    'docker container rm test_container'
        .start(nothrow: true, progress: Progress.devNull());
  });
  test('docker pull', () async {
    final imagePulled = Docker().pull('hello-world');

    final imageFound = Docker().findImageByName('hello-world');

    expect(imagePulled, equals(imageFound));
  });

  test('docker create', () async {
    final imagePulled = Docker().pull('hello-world');

    final container = Docker().create(imagePulled, 'test_container');

    expect(Docker().findContainerById(container.containerid), isNotNull);
    expect(container.isSame(Docker().findContainerById(container.containerid)!),
        isTrue);

    expect(Docker().findContainerByName(container.name), isNotNull);
    expect(container.isSame(Docker().findContainerByName(container.name)!),
        isTrue);
  });

  test('docker start/stop container', () async {
    final imagePulled = Docker().pull('alpine');
    Docker().pull('hello-world');

    if (Docker().findContainerByName('alpine_sleep') == null) {
      Docker().create(imagePulled, 'alpine_sleep', argString: 'sleep infinity');
    }

    final container = Docker().findContainerByName('alpine_sleep');
    expect(container, isNotNull);
    container!.start();
    sleep(2);
    expect(container.isRunning, isTrue);
    container.stop();
    sleep(4);
    expect(container.isRunning, isFalse);
  });

  test('containers', () {
    final imagePulled = Docker().pull('alpine');
    final c1 = Docker().create(imagePulled, 'test_container1');
    final c2 = Docker().create(imagePulled, 'test_container2');

    final containers = Docker().containers();

    expect(
        containers.firstWhere((element) => element.name == 'test_container1'),
        isNotNull);

    expect(
        containers.firstWhere((element) => element.name == 'test_container2'),
        isNotNull);

    c1.delete();
    c2.delete();
  });

  test('docker delete container', () async {
    final imagePulled = Docker().pull('hello-world');

    if (Docker().findContainerByName('test_container') == null) {
      Docker().create(imagePulled, 'test_container');
    }

    final container = Docker().findContainerByName('test_container');
    expect(container, isNotNull);
    container!.delete();
    expect(Docker().findContainerById(container.containerid), isNull);
  });

  test('example', () {
    /// If we don't have the image pull it.
    final alpineImage = Docker().pull('alpine');

    /// If the container exists then lets delete it so we can recreate it.
    final existing = Docker().findContainerByName('alpine_sleep_inifinity');
    if (existing != null) {
      existing.delete();
    }

    /// create container named alpine_sleep_inifinity
    final container = alpineImage.create('alpine_sleep_inifinity',
        argString: 'sleep infinity');

    if (Docker().findContainerByName('alpine_sleep_inifinity') == null) {
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
  });
}
