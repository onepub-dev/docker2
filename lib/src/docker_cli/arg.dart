/// Simple class used to pass additional command line args to
/// docker commands.
class Arg {
  /// Create an docker arg.
  /// e.g.
  /// docker create --format table
  /// [name] would be 'format'
  /// [value] would be 'table'
  Arg(this.name, this.value);

  /// The name of the arg
  String name;

  /// The value of the arg
  String? value;
}
