import 'package:cartoon/db/db_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cartoon/service.dart';
import 'package:path/path.dart';

///数据库配置
///数据库名称
final String DB_NAME = 'cartoon_db.db';

///数据库版本
final int DB_VERSION = 1;

///读取库方法
class DbManage {
  static final DbManage _instance = DbManage._();

  DbManage._();

  static DbManage get instance => _instance;

  Database? _database;

  Future<bool> init() async {
    try {
      _database = await _createDb();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<Database> get database async {
    if (null == _database) {
      throw Exception('error database is null');
    }
    if (!_database!.isOpen) {
      await init();
    }
    return _database!;
  }

  _createDb() async {
    String path = join(await getDatabasesPath(), DB_NAME);
    _log("_createDb: " + path);
    Database database = await openDatabase(path, version: DB_VERSION, onConfigure: (db) async {
      _log("onConfigure");
    }, onCreate: (db, version) async {
      _database = db;
      _log("onCreate version=$version");
      _createTables();
    }, onUpgrade: (db, oldVersion, newVersion) async {
      _database = db;
      _log('onUpgrade old=$oldVersion new=$newVersion');
    }, onOpen: (db) async {
      _log("onOpen");
    }, readOnly: false, singleInstance: true);
    _log("data path：" + database.path);
    return database;
  }

  _createTables() async {
    await ReadInfoDbProvider.crateTable(this, true);
  }

  Future<void> dropTable(String table, bool ifExists) async {
    String sql = "DROP TABLE " + (ifExists ? "IF EXISTS " : "") + "\"$table\"";
    return await execSQL(sql);
  }

  execSQL(String sql) async {
    return await _database!.execute(sql);
  }

  bool isOpen() {
    return _database?.isOpen == true;
  }

  static _log(String s) {
    s.log("DB_TAG");
  }

  Future<int> rawInsert(String table, List<String> fields, List values) async {
    String head = "INSERT OR REPLACE INTO";
    var sql = '$head $table (';
    var stringBuffer = StringBuffer();
    fields.forEach((element) {
      sql += element;
      sql += ",";
      stringBuffer.write("?");
      stringBuffer.write(",");
    });
    var questionString = stringBuffer.toString();
    questionString = questionString.substring(0, questionString.length - 1);
    sql = sql.substring(0, sql.length - 1) + ") VALUES (";
    sql += questionString;
    sql += ")";
    return await _database!.rawInsert(sql, values);
  }

  Future<int> insert(String table, Map<String, Object?> values,
      {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) async {
    return await _database!.insert(table, values, nullColumnHack: nullColumnHack, conflictAlgorithm: conflictAlgorithm);
  }

  Future<int> update(String table, Map<String, Object?> values,
      {String? where, List<Object?>? whereArgs, ConflictAlgorithm? conflictAlgorithm}) async {
    return await _database!
        .update(table, values, where: where, whereArgs: whereArgs, conflictAlgorithm: conflictAlgorithm);
  }

  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    //_database!.rawDelete('');
    return await _database!.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Object?>> insertList<T extends DbProvider>(String table, List<T> list) async {
    var batch = _database!.batch();
    list.forEach((element) {
      batch.insert(table, element.toMap());
    });
    return await batch.commit();
  }

  // Future<List<T>> loadAll<T extends DbProvider>(String sql,[List<Object?>? arguments]) async {
  //   var list = await _database!.rawQuery(sql,arguments);
  //   var beanList = <T>[];
  //   list.forEach((element) {
  //     beanList.add()
  //   });
  // }

}
