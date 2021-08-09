import 'docker.dart';
import 'exceptions.dart';
import 'image.dart';
import 'images.dart';

/// A docker container.
class Container {
  /// construct a docker container object from its parts.
  Container({
    required this.containerid,
    required this.imageid,
    required this.created,
    required this.status,
    required this.ports,
    required this.name,
  });

  /// id of the container (the 12 char version)
  String containerid;

  /// the id of the image this container is based on.
  String imageid;

  /// the create date/time of this container.
  String created;

  /// The status of this container.
  String status;

  /// The ports used by this container
  String ports;

  /// The name of this container.
  String name;

  /// Returns true if [other] has the same containerid as this
  /// container.
  /// We use the shorter 12 character version of the id.
  bool isSame(Container other) => containerid == other.containerid;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(covariant Container other) {
    if (this == other) {
      return true;
    }

    if (containerid == other.containerid) {
      return true;
    }

    return false;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => containerid.hashCode;

  /// returns the image based on this image's id.
  /// We actually refetch the list of images to ensure
  /// we have the complete set of details.
  Image? get image => Images().findByImageId(imageid);

  /// Tops tthe docker container if it is running.
  /// If the container is not running then no action is taken.
  void stop() {
    if (isRunning) {
      dockerRun('stop', containerid);
    }
  }

  /// Starts a docker container.
  /// If [daemon] is true (the default) then the container is started
  /// as a daemon. When [daemon] is false then we pass the interactive and
  /// attach arguments to the docker start command to allow full interaction.
  // Throws [ContainerAlreadyRunning] if the container is already running.
  ///
  /// The [args] and [argString] are appended to the command
  /// and allow you to add abitrary arguments.
  /// The [args] list is added before the [argString].
  void start({List<String>? args, String? argString, bool daemon = true}) {
    if (isRunning) {
      throw ContainerAlreadyRunning();
    }

    var cmdArgs = containerid;

    if (args != null) {
      cmdArgs += ' ${args.join(' ')}';
    }
    if (argString != null) {
      cmdArgs += ' $argString';
    }

    if (!daemon) {
      cmdArgs = '--attach --interactive $cmdArgs';
    }
    dockerRun('start', cmdArgs);
  }

  /// Returns true if the container is currently running.
  bool get isRunning =>
      dockerRun('container', "inspect -f '{{.State.Running}}' $containerid")
          .first ==
      'true';

  /// deletes this docker container.
  void delete() {
    dockerRun('container', 'rm $containerid');
  }

  /// writes this containers docker logs to the console
  /// If [limit] is 0 (the default) all log lines a output.
  /// If [limit] is > 0 then only the last [limit] lines are output.
  void showLogs({int limit = 0}) {
    var limitFlag = '';
    if (limit != 0) {
      limitFlag = '-n $limit';
    }
    dockerRun('logs', '$limitFlag $containerid');
  }

  /// Attaches to the running container and starts a bash command prompt.
  void cli() {
    dockerRun('exec', '-it $containerid /bin/bash');
  }

  @override
  String toString() => '$containerid ${image?.fullname} $status $name';
}
