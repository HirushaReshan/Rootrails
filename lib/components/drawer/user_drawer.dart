import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDrawer extends StatelessWidget {
  const UserDrawer({super.key});

  //sginout User
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey.shade300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //drawer Header
          Column(
            children: [
              DrawerHeader(
                child: Icon(
                  Icons.travel_explore,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),

              //Home tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(Icons.home, color: Colors.grey),
                  title: Text('H O M E'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              //Profile Tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(Icons.group, color: Colors.grey),
                  title: Text('P R O F I L E'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(Icons.animation, color: Colors.grey),
                  title: Text('A N O T H E R'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              //contact us
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(Icons.call, color: Colors.grey),
                  title: Text('C O N T A C T  U S'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/contact_us_page');
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(Icons.settings, color: Colors.grey),
                  title: Text('S E T T I N G S'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/user_settings_page');
                  },
                ),
              ),
            ],
          ),

          //Logout Button
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25.0),
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.grey),
              title: Text('LOG OUT'),
              onTap: () {
                //pop the darwer
                Navigator.pop(context);

                //signout the User
                signUserOut();
              },
            ),
          ),
        ],
      ),
    );
  }
}
