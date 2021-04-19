import 'package:dcli/dcli.dart';
import 'containers.dart';
import 'exceptions.dart';

import 'image.dart';
import 'images.dart';

/// Provides methods for manipulating a docker container.
class Container {
  /// Construct a Container instance
  Container({
    required this.containerid,
    required this.imageid,
    required this.created,
    required this.status,
    required this.ports,
    required this.names,
  });

  /// The containers id
  String containerid;

  /// The id of the image this container is based on.
  String imageid;

  /// The date the container was created.
  String created;

  /// The status of the container.
  String status;

  ///
  String ports;

  /// the names of the container.
  String names;

  /// Returns the image the docker container is based on.
  Image? get image => Images().findByImageId(imageid);

  /// Stops the container if it is running.
  /// Throws [ContainerNotRunning] if the container is not currently running.
  void stop() {
    if (!isRunning) {
      throw ContainerNotRunning();
    }
    'docker stop $containerid'.run;
  }

  /// Starts a docker container.
  // Throws [ContainerAlreadyRunning] if the container is already running.
  ///
  void start() {
    if (isRunning) {
      throw ContainerAlreadyRunning();
    }

    'docker start $containerid'.start(
        progress: Progress(print, stderr: (line) => printerr(red(line))));
  }

  /// Returns true if the container is already running.
  bool get isRunning =>
      "docker container inspect -f '{{.State.Running}}' $containerid"
          .firstLine ==
      'true';

  /// Delete the container.
  void delete() {
    'docker container rm $containerid'.run;

    Containers().flushCache();
  }

  /// Print the docker logs for the container to stdout.
  void showLogs() {
    'docker logs $containerid'.run;
  }

  /// Attaches to the running container and starts a bash command prompt.
  void cli() {
    'docker exec -it $containerid /bin/bash'
        .start(nothrow: true, progress: Progress.print(), terminal: true);
  }
}
