/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:meta/meta.dart';

import '../../docker2.dart';
import 'exceptions.dart';

/// A docker container.
@immutable
class Volume {
  /// The name of this volume.
  final String name;

  /// Driver of this volume
  final String driver;

  /// host path where the volume lives
  final String mountpoint;

  /// Labels
  final List<VolumeLabel> labels;

  /// The scope of the volume.
  final String scope;

  /// construct a docker container object from its parts.
  const Volume({
    required this.name,
    required this.driver,
    required this.mountpoint,
    required this.labels,
    required this.scope,
  });

  /// Returns true if [other] has the same name as this
  /// volume.
  bool isSame(Volume other) => name == other.name;

  @override
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

    Volume? volume;
    var retry = 10;

    /// The volume isn't always immediately visible so we wait a little.
    while (volume == null && retry > 0) {
      volume = Volumes().findByName(givenName);
      if (volume == null) {
        sleep(1);
      }
      retry--;
    }
    if (volume == null) {
      throw VolumeCreateException(
          'Unable to find the newly created volume $name');
    }

    return volume;
  }

  @override
  // the name is immutable.
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
