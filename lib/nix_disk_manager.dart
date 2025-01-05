import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nix_disk_manager/Layout/default_layout.dart';
import 'package:nix_disk_manager/Views/check_run_as_root_view.dart';
import 'package:nix_disk_manager/Views/disk_list_view.dart';
import 'package:nix_disk_manager/Views/disk_selected_view.dart';
import 'package:nix_disk_manager/Views/initial_proposal_view.dart';

class NixDiskManager extends StatefulWidget {
  const NixDiskManager({super.key});

  @override
  _NixDiskManagerState createState() => _NixDiskManagerState();
}

class _NixDiskManagerState extends State<NixDiskManager> {
  String statePageSelected = constPageCheckRunRoot;

  static const String constPageCheckRunRoot = 'checkRunAsRoot';
  static const String constPageInitialProposal = 'initialProposal';
  static const String constPageDiskList = 'diskList';
  static const String constPageDiskSelected = 'diskSelected';

  String stateDiskSelected = '';

  bool stateIsDebug = true;

  @override
  void initState() {
    super.initState();

    if (kReleaseMode) {
      setState(() => stateIsDebug = false);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Navigator(onDidRemovePage: (page) => false, pages: [
      if (statePageSelected == constPageCheckRunRoot)
        MaterialPage(
            key: const ValueKey(constPageCheckRunRoot),
            child: DefaultLayout(
                content: CheckRunAsRootView(
              isDebug: stateIsDebug,
              handleGoToNextPage: goToInitialProposal,
            )))
      else if (statePageSelected == constPageInitialProposal)
        MaterialPage(
            key: const ValueKey(constPageInitialProposal),
            child: DefaultLayout(
                content: InitialProposalView(
              isDebug: stateIsDebug,
              handleGoToNextPage: goToDiskList,
            )))
      else if (statePageSelected == constPageDiskList)
        MaterialPage(
            key: const ValueKey(constPageDiskList),
            child: DefaultLayout(
                content: DiskListView(
              isDebug: stateIsDebug,
              handleGoToDisk: goToDiskSelected,
            )))
      else if (statePageSelected == constPageDiskSelected)
        MaterialPage(
            key: const ValueKey(constPageDiskList),
            child: DefaultLayout(
                content: DiskSelectedView(
              isDebug: stateIsDebug,
              handleGoToDiskList: goToDiskList,
              handleGoToNextPage: goToDiskList,
              diskSelected: stateDiskSelected,
            )))
    ]));
  }

  void goToInitialProposal() {
    setState(() {
      statePageSelected = constPageInitialProposal;
    });
  }

  void goToDiskList() {
    setState(() {
      statePageSelected = constPageDiskList;
    });
  }

  void goToDiskSelected(String diskSelected) {
    setState(() {
      stateDiskSelected = diskSelected;
      statePageSelected = constPageDiskSelected;
    });
  }
}
