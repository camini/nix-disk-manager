import 'package:flutter/material.dart';
import 'package:nix_disk_manager/Commands/systemCommands.dart';
import 'package:nix_disk_manager/Entity/disk_entity.dart';

class DiskView extends StatefulWidget {
  Function handleGoToHome;

  String diskSelected;

  DiskView(
      {super.key, required this.handleGoToHome, required this.diskSelected});

  @override
  State<DiskView> createState() => _DiskViewState();
}

class _DiskViewState extends State<DiskView> {
  List<DiskEntity> stateDiskList = [];

  @override
  void initState() {
    super.initState();

    SystemCommands diskCommand = SystemCommands();

    diskCommand.listDisk().then((diskList) {
      setState(() {
        stateDiskList = diskList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.home),
                        onPressed: () {
                          widget.handleGoToHome();
                        }),
                    Text('Disque sélectionné : ${widget.diskSelected}')
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Expanded(child: SizedBox())
              ],
            )));
  }
}
