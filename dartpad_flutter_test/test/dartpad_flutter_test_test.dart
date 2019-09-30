// Copyright (c) 2019, the Flutter authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dartpad_test/dartpad_test.dart' as dpt;
import 'package:dartpad_flutter_test/dartpad_flutter_test.dart' as dft;

Widget _buildWidget() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: MyWidget(),
      ),
    ),
  );
}

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('$count'),
        RaisedButton(
          onPressed: () => setState(() => count++),
          child: Text('Clicky!'),
        ),
      ],
    );
  }
}

void main() {
  dft.testWidgets(
    'asdf',
    _buildWidget(),
    (controller) async {
      await controller.tap(find.byType(RaisedButton));
      await controller.pump(Duration(seconds: 10));
      await dpt.expect(find.text('0'), findsOneWidget);
    },
    logFn: (s) {
      print('LOGGED: $s');
    },
  )().then((result) {
    print(result.success);
    print(result.messages);
  });
}
