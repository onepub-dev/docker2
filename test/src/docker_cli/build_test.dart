import 'package:dcli/dcli.dart';
import 'package:docker2/docker2.dart';
import 'package:test/test.dart';

void main() {
  test('build ...', () async {
    final pathToHelloDocker = join(DartProject.self.pathToProjectRoot, 'test',
        'fixtures', 'hello.dockerfile');
    build(
      pathToDockerFile: pathToHelloDocker,
      imageName: 'hello',
      version: '1.0.0',
      buildArgs: ['hello=hi'],
    );
  });
}
