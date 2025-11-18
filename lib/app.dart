import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartsan_app/main.dart';

void main(){
  runApp(const DashBoard());
}

class DashBoard extends StatelessWidget{
  const DashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Dashboard",
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});


  @override
  State<StatefulWidget> createState() => _DashBoardPage();

}

class _DashBoardPage extends State<DashboardPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       // title: Text("Dashboard"),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(trailing: Icon(Icons.home),
              title: Text("Home"),
              onTap: (){
              Navigator.pop(context);
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => HomePage())
              );
              },
            ),
            ListTile(trailing: Icon(Icons.dashboard),
              title: Text("Dashboard"),
              onTap: (){
                Navigator.pop(context);
                MaterialPageRoute(builder: (context) => DashBoard());
              },
            ),
            ListTile(trailing: Icon(Icons.location_city),
              title: Text("Report Issue"),
              onTap: (){
              Navigator.pop(context);
              },
            ),
            ListTile(trailing: Icon(Icons.work),
              title: Text("Workers"),
              onTap: (){
                Navigator.pop(context);
              },
            ),
            ListTile(trailing: Icon(Icons.analytics),
              title: Text("Analytics"),
            onTap: (){
              Navigator.pop(context);
            },)
          ],
        ),
      ),
      body: Column(

        children: [

          Container(
            padding: EdgeInsets.all(16.0),
              child: Column(

                children: [
                  Text("Dashboard",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 25
                    ),),
                  Text("Monitor sanitization operations in real time",
                      textAlign: TextAlign.center
                  )
                ],
              )
          )


        ],
      ),
    );
  }

}