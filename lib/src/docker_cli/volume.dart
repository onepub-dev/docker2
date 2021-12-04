// ignore_for_file: unnecessary_cast

import '../../docker2.dart';
import 'exceptions.dart';

/// A docker container.
class Volume {
  /// construct a docker container object from its parts.
  Volume({
    required this.name,
    required this.driver,
    required this.mountpoint,
    required this.labels,
    required this.scope,
  });

  /// The name of this volume.
  String name;

  /// Driver of this volume
  String driver;

  /// host path where the volume lives
  String mountpoint;

  /// Labels
  List<VolumeLabel> labels;

  /// The scope of the volume.
  String scope;

  /// Returns true if [other] has the same name as this
  /// volume.
  bool isSame(Volume other) => name == other.name;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(covariant Volume other) {
    if (identical(this, other)) {
      return true;
    }

    if (name == other.name) {
      return true;
    }

    return false;
  }

  /// deletes this docker volume.
  /// Throws a [DockerCommandFailed] if the delete fails.
  void delete() {
    dockerRun('volume', 'rm $name');
  }

  /// Creates a docker volume
  ///
  /// If you pass [name] then the volume will be created with that name
  /// otherwise docker will generate a random uuid for the name.
  /// If an error occurs a [VolumeCreateException] is thrown
  static Volume create({String? name, String driver = 'local'}) {
    final givenName =
        dockerRun('volume', 'create ${name ?? ''}  --driver $driver').first;

    final volume = Volumes().findByName(givenName);
    if (volume == null) {
      throw VolumeCreateException(
          'Unable to find the newly created volume $name');
    }

    return volume;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => name.hashCode;

  @override
  String toString() => '$name $driver $mountpoint';

  // factory Volume.fromJson(Map<String, String> v) {
  //   final type = v['Type'];
  //   assert(type == 'volume', 'Must be a volume');
  //   final mountpoint = v['Source']! as String;
  //   final name = v['Name']! as String;

  //   /// where it is mounted into the container.
  //   final desitnation = v['Destination']! as String;
  //   final driver = v['Driver']! as String;
  //   final mode = v['Mode']! as String; // ='rw',
  //   final rw = v['RW']! as bool;
  //   final propogation = v['Propagation']! as String;

  //   return Volume(name: name, driver: driver, mountpoint: mountpoint);
  // }
}
