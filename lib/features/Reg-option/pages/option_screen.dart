// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:godropme/features/Reg-option/widgets/option_content.dart';

class OptionScreen extends StatelessWidget {
  const OptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.vertical,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [OptionContent()],
            ),
          ),
        ),
      ),
    );
  }
}
