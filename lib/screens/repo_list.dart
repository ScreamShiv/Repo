import 'package:flutter/material.dart';
import 'package:repo/screens/repo_details.dart';
import 'package:repo/models/repo.dart';
import 'package:repo/utils/database_helper.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:sqflite/sqflite.dart';


class RepoList extends StatefulWidget{

  const RepoList({super.key});

  @override
  State<StatefulWidget> createState() {
   return RepoListState();
  }
}

class RepoListState extends State<RepoList>{

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Repo>? repoList;                                   // list of messages
  int count = 0;                                          // list count

  @override
  Widget build(BuildContext context) {

    if(repoList == null){
      repoList = <Repo>[];
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Repo',
            style: TextStyle(
              color: Colors.black87,
            )),
      ),
      body: getRepoListView(),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          // floating action button clicked
          navigateToDetail(Repo('','',2),'Add Message'); // initialize a empty repo
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.add_comment_rounded,color: Colors.blueGrey,),
      ),
    );
  }

  ListView getRepoListView(){

    return ListView.builder(
      itemCount: count,
        itemBuilder: (BuildContext context,int position) {
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(

              leading: CircleAvatar(
                backgroundColor: getPriorityColor(repoList![position].priority),
                child: getPriorityIcon(repoList![position].priority),
              ),

              title: Text(repoList![position].title, style: const TextStyle(
                color: Colors.black,
                fontSize: 14.0,
              ),),

              subtitle: Text(repoList![position].date, style: const TextStyle(
                color: Colors.grey,
                fontSize: 12.0,
              ),),

              trailing: GestureDetector(
                child: const Icon(Icons.delete,color: Colors.blueGrey,),
                onTap: (){
                  // delete icon clicked
                  _deleteRepo(context, repoList![position]);
                },
              ),


              onTap: (){
                  navigateToDetail(repoList![position],'Edit Message');
              },

            ),
          );
        },
    );

  }

  // get icon color based on priority
  Color getPriorityColor(int priority){
    switch(priority){
      case 1:
        return Colors.redAccent;
      case 2:
        return Colors.yellow;
      default:
        return Colors.yellow;
    }
  }

  // get icon based on repo priority
  Icon getPriorityIcon(int priority){
    switch(priority){
      case 1:
        return const Icon(Icons.note_rounded,color: Colors.white,);
      case 2:
        return const Icon(Icons.note_outlined,color: Colors.white,);
      default:
        return const Icon(Icons.note_outlined,color: Colors.white,);
    }
  }

  // delete a repo
  void _deleteRepo(BuildContext context, Repo repo) async{
    int result = await databaseHelper.deleteRepo(repo.id!);
    if(!mounted){
      return;
    }
    if(result != 0 ){
      _showSnackBar(context,'Message deleted successfully');
      updateListView();
    }
  }

  // show a Snack bar at the bottom
  void _showSnackBar(BuildContext context, String msg){
    final snackBar = SnackBar(content: Text(msg));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // updating the listview whenever the data in database changes
  void updateListView(){
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database){

      Future<List<Repo>> repoListFuture = databaseHelper.getRepoList();
      repoListFuture.then((repoList){
        setState(() {
          this.repoList = repoList;
          count = repoList.length;
        });
      });
    });
  }

  // navigating to detail screen
  void navigateToDetail(Repo repo,String title) async{
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context){   // return value from detail screen while back navigation
      return RepoDetails(repo,title);
    }));

    if(result){
      updateListView();
    }
  }

}

