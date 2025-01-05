import 'package:flutter/material.dart';
import 'package:nix_disk_manager/Commands/systemCommands.dart';
import 'package:nix_disk_manager/Response/command_response.dart';

class InitialProposalView extends StatefulWidget {
  bool isDebug;
  Function handleGoToNextPage;
  InitialProposalView(
      {super.key, required this.isDebug, required this.handleGoToNextPage});

  @override
  State<InitialProposalView> createState() => _InitialProposalViewState();
}

class _InitialProposalViewState extends State<InitialProposalView> {
  bool stateDisplayButtons = true;
  bool stateDisplayLoadingButtons = false;
  String stateDisplayCommandMessage = '';

  bool stateDisplayNextButton = false;

  Future<void> cleanAndGenerate() async {
    SystemCommands systemCommands = SystemCommands();

    setState(() {
      stateDisplayButtons = false;
      stateDisplayLoadingButtons = true;
    });
    CommandResponse systemResponse =
        await systemCommands.initialCleanAndRegenerate();

    String commandMessage;
    if (systemResponse.status) {
      commandMessage =
          'Toutes les partitions secondaires (hors / et /boot) sont (en principe) démontées.';
    } else {}

    setState(() {
      stateDisplayLoadingButtons = false;
      stateDisplayCommandMessage = systemResponse.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            const Text(
                'Souhaitez-vous tout nettoyer (le script va démonter les partitions secondaires'),
            const Text(
                ' (puis regénérer la configuration avec nixos-generate-config) '),
            const SizedBox(
              height: 10,
            ),
            if (stateDisplayLoadingButtons) CircularProgressIndicator(),
            if (stateDisplayButtons)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        cleanAndGenerate();
                      },
                      child: const Text('Oui')),
                  ElevatedButton(
                      onPressed: () {
                        widget.handleGoToNextPage();
                      },
                      child: const Text('Non')),
                ],
              ),
            const SizedBox(
              height: 10,
            ),
            Text(stateDisplayCommandMessage),
            const SizedBox(
              height: 10,
            ),
            if (stateDisplayNextButton)
              ElevatedButton(
                  onPressed: () {
                    widget.handleGoToNextPage();
                  },
                  child: const Text('Aller à la page de list des disques'))
          ],
        ),
      ),
    );
  }
}
