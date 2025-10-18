import 'dart:convert';

import 'package:meta/meta.dart';

import 'containers.dart';
import 'docker.dart';
import 'exceptions.dart';
import 'image.dart';
import 'images.dart';
import 'volume.dart';
import 'volumes.dart';

/// A docker container.
@immutable
class Container {
  /// id of the container (the 12 char version)
  final String containerid;

  /// the id of the image this container is based on.
  final String imageid;

  /// the create date/time of this container.
  final String created;

  /// The status of this container.
  final String status;

  /// The ports used by this container
  final String ports;

  /// The name of this container.
  final String name;

  /// construct a docker container object from its parts.
  const Container({
    required this.containerid,
    required this.imageid,
    required this.created,
    required this.status,
    required this.ports,
    required this.name,
  });

  /// Creates a container from [image] binding the passed
  /// [Volume]s into the container.
  factory Container.create(Image image,
      {List<VolumeMount> volumes = const <VolumeMount>[],
      bool readonly = false}) {
    final volarg = StringBuffer();
    if (volumes.isNotEmpty) {
      for (final mount in volumes) {
        final readonlyArg = readonly ? ',readonly' : '';

        volarg.write("--mount 'type=volume,source=${mount.volume.name}"
            ",destination=${mount.mountPath}$readonlyArg'");
      }
    }
    final containerid =
        dockerRun('container', 'create $volarg ${image.name}').first;

    return Containers().findByContainerId(containerid)!;
  }

  /// Returns true if [other] has the same containerid as this
  /// container.
  /// We use the shorter 12 character version of the id.
  bool isSame(Container other) => containerid == other.containerid;

  @override
  bool operator ==(covariant Container other) {
    if (identical(this, other)) {
      return true;
    }

    if (containerid == other.containerid) {
      return true;
    }

    return false;
  }

  /// returns the list of volumes attached to this container.
  List<Volume> get volumes {
    final volumes = <Volume>[];

    final line =
        dockerRun('inspect', '$containerid --format "{{json .Mounts}}"').first;

    if (line == '[]') {
      return volumes;
    }

    final list = jsonDecode(line) as List<dynamic>;
    for (final v in list) {
      // it's json.
      // ignore: avoid_dynamic_calls
      final type = v['Type'] as String;
      if (type == 'volume') {
        // it's json.
        // ignore: avoid_dynamic_calls
        final name = v['Name']! as String;
        final volume = Volumes().findByName(name);
        if (volume == null) {
          throw UnknownVolumeException(
              'The container $containerid contains an unknown Volume $name');
        }
        volumes.add(volume);
      }
    }

    return volumes;
  }

  @override
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

    var terminal = false;
    if (!daemon) {
      cmdArgs = '--attach --interactive $cmdArgs';
      terminal = true;
    }
    dockerRun('start', cmdArgs, terminal: terminal);
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
    dockerRun('exec', '-it $containerid /bin/bash', terminal: true);
  }

  @override
  String toString() => '$containerid ${image?.fullname} $status $name';
}

/// Describes a [Volume] and where it is to be mounted
/// in a container.
class VolumeMount {
  /// The volume to mount.
  Volume volume;

  /// The path within the container the volume is to be mounted into.
  String mountPath;

  /// Describes a [Volume] and where it is to be mounted
  /// in a container.
  VolumeMount(this.volume, this.mountPath);
}
