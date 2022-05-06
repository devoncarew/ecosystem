import 'dart:io';

import 'package:dashboard_cli/package_manager.dart';
import 'package:args/command_runner.dart';

// todo: support sdk
// todo: support google3
// todo: support scanning repos
// todo: support logging for changes

void main(List<String> arguments) async {
  final runner = UpdateRunner();

  try {
    final code = await runner.run(arguments) ?? 0;
    exit(code);
  } on UsageException catch (e) {
    stderr.writeln('$e');
    exit(1);
  }
}

class UpdateRunner extends CommandRunner<int> {
  UpdateRunner()
      : super(
          'update',
          'A tool to update the information for the packages health dashboard.',
        ) {
    addCommand(PackagesCommand());
    addCommand(SdkCommand());
    addCommand(RepositoriesCommand());
    addCommand(SheetsCommand());
    addCommand(StatsCommand());
  }
}

class PackagesCommand extends Command<int> {
  @override
  final String name = 'packages';

  @override
  List<String> get aliases => const ['pub'];

  @override
  final String description = 'Update information sourced from pub.dev.';

  PackagesCommand() {
    // todo: argsparser - allow for just updating specific publishers, packages,
    // ...
    argParser.addMultiOption(
      'publisher',
      valueHelp: 'publisher',
      help: 'Just update the info for the given publisher(s).',
    );
  }

  @override
  Future<int> run() async {
    List<String> specificPublishers = argResults!['publisher'];

    PackageManager packageManager = PackageManager();
    await packageManager.setup();
    if (specificPublishers.isEmpty) {
      await packageManager.updateAllPublisherPackages();
    } else {
      for (var publisher in specificPublishers) {
        await packageManager.updatePublisherPackages(publisher);
      }
    }
    await packageManager.close();
    return 0;
  }
}

class StatsCommand extends Command<int> {
  @override
  final String name = 'stats';

  @override
  final String description = 'Calculate and update daily package stats.';

  StatsCommand();

  @override
  Future<int> run() async {
    PackageManager packageManager = PackageManager();
    await packageManager.setup();
    await packageManager.updateHealthStats();
    await packageManager.close();
    return 0;
  }
}

// todo: support updating a specific repo
class RepositoriesCommand extends Command<int> {
  @override
  final String name = 'repositories';

  @override
  List<String> get aliases => const ['repo', 'repos'];

  @override
  final String description =
      'Update repository information sourced from github.';

  RepositoriesCommand();

  @override
  Future<int> run() async {
    PackageManager packageManager = PackageManager();
    await packageManager.setup();
    await packageManager.updateRepositories();
    await packageManager.close();
    return 0;
  }
}

class SdkCommand extends Command<int> {
  @override
  final String name = 'sdk';

  @override
  final String description =
      'Update information sourced from the Dart SDK repo.';

  SdkCommand();

  @override
  Future<int> run() async {
    PackageManager packageManager = PackageManager();
    await packageManager.setup();
    await packageManager.updateFromSdk();
    await packageManager.close();
    return 0;
  }
}

class SheetsCommand extends Command<int> {
  @override
  final String name = 'sheets';

  @override
  final String description =
      'Update maintainer information sourced from a Google sheet.';

  SheetsCommand();

  @override
  Future<int> run() async {
    PackageManager packageManager = PackageManager();
    await packageManager.setup();
    await packageManager.updateMaintainersFromSheets();
    await packageManager.close();
    return 0;
  }
}