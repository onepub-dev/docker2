/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

/// Simple class used to pass additional command line args to
/// docker commands.
class Arg {
  /// The name of the arg
  String name;

  /// The value of the arg
  String? value;

  /// Create an docker arg.
  /// e.g.
  /// docker create --format table
  /// [name] would be 'format'
  /// [value] would be 'table'
  Arg(this.name, this.value);
}
