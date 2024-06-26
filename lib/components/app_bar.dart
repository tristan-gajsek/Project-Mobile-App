import 'package:flutter/material.dart';
import 'package:project_mobile_app/screens/app/map.dart';
import 'package:project_mobile_app/screens/app/profile.dart';
import 'package:project_mobile_app/state.dart';
import 'package:provider/provider.dart';

class MainAppBar extends StatefulWidget {
  final String title;

  const MainAppBar({super.key, required this.title});

  @override
  State<MainAppBar> createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Center(
        child: Text(widget.title),
      ),
      leading: IconButton(
        onPressed: () {
            // var sharedState = Provider.of<SharedState>(context, listen: false);
            // sharedState.endSession();
            Navigator.pop(context);
        },
        icon: const Icon(Icons.logout),
      ),
      actions: [
        PopupMenuButton(
          onSelected: (String result) {
            switch (result) {
              case 'Profile':
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
                break;
              case 'Map':
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapScreen(),
                  ),
                );
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem(
              value: 'Profile',
              child: Text('Profile'),
            ),
            const PopupMenuItem(
              value: 'Map',
              child: Text('Map'),
            ),
          ],
        ),
      ],
    );
  }
}
