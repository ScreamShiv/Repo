import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:repo/models/repo.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;                // Singleton DatabaseHelper
  static Database? _database;                            // Singleton Database

  String repoTable = 'repo_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colDate = 'date';
  String colPriority = 'priority';

  DatabaseHelper._getInstance();      // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._getInstance();      // executed only once, singleton object
    return _databaseHelper!;
  }

  Future<Database> get database async{             // getter for database instance

    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async{
    // Get the directory path for both Android and iOS to store database
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}repo.db';

    // Open/create database at given path
    var repoDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return repoDatabase;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $repoTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
            '$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  // Fetch operation: Get all repo objects from database
  Future<List<Map<String,dynamic>>> getRepoMapList() async{
    Database db = await database;

    var result = await db.query(repoTable, orderBy: '$colPriority ASC');
    return result;
  }

  // Insert operation: Insert repo object to database
  Future<int> insertRepo(Repo repo) async{
    var db = await database;
    var result = await db.insert(repoTable, repo.toMap());
    return result;
  }

  // Update operation: Update an existing repo object
  Future<int> updateRepo(Repo repo) async{
    var db = await database;
    var result = await db.update(repoTable, repo.toMap(), where: '$colId = ?', whereArgs: [repo.id]);
    return result;
  }

  // Delete operation: delete a repo object using its id
  Future<int> deleteRepo(int id) async{
    var db = await database;
    var result = await db.rawDelete('DELETE FROM $repoTable WHERE $colId = $id');
    return result;
  }

  // get number of repo objects saved in database
  Future<int?> getCount() async{
    var db = await database;
    List<Map<String,dynamic>> x = await db.rawQuery('SELECT COUNT (*) FROM $repoTable');
    int? result = Sqflite.firstIntValue(x);
    return result;
  }

  // return a List of repo objects after converting it from list of map objects
  Future<List<Repo>> getRepoList() async{
    var repoMapList = await getRepoMapList();
    int count = repoMapList.length;

    List<Repo> repoList = <Repo>[];

    for(int i =0; i < count; i++){
      repoList.add(Repo.fromMap(repoMapList[i]));
    }

    return repoList;
  }

}
