
class Repo {

  int? _id;
  late String _title;
  late String? _description ;
  late String _date;
  late int _priority;

  Repo(this._title, this._date, this._priority, [this._description]); // making description optional

  Repo.withId(this._id, this._title, this._date, this._priority, [this._description]); // named constructor

  int? get id => _id;

  String get title => _title;

  String? get description => _description;

  String get date => _date;

  int get priority => _priority;

  set title(String newTitle){
    if(newTitle.length <= 255){
      _title = newTitle;
    }
  }

  set description(String? newDescription){
    newDescription ??= '';
    _description = newDescription;
  }

  set date(String newDate){
    _date = newDate;
  }

  set priority(int newPriority){
    if(newPriority>=1 && newPriority<=2){
      _priority = newPriority;
    }
  }


  Map<String, dynamic> toMap(){  // convert model object to map object
    var map =  <String,dynamic>{} ;

    if(_id != null){
      map['id'] = _id;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['date'] = _date;
    map['priority'] = _priority;

    return map;
  }

  Repo.fromMap(Map<String, dynamic> map){  // model object from map object
    _id = map['id'];
    _title = map['title'];
    _description = map['description'];
    _date = map['date'];
    _priority = map['priority'];
  }

}