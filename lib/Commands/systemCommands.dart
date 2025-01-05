import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nix_disk_manager/Entity/disk_entity.dart';
import 'package:nix_disk_manager/Entity/partition_entity.dart';
import 'package:nix_disk_manager/Entity/partition_details_entity.dart';
import 'package:nix_disk_manager/Response/command_response.dart';

class SystemCommands {
  bool isDebug = true;

  static const String successPattern = 'success';

  static const String flatpakSpawnBin = 'flatpak-spawn';

  late String documentsPath;
  String commandDiskList = 'disk_list.sh';
  String commandCheckRunAsRoot = 'check_run_as_root.sh';
  String commandCleanAndRegenerate = 'initial_clean_and_regenerate.sh';
  String commandShowPartitionForDisk = 'show_partition_of_disk_selected.sh';
  String commandGetPartionDetail = 'get_fs_and_uuid.sh';
  String commandCreateFile = 'create_nix_file.sh';

  static final SystemCommands _singleton = SystemCommands._internal();

  factory SystemCommands([String? newDocumentsPath]) {
    if (newDocumentsPath != null) {
      _singleton.documentsPath = newDocumentsPath;

      if (kReleaseMode) {
        _singleton.isDebug = false;
      }
    }
    return _singleton;
  }

  String getPath(String binaryPath) {
    return documentsPath + '/' + binaryPath;
  }

  SystemCommands._internal();

  ProcessResult runSync(String command, List<String> argumentList) {
    List<String> newArgumentList = [command];
    for (String argumentLoop in argumentList) {
      newArgumentList.add(argumentLoop);
    }

    String executeBin = '';

    String bashBin = 'bash';

    return Process.runSync(bashBin, newArgumentList);
  }

  Future<List<DiskEntity>> listDisk() async {
    ProcessResult result = runSync(getPath(commandDiskList), []);

    List<String> rawLineList = result.stdout.toString().split('\n');

    List<DiskEntity> diskList = [];
    for (String lineLoop in rawLineList) {
      if (lineLoop.trim().length > 3) {
        lineLoop = lineLoop.trim().replaceAll(RegExp(r'\s+'), ' ');

        List<String> lineDetailList = lineLoop.trim().split(' ');

        diskList
            .add(DiskEntity(path: lineDetailList[0], size: lineDetailList[1]));
      }
    }

    return diskList;
  }

  Future<bool> doesProgramRunAsRoot() async {
    ProcessResult result = runSync(getPath(commandCheckRunAsRoot), []);

    String rawLine = result.stdout.toString();

    print(rawLine);

    if (rawLine.contains('success')) {
      return true;
    }
    return false;
  }

  Future<CommandResponse> initialCleanAndRegenerate() async {
    ProcessResult result = runSync(getPath(commandCleanAndRegenerate), []);

    String rawLine = result.stdout.toString();

    print(rawLine);

    if (rawLine.contains('success')) {
      return CommandResponse(status: true, message: '');
    }
    return CommandResponse(status: false, message: rawLine);
  }

  Future<List<PartitionEntity>> listPartitionByDisk(String diskPath) async {
    ProcessResult result =
        runSync(getPath(commandShowPartitionForDisk), [diskPath]);

    List<String> rawLineList = result.stdout.toString().split('\n');

    List<PartitionEntity> partitionList = [];
    for (String lineLoop in rawLineList) {
      if (lineLoop.trim().length > 3) {
        lineLoop = lineLoop.trim().replaceAll(RegExp(r'\s+'), ' ');

        List<String> lineDetailList = lineLoop.trim().split(' ');

        String formatFound = 'n/c';
        if (lineDetailList.length > 2) {
          formatFound = lineDetailList[2];
        }

        partitionList.add(PartitionEntity(
            name: lineDetailList[0],
            size: lineDetailList[1],
            format: formatFound));
      }
    }

    return partitionList;
  }

  Future<PartitionDetailsEntity> getDetailPartitionFor(
      String partitionName) async {
    ProcessResult result =
        runSync(getPath(commandGetPartionDetail), ["/dev/$partitionName"]);

    List<String> rawLineList = result.stdout.toString().split('\n');

    for (String lineLoop in rawLineList) {
      if (lineLoop.trim().length > 3) {
        List<String> lineDetailList = lineLoop.trim().split('|');

        if (lineDetailList[0] == successPattern) {
          return PartitionDetailsEntity(
              fileSystem: lineDetailList[1], uuid: lineDetailList[2]);
        }
      }
    }
    return PartitionDetailsEntity(fileSystem: 'n/c', uuid: 'n/c');
  }

  void debug(String text) {
    print(text);
  }

  Future<CommandResponse> createMountPoint(String mountPoint) async {
    Directory newMountPoint = Directory('/mnt/$mountPoint');

    debug('Essai de créer répertoire ${newMountPoint.path}');

    if (newMountPoint.existsSync()) {
      String errorMessage = "le répertoire ${newMountPoint.path} existe déjà";
      debug('Error:$errorMessage');
      return CommandResponse(status: false, message: errorMessage);
    }

    try {
      newMountPoint.createSync();
      String successMessage =
          "le répertoire ${newMountPoint.path} créé avec succès";
      debug(successMessage);
      return CommandResponse(status: true, message: successMessage);
    } catch (e) {
      debug('Exception:$e');
      return CommandResponse(status: false, message: e.toString());
    }
  }

  Future<CommandResponse> createNixFile(
      String fsType, String mountPoint, String uuid) async {
    ProcessResult result =
        runSync(getPath(commandCreateFile), [fsType, mountPoint, uuid]);
    debug(
        'call: /bin/bash ${getPath(commandCreateFile)} $fsType $mountPoint $uuid');

    String rawLine = result.stdout.toString();

    String errorResult = result.stderr.toString();
    if (errorResult.isNotEmpty) {
      return CommandResponse(status: false, message: errorResult);
    }
    debug(rawLine);

    if (rawLine.contains('success')) {
      return CommandResponse(
          status: true,
          message:
              'Fichier /etc/nixos/hardware-configuration.nix mis à jour avec succès');
    }
    return CommandResponse(status: false, message: rawLine);
  }
}
