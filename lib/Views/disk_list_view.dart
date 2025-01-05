import 'package:flutter/material.dart';
import 'package:nix_disk_manager/Commands/systemCommands.dart';
import 'package:nix_disk_manager/Entity/disk_entity.dart';
import 'package:nix_disk_manager/Views/Shared/width_space_component.dart';

class DiskListView extends StatefulWidget {
  bool isDebug;
  Function handleGoToDisk;
  DiskListView(
      {super.key, required this.isDebug, required this.handleGoToDisk});

  @override
  State<DiskListView> createState() => _DiskListViewState();
}

class _DiskListViewState extends State<DiskListView> {
  List<DiskEntity> stateDiskList = [];

  @override
  void initState() {
    load();
    super.initState();
  }

  void load() async {
    SystemCommands diskCommand = SystemCommands();

    diskCommand.listDisk().then((diskList) {
      setState(() {
        stateDiskList = diskList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        const Row(
          children: [Text('Selectionnez un disque')],
        ),
        const SizedBox(
          height: 15,
        ),
        Expanded(
            child: ListView(
                children: stateDiskList.map((stateDiskLoop) {
          return Card(
              child: ListTile(
                  onTap: () {
                    widget.handleGoToDisk(stateDiskLoop.path);
                  },
                  title: Row(
                    children: [
                      Text(stateDiskLoop.path),
                      WidthSpaceComponent(),
                      Text(stateDiskLoop.size)
                    ],
                  )));
        }).toList()))
      ],
    ));
  }
}
