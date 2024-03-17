import 'dart:ui';

import 'package:dino_run_game/game/dino_run.dart';
import 'package:dino_run_game/models/modus_settings.dart';
import 'package:dino_run_game/widgets/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModusMenu extends StatelessWidget {
  static const id = 'ModusMenu';

  final DinoRun game;

  const ModusMenu(this.game, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.black.withAlpha(100),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 100),
              child: Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  const Text(
                    'Modus',
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<ModusSettings>(context, listen: false).modus =
                          ModusType.easy;
                      game.changeBackground();
                      game.overlays.remove(ModusMenu.id);
                      game.overlays.add(MainMenu.id);
                    },
                    child: const Text(
                      'Easy',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<ModusSettings>(context, listen: false).modus =
                          ModusType.middle;
                      game.changeBackground();
                      game.overlays.remove(ModusMenu.id);
                      game.overlays.add(MainMenu.id);
                    },
                    child: const Text(
                      'Middle',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<ModusSettings>(context, listen: false).modus =
                          ModusType.hard;
                      game.changeBackground();
                      game.overlays.remove(ModusMenu.id);
                      game.overlays.add(MainMenu.id);
                    },
                    child: const Text(
                      'Hard',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<ModusSettings>(context, listen: false).modus =
                          ModusType.nightmare;
                      game.changeBackground();
                      game.overlays.remove(ModusMenu.id);
                      game.overlays.add(MainMenu.id);
                    },
                    child: const Text(
                      'Nightmare',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
