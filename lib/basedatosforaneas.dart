import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:u3_ejercicio2_tablasconforanea/cita.dart';
import 'package:u3_ejercicio2_tablasconforanea/persona.dart';

class DB {
  static Future<Database> _conectarDB() async {
    return openDatabase(
      join(await getDatabasesPath(), "ejercicio2.db"),
      version: 1,
      onConfigure: (db) {
        //cuando se requiere el uso de foreign keys
        return db.execute("PRAGMA foreign_key = ON");
      },
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE PERSONA("
          "IDPERSONA INTEGER PRIMARY KEY AUTOINCREMENT,"
          "NOMBRE TEXT, "
          "TELEFONO TEXT)",
        );
        await db.execute(
          "CREATE TABLE CITA(IDCITA INTEGER PRIMARY KEY AUTOINCREMENT, "
          "LUGAR TEXT,"
          "FECHA TEXT,"
          "HORA TEXT,"
          "ANOTACIONES TEXT,"
          "COLOR INTEGER,"
          "IDPERSONA INTEGER,"
          "FOREIGN KEY (IDPERSONA) REFERENCES PERSONA (IDPERSONA) "
          "ON DELETE CASCADE ON UPDATE CASCADE)",
        );
      },
    );
  }

  //CONSULTAS PARA CRUD DE PERSONA
  static Future<List<Persona>> mostraPersonas() async {
    Database base = await _conectarDB();
    List<Map<String, dynamic>> temp = await base.query("PERSONA");
    return List.generate(temp.length, (contador) {
      return Persona(
        idpersona: temp[contador]["IDPERSONA"],
        nombre: temp[contador]["NOMBRE"],
        telefono: temp[contador]["TELEFONO"],
      );
    });
  }

  static Future<List<Persona>> buscarPersona(referencia) async {
    Database base = await _conectarDB();
    String busqueda = referencia.toLowerCase();
    List<Map<String, dynamic>> temp = await base.query(
      "PERSONA",
      where: "LOWER(NOMBRE) LIKE ? OR TELEFONO LIKE ?",
      whereArgs: ['%$busqueda%', '%$busqueda%'],
    );
    
    return List.generate(temp.length, (contador){
      return Persona(
        idpersona: temp[contador]["IDPERSONA"],
        nombre: temp[contador]["NOMBRE"],
        telefono: temp[contador]["TELEFONO"],
      );
    });
  }

  static Future<int> insertarPersona(Persona p) async {
    Database base = await _conectarDB();
    return base.insert("PERSONA", p.toJSON());
  }

  static Future<int> eliminarPersona(int idPersona) async {
    Database base = await _conectarDB();
    return base.delete("Persona", where: "IDPERSONA=?", whereArgs: [idPersona]);
  }

  static Future<int> actualizarPersona(Persona p) async {
    Database base = await _conectarDB();
    return base.update("PERSONA", p.toJSON(),where: "IDPERSONA=?", whereArgs: [p.idpersona]);
  }

  //CONSULTAS PARA CRUD DE CITAS

  static Future<List<Cita>> mostrarCitas() async {
    Database base = await _conectarDB();
    List<Map<String, dynamic>> temp = await base.query("CITA");
    return List.generate(temp.length, (contador){
      return Cita(
          idcita: temp[contador]["IDCITA"],
          lugar: temp[contador]["LUGAR"],
          fecha: temp[contador]["FECHA"],
          hora: temp[contador]["HORA"],
          anotaciones: temp[contador]["ANOTACIONES"],
          color: temp[contador]["COLOR"],
          idpersona: temp[contador]["IDPERSONA"]
      );
    });
  }

  static Future<int> insertarCita(Cita c) async {
    Database base = await _conectarDB();
    return base.insert("CITA", c.toJSON());
  }

  static Future<int> eliminarCita(int idCita) async {
    Database base = await _conectarDB();
    return base.delete("CITA", where: "IDCITA = ?", whereArgs: [idCita]);
  }

  static Future<int> actualizarCita(Cita c) async {
    Database base = await _conectarDB();
    return base.update("CITA", c.toJSON(), where: "IDCITA=?", whereArgs: [c.idcita]);
  }
}
