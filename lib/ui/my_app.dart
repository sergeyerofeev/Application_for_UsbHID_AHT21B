import 'package:flutter/material.dart';

import '../widget/content_body.dart';
import '../widget/draggeble_app_bar.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFFEFEFE),
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: DraggebleAppBar(),
          body: SizedBox.expand(
            child: ContentBody(),
          ),
        ),
      ),
    );
  }
}
