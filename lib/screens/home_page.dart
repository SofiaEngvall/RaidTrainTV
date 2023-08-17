import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './favorites_page.dart';
import './raid_trains.dart';
import './organize_raid_train_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
   var selectedIndex = 0; 

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      // case 0:
      //   page = LoginPage();
      //   break;
      case 0:
        page = RaidTrains();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = OrganizeRaidTrainPage();
        break;
      case 4:
        // FirebaseAuth.instance.signOut();
        // page = LoginPage();
        // break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            title: Text("RaidTrainTV"),
            actions: [
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    // User is logged in
                    return Text('Logged in as ${snapshot.data!.displayName}');
                  } else {
                    // User is not logged in
                    return IconButton(
                      icon: Icon(Icons.login),
                      onPressed: () async {
                        try {
                          print("temp");
                        } catch (e) {
                          print(e);
                        }
                      },
                    );
                  }
                },
              )
            ],
          ),
          body: Row(
            children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: [
                      // NavigationRailDestination(
                      //   icon: Icon(Icons.login),
                      //   label: Text('Log In'),
                      // ),
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text('Favorites'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.train),
                        label: Text('Organize RaidTrain'),
                      ),
                      // NavigationRailDestination(
                      //   icon: Icon(Icons.logout),
                      //   label: Text('Log Out'),
                      // ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                      selectedIndex = value;
                    });
                    },
                  ),
                ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}