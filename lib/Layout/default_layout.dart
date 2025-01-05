import 'package:flutter/material.dart';

class DefaultLayout extends StatefulWidget {
  Widget content;

  DefaultLayout({
    super.key,
    required this.content,
  });

  @override
  _DefaultLayoutState createState() => _DefaultLayoutState();
}

class _DefaultLayoutState extends State<DefaultLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(5),
        child: Card(
            elevation: 4,
            child: Scrollbar(
                child: Padding(
                    padding: EdgeInsets.all(20), child: widget.content))),
      ),
    );
  }
}
