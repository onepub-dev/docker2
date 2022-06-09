/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'package:dcli/dcli.dart';

import '../../docker2.dart';

///
/// Builds a docker image from the docker file at [pathToDockerFile]
/// Giving it a name of [imageName]:[version]
/// If you set the optional [clean] argument to true then the build
/// will be run with the --no-cache flag set.
///
/// You can pass additional docker build args in the [buildArgs] argument.
/// The args should be passed in the form ['arg=value']
///
/// If passed, the [workingDirectory] is used when running the
/// docker build command. This is important as it affects what
/// files the docker build command will add to its context.
/// If not passed then the current working directory will be used.
Image build(
    {required String pathToDockerFile,
    required String imageName,
    required String version,
    bool clean = false,
    List<String> buildArgs = const <String>[],
    String? repository,
    String? workingDirectory}) {
  var cleanArg = '';
  if (clean) {
    cleanArg = ' --no-cache';
  }

  workingDirectory ??= pwd;

  final tag =
      tagName(repository: repository, imageName: imageName, version: version);

  final buildArgList = StringBuffer();
  if (buildArgs.isNotEmpty) {
    for (final arg in buildArgs) {
      buildArgList.write('--build-arg $arg ');
    }
  }

  'docker  build $buildArgList $cleanArg -t $tag'
          ' -f $pathToDockerFile .'
      .start(workingDirectory: workingDirectory);

  return Image.fromName(tag);
}

// Publishes the image to a docker repository.
// The [image]'s repository must be set.
void publish({required Image image}) {
  'docker push ${image.fullname}'.run;
}

String tagName(
        {required String imageName,
        required String version,
        String? repository}) =>
    repository != null
        ? '$repository/$imageName:$version'
        : '$imageName:$version';

String tagNameLatest({required String imageName, String? repository}) =>
    repository != null ? '$repository/$imageName:latest' : '$imageName:latest';
