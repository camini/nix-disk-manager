import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nix_disk_manager/Commands/systemCommands.dart';
import 'package:nix_disk_manager/nix_disk_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
  String appDocumentsDirPath = appDocumentsDir.path;

  Directory documentsTargetDirectory =
      Directory(p.join(appDocumentsDirPath, "NixDiskManager"));

  if (!documentsTargetDirectory.existsSync()) {
    await documentsTargetDirectory.create();
  }

  print('contenu de /etc/nixos:');
  print('');
  ProcessResult processResult = Process.runSync('ls', ['/etc/nixos']);
  print(processResult.stdout.toString());
  print('');
  print('fin du contenu de /etc/nixos');

  List<String> binaryList = [
    'disk_list.sh',
    'check_run_as_root.sh',
    'initial_clean_and_regenerate.sh',
    'show_partition_of_disk_selected.sh',
    'get_fs_and_uuid.sh',
    'create_nix_file.sh'
  ];

  bool debug = true;

  if (kReleaseMode) {
    debug = false;
  }

  for (String binaryLoop in binaryList) {
    File binaryFile = File('${documentsTargetDirectory.path}/$binaryLoop');
    if (!binaryFile.existsSync() || debug) {
      print('Start copy $binaryLoop');
      final bytes = await rootBundle.load('assets/bin/$binaryLoop');
      final targetFile = File('${documentsTargetDirectory.path}/$binaryLoop');
      await targetFile.writeAsBytes(bytes.buffer.asUint8List());

      print('End copy $binaryLoop');
    }
  }

  SystemCommands(documentsTargetDirectory.path);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nix Disk Manager',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NixDiskManager(),
    );
  }
}
