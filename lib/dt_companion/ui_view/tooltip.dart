import 'package:flutter/material.dart';
import 'package:overlay_tooltip/overlay_tooltip.dart';

import '../companion_app_theme.dart';

class MTooltip extends StatelessWidget {
  final TooltipController controller;
  final String title;

  const MTooltip({
    Key? key,
    required this.controller,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentDisplayIndex = controller.nextPlayIndex + 1;
    final totalLength = controller.playWidgetLength;
    final hasNextItem = currentDisplayIndex < totalLength;
    final hasPreviousItem = currentDisplayIndex != 1;
    final canPause = currentDisplayIndex < totalLength;

    return Container(
      width: size.width * .7,
      decoration: BoxDecoration(
        color: CompanionAppTheme.dark_grey,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size.width,
            child: Text(
              title,
              style: TextStyle(
                fontFamily: CompanionAppTheme.fontName,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.2,
                color: CompanionAppTheme.lightText,
              ),
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              if (hasPreviousItem)
                TextButton(
                  onPressed: () {
                    controller.previous();
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Prev',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (canPause)
                TextButton(
                  onPressed: () {
                    controller.pause();
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Pause',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              TextButton(
                onPressed: () {
                  controller.next();
                },
                style: TextButton.styleFrom(
                    backgroundColor: CompanionAppTheme.lightText,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    hasNextItem ? 'Next' : 'Got It',
                    style: const TextStyle(
                      color: CompanionAppTheme.darkerText,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
