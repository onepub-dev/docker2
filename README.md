Docker CLI is Dart library for controlling docker images and containers.

Docker CLI wraps the docker cli tooling.

Example:

```dart
    /// If we don't have the image pull it.
    var alpineImage = Docker().pull('alpine');

    /// If the container exists then lets delete it so we can recreate it.
    var existing = Docker().findContainerByName('alpine_sleep_inifinity');
    if (existing != null) {
      existing.delete();
    }

    /// create container named alpine_sleep_inifinity
    var container = alpineImage.create('alpine_sleep_inifinity',
        argString: 'sleep infinity');

    if (Docker().findContainerByName('alpine_sleep_inifinity') == null) {
      print('Huston we have a container');
    }

    // start the container.
    container.start();
    sleep(2);
    
    /// stop the container.
    container.stop();

    while (container.isRunning)
    {
        sleep(1);
    }
    container.delete();

    Docker().volumes;
```
