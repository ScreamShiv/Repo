import 'package:flutter/material.dart';
import 'package:repo/models/repo.dart';
import 'package:repo/utils/database_helper.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class RepoDetails extends StatefulWidget {
  final String appBarTitle;
  final Repo repo;

  const RepoDetails(this.repo, this.appBarTitle, {super.key});

  @override
  State<StatefulWidget> createState() {
    return RepoDetailsState();
  }
}

class RepoDetailsState extends State<RepoDetails> {
  final _formKey = GlobalKey<FormState>();

  DatabaseHelper databaseHelper = DatabaseHelper();

  late String appBarTitle = widget.appBarTitle;                     // accessing property from parent widget(RepoDetails)
  late Repo repo = widget.repo;

  bool isUpdated = false;                                           // check if user edited any field

  final _priorities = ['High', 'Low'];

  TextEditingController titleController = TextEditingController();              // observer for text field
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = Theme.of(context).textTheme.titleMedium;

    titleController.text = repo.title;
    descriptionController.text =
        repo.description != null ? repo.description! : '';

    return WillPopScope(
        onWillPop: moveToLastScreen,
        child: Scaffold(
            appBar: AppBar(
              title: Text(appBarTitle,
                style: const TextStyle(
                  color: Colors.black87,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                },
              ),
            ),
            body: Form(
              key: _formKey,
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0),
                child: ListView(
                  children: <Widget>[
                    ListTile(
                      title: DropdownButton(
                          items: _priorities.map((String dropDownItem) {
                            return DropdownMenuItem<String>(
                              value: dropDownItem,
                              child: Text(dropDownItem),
                            );
                          }).toList(),
                          style: textStyle,
                          value: getPriorityAsString(repo.priority),
                          onChanged: (String? selectedValue) {
                            // dropdown item selected
                            setState(() {
                              updatePriorityAsInt(selectedValue!);
                            });
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                      child: TextFormField(
                        controller: titleController,
                        style: textStyle,
                        validator: (String? value){
                          if(value!=null && value.isEmpty){
                            return 'Title must not be empty!';
                          }
                        },
                        onChanged: (String value) {
                          // user entered some value
                          updateTitle();
                        },
                        decoration: InputDecoration(
                            label: const Text('Title'),
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        minLines: 5,
                        maxLines: 7,
                        controller: descriptionController,
                        style: textStyle,
                        onChanged: (String value) {
                          // user entered some value
                          updateDescription();
                        },
                        decoration: InputDecoration(
                            label: const Text('Description'),
                            labelStyle: textStyle,
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white),
                            onPressed: () {
                              // save button clicked
                              setState(() {
                                if(_formKey.currentState != null &&
                                    _formKey.currentState!.validate()){          // checking form validation
                                  _save();
                                }
                              });
                            },
                            child: const Text(
                              'Save',
                              textScaleFactor: 1.3,
                            ),
                          )),
                          Container(
                            width: 16.0,
                          ),
                          Expanded(
                              child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white),
                            onPressed: () {
                              // delete button clicked
                              setState(() {
                                _delete();
                              });
                            },
                            child: const Text(
                              'Delete',
                              textScaleFactor: 1.3,
                            ),
                          ))
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )));
  }

  // set priority int value from selected string
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        repo.priority = 1;
        break;
      case 'Low':
        repo.priority = 2;
        break;
    }
  }

  // priority string from int value
  String getPriorityAsString(int value) {
    String priority = _priorities[1];
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  // update title property using text field value
  void updateTitle() {
    repo.title = titleController.text;
  }

  // update description property using text field value
  void updateDescription() {
    repo.description = descriptionController.text;
  }

  // delete the message
  void _delete() async {
    if (repo.id == null) {
      _showAlertDialog('Warning', 'Unsaved message can not be deleted!');
      return;
    }
    isUpdated = true;
    moveToLastScreen();

    int result = await databaseHelper.deleteRepo(repo.id!);
    if (result != 0) {
      _showAlertDialog('Success', 'Message was deleted successfully');
    } else {
      _showAlertDialog('Failed', 'A problem occurred while deleting message!');
    }
  }

  // save the message
  void _save() async {
    isUpdated = true;
    moveToLastScreen();

    repo.date = DateFormat.yMMMd().format(DateTime.now());       // get current date
    int result;
    if (repo.id != null) {
      result = await databaseHelper.updateRepo(repo);
    } else {
      result = await databaseHelper.insertRepo(repo);
    }

    if (result != 0) {
      _showAlertDialog('Status', 'Message saved successfully');
    } else {
      _showAlertDialog('Status', 'Some problem occurred while saving!');
    }
  }

  void _showAlertDialog(String title, String message) {   // show an alert dialog
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  Future<bool> moveToLastScreen() async {     // return to previous screen
    Navigator.pop(context, isUpdated);        // return a boolean value for the previous screen to update list
    return Future.value(true);
  }
}
