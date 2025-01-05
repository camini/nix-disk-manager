import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nix_disk_manager/Commands/systemCommands.dart';
import 'package:nix_disk_manager/Entity/disk_entity.dart';
import 'package:nix_disk_manager/Entity/partition_details_entity.dart';
import 'package:nix_disk_manager/Entity/partition_entity.dart';
import 'package:nix_disk_manager/Response/command_response.dart';
import 'package:nix_disk_manager/Views/Shared/width_space_component.dart';

class DiskSelectedView extends StatefulWidget {
  bool isDebug;
  Function handleGoToDiskList;

  Function handleGoToNextPage;
  String diskSelected;
  DiskSelectedView(
      {super.key,
      required this.isDebug,
      required this.handleGoToDiskList,
      required this.handleGoToNextPage,
      required this.diskSelected});

  @override
  State<DiskSelectedView> createState() => _DiskSelectedViewState();
}

class _DiskSelectedViewState extends State<DiskSelectedView> {
  List<DiskEntity> stateDiskList = [];
  List<PartitionEntity> statePartitionList = [];
  PartitionEntity? statePartitionSelected;
  PartitionDetailsEntity? statePartitionDetailsSelected;

  DiskEntity? stateDiskSelected;

  ScrollController scrollController = ScrollController();

  final TextEditingController mountPointController = TextEditingController();

  bool stateDisplayMountPointButton = true;
  bool stateDisplayCircularMountPointButton = false;

  String stateMountPointMessage = '';

  @override
  void initState() {
    load();
    super.initState();
  }

  void load() async {
    SystemCommands systemCommands = SystemCommands();

    systemCommands.listDisk().then((diskList) {
      for (DiskEntity diskLoop in diskList) {
        if (diskLoop.path == widget.diskSelected) {
          setState(() {
            stateDiskSelected = diskLoop;
          });

          loadPartition(diskLoop);
        }
      }
    });
  }

  void loadPartition(DiskEntity diskSelected) async {
    SystemCommands systemCommands = SystemCommands();

    systemCommands
        .listPartitionByDisk(diskSelected.path)
        .then((List<PartitionEntity> partitionList) {
      setState(() => statePartitionList = partitionList);
    });
  }

  void loadPartitionDetail(PartitionEntity partitionSelected) async {
    SystemCommands systemCommands = SystemCommands();
    systemCommands
        .getDetailPartitionFor(partitionSelected.name)
        .then((PartitionDetailsEntity partitionDetailEntity) {
      setState(() {
        statePartitionSelected = partitionSelected;
        statePartitionDetailsSelected = partitionDetailEntity;
      });
    });
  }

  void createMountPoint(String mountPath) async {
    SystemCommands systemCommands = SystemCommands();

    CommandResponse creationMountPointResponse =
        await systemCommands.createMountPoint(mountPath);
    if (creationMountPointResponse.status) {
      setState(() {
        stateDisplayCircularMountPointButton = true;
        stateDisplayMountPointButton = false;
      });

      String absoluteMountPoint = '/mnt/$mountPath';
      CommandResponse commandResponse = await systemCommands.createNixFile(
          statePartitionDetailsSelected!.fileSystem,
          absoluteMountPoint,
          statePartitionDetailsSelected!.uuid);

      if (commandResponse.status) {
        setState(() {
          stateDisplayCircularMountPointButton = false;
          stateMountPointMessage = commandResponse.message;
        });
      } else {
        setState(() {
          stateDisplayCircularMountPointButton = false;
          stateMountPointMessage = commandResponse.message;
        });
      }
    } else {
      setState(() {
        stateDisplayMountPointButton = false;

        stateDisplayCircularMountPointButton = false;
        stateMountPointMessage = creationMountPointResponse.message;
      });
    }
  }

  void cancelCreateMountMoint() {
    setState(() {
      mountPointController.clear();
      stateDisplayCircularMountPointButton = false;
      stateDisplayMountPointButton = true;
      stateMountPointMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      Row(
        children: [
          IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                widget.handleGoToDiskList();
              }),
          stateDiskSelected == null
              ? CircularProgressIndicator()
              : Text(
                  'Disque sélectionné : ${stateDiskSelected!.path} ${stateDiskSelected!.size}')
        ],
      ),
      const SizedBox(
        height: 15,
      ),
      if (statePartitionList.isNotEmpty)
        statePartitionSelected == null
            ? const Row(
                children: [
                  Text('Selecionnez votre partition'),
                ],
              )
            : Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        setState(() {
                          statePartitionSelected = null;
                        });
                      }),
                  const Text('Partition sélectionnée'),
                ],
              ),
      statePartitionSelected == null
          ? Expanded(
              child: ListView(
                  children:
                      statePartitionList.map((PartitionEntity partitionLoop) {
              return Card(
                  child: ListTile(
                      onTap: () {
                        loadPartitionDetail(partitionLoop);
                        // widget.handleGoToDisk(stateDiskLoop.path);
                      },
                      title: Row(
                        children: [
                          Text(partitionLoop.name),
                          WidthSpaceComponent(),
                          Text(partitionLoop.size),
                          WidthSpaceComponent(),
                          Text(partitionLoop.format)
                        ],
                      )));
            }).toList()))
          : Expanded(
              child: Column(
              children: [
                ListTile(
                    onTap: () {
                      // widget.handleGoToDisk(stateDiskLoop.path);
                    },
                    title: Row(
                      children: [
                        Text(statePartitionSelected!.name),
                        WidthSpaceComponent(),
                        Text(statePartitionSelected!.size),
                        WidthSpaceComponent(),
                        Text(statePartitionSelected!.format)
                      ],
                    )),
                if (statePartitionDetailsSelected != null)
                  const ListTile(
                    title: Text('Détails'),
                  ),
                if (statePartitionDetailsSelected != null)
                  Padding(
                      padding: const EdgeInsets.fromLTRB(30, 5, 4, 5),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('File system:'),
                              Text(statePartitionDetailsSelected!.fileSystem),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('UIID:'),
                              Text(statePartitionDetailsSelected!.uuid),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                  'Entrez le nom du dossier (ex: data, jeux) :'),
                              SizedBox(
                                  width: 200,
                                  child: TextField(
                                    controller: mountPointController,
                                    decoration: const InputDecoration(
                                        hintText: 'data,jeux..'),
                                  )),
                              if (stateDisplayMountPointButton)
                                ElevatedButton(
                                    onPressed: () {
                                      createMountPoint(
                                          mountPointController.text);
                                    },
                                    child: const Text('Valider')),
                              if (stateDisplayCircularMountPointButton)
                                CircularProgressIndicator(),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                stateMountPointMessage,
                                style: TextStyle(color: Colors.redAccent),
                              )
                            ],
                          ),
                          if (stateMountPointMessage.isNotEmpty)
                            Row(
                              children: [
                                ElevatedButton.icon(
                                    icon: const Icon(Icons.cancel),
                                    onPressed: () {
                                      cancelCreateMountMoint();
                                    },
                                    label: const Text('Annuler/Recommencer'))
                              ],
                            )
                        ],
                      ))
              ],
            ))
    ]));
  }
}
