import 'package:flutter/material.dart';
import 'package:nix_disk_manager/Commands/systemCommands.dart';

class CheckRunAsRootView extends StatefulWidget {
  bool isDebug;
  Function handleGoToNextPage;

  CheckRunAsRootView(
      {super.key, required this.isDebug, required this.handleGoToNextPage});

  @override
  State<CheckRunAsRootView> createState() => _CheckRunAsRootViewState();
}

class _CheckRunAsRootViewState extends State<CheckRunAsRootView> {
  bool stateRunAsRoot = false;

  bool isLoaded = false;

  @override
  void initState() {
    load();

    super.initState();
  }

  void load() async {
    SystemCommands diskCommand = SystemCommands();

    bool doesRunAsRoot = false;

    if (widget.isDebug) {
      doesRunAsRoot = true;
    } else {
      doesRunAsRoot = await diskCommand.doesProgramRunAsRoot();
    }

    if (doesRunAsRoot) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.handleGoToNextPage();
      });
    } else {
      setState(() {
        isLoaded = true;
        stateRunAsRoot = doesRunAsRoot;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return !isLoaded
        ? const CircularProgressIndicator()
        : Container(
            child: stateRunAsRoot
                ? Column(
                    children: [
                      Text('Vous êtes bien en Root'),
                      ElevatedButton(
                          onPressed: () {
                            widget.handleGoToNextPage();
                          },
                          child: Text('Suivant'))
                    ],
                  )
                : Text('Vous devez lancer ce programme en Root'));
  }
}
