import 'package:flutter/material.dart';

import '../model/data_model.dart';
import '../ui/table.dart';
import '../ui/widgets.dart';
import 'pub_page.dart';

class SDKPage extends NavPage {
  final DataModel dataModel;

  SDKPage(this.dataModel) : super('SDK');

  @override
  Widget createChild(BuildContext context, {Key? key}) {
    return _SDKPage(dataModel: dataModel, key: key);
  }
}

class _SDKPage extends StatelessWidget {
  final DataModel dataModel;

  const _SDKPage({
    required this.dataModel,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SDKDependenciesWidget(dataModel: dataModel);
  }
}

//             Text(
//               '${sdkDeps.length} repos, ${deps.length} packages',
//               textAlign: TextAlign.end,
//             ),

class SDKDependenciesWidget extends StatelessWidget {
  final DataModel dataModel;

  const SDKDependenciesWidget({
    required this.dataModel,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<PackageInfo>>(
      valueListenable: dataModel.packages,
      builder: (context, packages, _) {
        return ValueListenableBuilder<List<SdkDep>>(
          valueListenable: dataModel.sdkDependencies,
          builder: (context, sdkDeps, _) {
            List<PackageRepoDep> deps = _calculateDeps(sdkDeps, packages);

            return VTable<PackageRepoDep>(
              items: deps,
              columns: [
                VTableColumn(
                  label: 'Package',
                  width: 125,
                  grow: 0.2,
                  transformFunction: (dep) => dep.packageName ?? '',
                ),
                VTableColumn(
                  label: 'Publisher',
                  width: 125,
                  grow: 0.2,
                  transformFunction: (dep) => dep.packagePublisher ?? '',
                  validators: [
                    (dep) {
                      if (dep.packagePublisher == null) {
                        return ValidationResult.error('unverified publisher');
                      }

                      const stdPublishers = {
                        'dart.dev',
                        'google.dev',
                        'tools.dart.dev',
                      };
                      if (!stdPublishers.contains(dep.packagePublisher)) {
                        return ValidationResult.warning('Atypical publisher');
                      }

                      return null;
                    },
                  ],
                ),
                VTableColumn(
                  label: 'Commit',
                  width: 75,
                  grow: 0.2,
                  transformFunction: (dep) => dep.commit.substring(1, 10),
                ),
                VTableColumn(
                  label: 'Repo',
                  width: 275,
                  grow: 0.2,
                  transformFunction: (dep) => dep.repoUrl,
                  renderFunction: (BuildContext context, dep) {
                    return Hyperlink(url: dep.repoUrl);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<PackageInfo> _filterPackages(List<PackageInfo> packages, String repo) {
    packages = packages.where((p) => p.repoUrl == repo).toList();

    // Remove the discontinued packages.
    packages = packages.where((p) => !p.discontinued).toList();

    packages.sort((a, b) => a.name.compareTo(b.name));

    return packages;
  }

  List<PackageRepoDep> _calculateDeps(
    List<SdkDep> sdkDeps,
    List<PackageInfo> allPackages,
  ) {
    const gitDeps = {
      'https://github.com/dart-lang/http_io',
      'https://github.com/dart-lang/pub',
      'https://github.com/dart-lang/web_components',
    };

    // find all the implied packages
    List<PackageRepoDep> deps = [];

    for (var sdkDep in sdkDeps) {
      final repository = sdkDep.repository;
      final packages = _filterPackages(allPackages, repository);

      if (packages.isEmpty) {
        if (!gitDeps.contains(repository)) {
          // Assume the package name is the last part of the repo url.
          deps.add(PackageRepoDep(
            packageName: repository.substring(repository.lastIndexOf('/') + 1),
            commit: sdkDep.commit,
            repoUrl: repository,
          ));
        }
      } else {
        for (var package in packages) {
          deps.add(PackageRepoDep(
            packageName: package.name,
            packagePublisher: package.publisher,
            commit: sdkDep.commit,
            repoUrl: repository,
          ));
        }
      }
    }

    return deps;
  }
}

// class SDKPackagesWidget extends StatelessWidget {
//   final DataModel dataModel;

//   const SDKPackagesWidget({
//     required this.dataModel,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<List<PackageInfo>>(
//       valueListenable: dataModel.packages,
//       builder: (context, packages, _) {
//         return VTable<PackageInfo>(
//           items: _filterPackages(packages),
//           columns: [
//             VTableColumn(
//               label: 'Package',
//               width: 125,
//               grow: 0.2,
//               transformFunction: (p) => p.name,
//               styleFunction: PackageInfo.getDisplayStyle,
//             ),
//             VTableColumn(
//               label: 'Publisher',
//               width: 125,
//               grow: 0.2,
//               transformFunction: PackageInfo.getPublisherDisplayName,
//               styleFunction: PackageInfo.getDisplayStyle,
//             ),
//             VTableColumn(
//               label: 'Maintainer',
//               width: 125,
//               grow: 0.2,
//               transformFunction: (p) => p.maintainer,
//               styleFunction: PackageInfo.getDisplayStyle,
//             ),
//             VTableColumn(
//               label: 'Version',
//               alignment: Alignment.centerRight,
//               width: 100,
//               transformFunction: (p) => p.version.toString(),
//               compareFunction: (a, b) {
//                 return a.version.compareTo(b.version);
//               },
//               styleFunction: PackageInfo.getDisplayStyle,
//             ),
//           ],
//         );
//       },
//     );
//   }

//   List<PackageInfo> _filterPackages(List<PackageInfo> packages) {
//     // Just SDK packages.
//     packages = packages
//         .where((p) => p.repoUrl == 'https://github.com/dart-lang/sdk')
//         .toList();

//     // Remove the discontinued packages.
//     packages = packages.where((p) => !p.discontinued).toList();

//     packages.sort((a, b) => a.name.compareTo(b.name));

//     return packages;
//   }
// }
