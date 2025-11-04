//ARCHIVOS
import 'package:flutter/material.dart';
import 'package:u3_ejercicio2_tablasconforanea/basedatosforaneas.dart';
import 'package:u3_ejercicio2_tablasconforanea/persona.dart';
import 'package:u3_ejercicio2_tablasconforanea/cita.dart';
//PAQUETES
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

List<Persona> personas = [];
List<Cita> citas = [];

class _HomeState extends State<Home> {
  String kGoogleApiKey = "AIzaSyCbsuDxiN3S4C_r2qLx75vMtgcsthvhXUY";
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  Color colorCita = Colors.pink.shade300;
  Color pickerColorTemporal = Colors.pink;

  //CITA
  final lugarController = TextEditingController();
  final fechaController = TextEditingController();
  DateTime fechaSeleccionada = DateTime.now();
  final horaController = TextEditingController();
  TimeOfDay horaSeleccionada = TimeOfDay.now();
  final anotacionesController = TextEditingController();
  Persona? personaSeleccionada;

  //PERSONA
  final nombreC = TextEditingController();
  final telefonoC = TextEditingController();

  int _indice = 0;
  String busquedaP = '';

  void initState() {
    super.initState();
    actualizarListaPersonas();
    actualizarListaCitas();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Agenda de Eventos",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
        centerTitle: true,
      ),
      body: secciones(),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _indice,
        items: [
          Icon(UniconsLine.home_alt),
          Icon(UniconsLine.calendar_alt),
          Icon(UniconsLine.users_alt),
        ],
        onTap: (x) {
          setState(() {
            _indice = x;
          });
        },
        letIndexChange: (index) => true,
        color: theme.colorScheme.primary,
        buttonBackgroundColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        height: 60,
      ),
    );
  }

  Widget secciones() {
    switch (_indice) {
      case 1:
        return paginaEventos();
      case 2:
        return paginaPersonas();
    }
    return paginaHome();
  }

  Widget paginaHome() {
    if (citas.isNotEmpty) {
      return ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: citas.length,
        itemBuilder: (context, contador) {
          Persona? persona;
          try {
            persona = personas.firstWhere(
              (p) => p.idpersona == citas[contador].idpersona,
              orElse: () =>
                  Persona(idpersona: null, nombre: 'Desconocido', telefono: ''),
            );
          } catch (_) {
            persona = Persona(
              idpersona: null,
              nombre: 'Desconocido',
              telefono: '',
            );
          }
          return cardCitas(contador, persona);
        },
      );
    } else {
      return Center(
        child: Text(
          "No hay eventos para mostrar",
          style: TextStyle(fontSize: 20),
        ),
      );
    }
  }

  Widget paginaEventos() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilledButton(
                child: Row(
                  children: [
                    Text("Nuevo Evento "),
                    Icon(Icons.calendar_month),
                  ],
                ),
                onPressed: () {
                  if (personas.isEmpty) {
                    manejarRespuesta(
                      context,
                      "WARNING",
                      "No hay contactos",
                      "Antes de crear un evento, agrega al menos un contacto en la sección Personas.",
                    );
                return;
              }
              personaSeleccionada ??= personas
                  .first;
                  mostrarDialogCita(
                    context,
                    null,
                'Nuevo Evento',
                    '',
                    '',
                    '',
                    personaSeleccionada!,
                    '',
                    colorCita.value,
                    'Creación',
                  );
                },
              ),
              IconButton(onPressed: () {}, icon: Icon(UniconsLine.filter)),
            ],
          ),
          Divider(thickness: 2),
          Text(
            "Citas",
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 30),
          citas.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: citas.length,
                    itemBuilder: (context, contador) {

                      Persona persona = personas.firstWhere(
                        (p) => p.idpersona == citas[contador].idpersona,
                        orElse: () => Persona(
                            idpersona: -1, nombre: 'Desconocido', telefono: ''),
                      );
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Color(citas[contador].color!),
                        child: ListTile(
                          title: Text(
                            '${citas[contador].lugar} - ${persona.nombre}',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${citas[contador].fecha} | ${citas[contador].hora}',
                          ),
                          onTap: () {
                            AwesomeDialog(
                              context: context,
                              headerAnimationLoop: false,
                              dialogType: DialogType.info,
                              animType: AnimType.scale,
                              body: cardCitas(contador, persona),
                              btnOkOnPress: () {
                                mostrarDialogCita(
                                  context,
                                  citas[contador].idcita,
                                  'Modificando Cita ${citas[contador].lugar}',
                                  citas[contador].lugar,
                                  citas[contador].fecha,
                                  citas[contador].hora,
                                  persona,
                                  citas[contador].anotaciones!,
                                  citas[contador].color!,
                                  'Edicion',
                                );
                              },
                              btnOkText: "Editar",
                              btnOkColor: Theme.of(context).colorScheme.primary,

                              btnCancelOnPress: () {
                                confEliminacionP(
                                  context,
                                  citas[contador].idcita!,
                                  "Cita",
                                );
                                lugarController.clear();
                                fechaController.clear();
                                horaController.clear();
                                personaSeleccionada = personas.first;
                                colorCita = Colors.pink.shade300;
                                anotacionesController.clear();
                              },
                              btnCancelText: 'Eliminar',
                              btnCancelColor: Theme.of(
                                context,
                              ).colorScheme.error,
                            ).show();
                          },
                        ),
                      );
                    },
                  ),
                )
              : Center(
                  child: Text(
                    "No hay eventos para mostrar",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
        ],
      ),
    );
  }

  Widget paginaPersonas() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilledButton(
                child: Row(
                  children: [Text("Agregar Persona "), Icon(Icons.add)],
                ),
                onPressed: () {
                  mostrarDialogPersona(
                    context,
                    null,
                    'Ingrese los datos del Contacto',
                    '',
                    '',
                    'Creación',
                  );
                },
              ),
              SizedBox(
                height: 30,
                width: 100,
                child: SearchBar(
                  leading: Icon(Icons.search),
                  onChanged: (paramBusqueda) {
                    setState(() {
                      busquedaP = paramBusqueda;
                    });
                    actualizarListaPersonas();
                  },
                ),
              ),
            ],
          ),
          Divider(thickness: 2),
          Text(
            "Personas",
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: personas.length,
              itemBuilder: (context, contador) {
                return ListTile(
                  leading: CircleAvatar(child: Icon(UniconsLine.users_alt)),
                  title: Text(personas[contador].nombre),
                  subtitle: Text("Telefono: ${personas[contador].telefono}"),
                  trailing: IconButton(
                    onPressed: () {
                      llamar(personas[contador].telefono);
                    },
                    icon: Icon(UniconsLine.phone),
                  ),
                  onTap: () {
                    nombreC.text = personas[contador].nombre;
                    telefonoC.text = personas[contador].telefono;

                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.noHeader,
                      animType: AnimType.scale,
                      body: Center(
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            CircleAvatar(child: Icon(UniconsLine.users_alt)),
                            SizedBox(height: 30),
                            Text(
                              personas[contador].nombre,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            SizedBox(height: 30),
                            Text(
                              personas[contador].telefono,
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            SizedBox(height: 60),
                          ],
                        ),
                      ),

                      btnCancel: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.amberAccent,
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          confEliminacionP(
                            context,
                            personas[contador].idpersona!,
                            'Persona',
                          );
                        },
                        child: Text(
                          "Eliminar Contacto",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      btnCancelOnPress: () {},

                      btnOk: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.lightGreen,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          mostrarDialogPersona(
                            context,
                            personas[contador].idpersona,
                            "Actualizando Información de ${personas[contador].nombre}",
                            personas[contador].nombre,
                            personas[contador].telefono,
                            'Actualización',
                          );
                        },
                        child: Text(
                          "Editar Contacto",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ).show();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void actualizarListaPersonas() async {
    List<Persona> resultados;

    if (busquedaP.isEmpty) {
      resultados = await DB.mostraPersonas();
    } else {
      resultados = await DB.buscarPersona(busquedaP);
    }
    if (mounted) {
      setState(() {
        personas = resultados;
        if (personaSeleccionada == null && personas.isNotEmpty) {
          personaSeleccionada = personas.first;
        }
      });
    }
  }

  void actualizarListaCitas() async {
    List<Cita> resultados = await DB.mostrarCitas();
    setState(() {
      citas = resultados;
    });
  }

  void confEliminacionP(BuildContext contexto, int id, String tabla) {
    AwesomeDialog(
      context: contexto,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      desc: tabla == 'Persona'
          ? '¿Está seguro de eliminar este contacto?\nSe eliminarán sus citas tambien.'
          : '¿Está seguro de eliminar esta cita?',
      btnOkOnPress: () async {
        await (tabla == 'Persona' ? DB.eliminarPersona(id) : DB.eliminarCita(id)).then((
          respuesta,
        ) {
          respuesta > 0
              ? manejarRespuesta(
                  context,
                  "OK",
                  'Eliminación Exitosa',
                  'Se ha eliminado correctamente ${tabla == 'Persona' ? 'el contacto' : 'la cita'}',
                )
              : manejarRespuesta(
                  context,
                  'FALLO',
                  'Error al Intentar Eliminar',
                  'Ocurrió un error durante la eliminación. \nVuelva a intentar',
                );
        });
        actualizarListaPersonas();
        actualizarListaCitas();
      },
      btnCancelOnPress: () {},
    ).show();
  }

  void manejarRespuesta(
    BuildContext contexto,
    String resultado,
    String titulo,
    String descripcion,
  ) {
    AwesomeDialog(
      context: contexto,
      dialogType: resultado == "OK"
          ? DialogType.success
          : resultado == 'FALLO'
          ? DialogType.error
          : DialogType.warning,
      animType: AnimType.scale,
      title: titulo,
      desc: descripcion,
      btnOkOnPress: () {},
    ).show();
  }

  void mostrarDialogPersona(
    BuildContext contexto,
    int? id,
    String titulo,
    String nombre,
    String numero,
    String operacion,
  ) {
    nombreC.text = nombre;
    telefonoC.text = numero;

    AwesomeDialog(
      context: contexto,
      headerAnimationLoop: false,
      dialogType: operacion == 'Creación'
          ? DialogType.info
          : DialogType.question,
      animType: AnimType.scale,
      body: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(contexto).textTheme.titleSmall),
            TextField(
              controller: nombreC,
              decoration: InputDecoration(
                labelText: "Nombre",
                suffixIcon: Icon(UniconsLine.user),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: telefonoC,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Numero de Teléfono",
                suffixIcon: Icon(UniconsLine.phone),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
      btnOkOnPress: () async {
        Persona contacto = Persona(
          idpersona: (operacion == 'Actualización' ? id : null),
          nombre: nombreC.text,
          telefono: telefonoC.text,
        );
        await (operacion == 'Creación'
                ? DB.insertarPersona(contacto)
                : DB.actualizarPersona(contacto))
            .then((respuesta) {
              respuesta > 0
                  ? manejarRespuesta(
                      context,
                      'OK',
                      'Persona Agregada',
                      'Nuevo contacto agregado correctamente!',
                    )
                  : manejarRespuesta(
                      context,
                      'FALLO',
                      'Problema al Agregar',
                      'Ocurrió un problema al agregar el contacto. \nVuelva a intentar',
                    );
            });

        setState(() {
          nombreC.clear();
          telefonoC.clear();
          actualizarListaPersonas();
        });
      },
      btnOkText: operacion == 'Creación' ? 'Guardar' : 'Actualizar',
      btnOkColor: Theme.of(context).colorScheme.primary,

      btnCancelOnPress: () {
        nombreC.clear();
        telefonoC.clear();
      },
      btnCancelText: 'Cancelar',
      btnCancelColor: Theme.of(context).colorScheme.error,
    ).show();
  }

  void mostrarDialogCita(
    BuildContext contexto,
    int? id,
    String titulo,
    String lugar,
    String fecha,
    String hora,
    Persona invitado,
    String notas,
    int color,
    String operacion,
  ) {
    if (operacion == 'Edicion') {
      lugarController.text = lugar;
      fechaController.text = fecha;
      horaController.text = hora;
      personaSeleccionada = invitado;
      anotacionesController.text = notas;
    }
    AwesomeDialog(
      context: contexto,
      headerAnimationLoop: false,
      dialogType: operacion == 'Creación'
          ? DialogType.info
          : DialogType.question,
      animType: AnimType.scale,
      body: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Información del Evento:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            TextButton.icon(
              onPressed: () {
                mostrarColorPicker(context);
              },
              label: Text('Color de Nota'),
              icon: Icon(UniconsLine.paint_tool, size: 30),
            ),
            TextField(
              controller: lugarController,
              decoration: InputDecoration(
                labelText: "Lugar de la Cita",
                suffixIcon: Icon(UniconsLine.map),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextField(
                  readOnly: true,
                  controller: fechaController,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: "Fecha",
                    suffixIcon: Icon(UniconsLine.calender),
                  ),
                  onTap: () async {
                    DateTime? fecha = await showDatePicker(
                      context: context,
                      initialDate: fechaSeleccionada,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2030),
                    );

                    if (fecha != null && fecha != fechaSeleccionada) {
                      setState(() {
                        fechaSeleccionada = fecha;
                        fechaController.text =
                            "${fecha.day}/${fecha.month}/${fecha.year}";
                      });
                    }
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  readOnly: true,
                  controller: horaController,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: "Hora",
                    suffixIcon: Icon(UniconsLine.clock),
                  ),
                  onTap: () async {
                    TimeOfDay? hora = await showTimePicker(
                      context: context,
                      initialTime: horaSeleccionada,
                    );
                    setState(() {
                      if (hora != null && hora != horaSeleccionada) {
                        horaSeleccionada = hora;
                        horaController.text = horaSeleccionada.format(context);
                      } else {}
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            DropdownButtonFormField(
              items: personas.map((p) {
                return DropdownMenuItem(value: p, child: Text(p.nombre));
              }).toList(),
              initialValue: personas.isNotEmpty ? personaSeleccionada : null,
              decoration: InputDecoration(labelText: "Persona Invitada"),
              onChanged: (persona) {
                setState(() {
                  personaSeleccionada = persona;
                });
              },
            ),
            SizedBox(height: 10),
            Text("Anotaciones:"),
            TextField(controller: anotacionesController, maxLines: 5),
          ],
        ),
      ),
      btnOkOnPress: () async {
        if (personaSeleccionada == null ||
            personaSeleccionada!.idpersona == null ||
            lugarController.text.isEmpty ||
            fechaController.text.isEmpty ||
            horaController.text.isEmpty) {
          manejarRespuesta(
            context,
            "WARNING",
            "Datos Insuficientes",
            'Llene los datos antes de continuar',
          );
          return;
        }
        Cita evento = Cita(
          idcita: (operacion == 'Edicion' ? id : null),
          lugar: lugarController.text,
          fecha: fechaController.text,
          hora: horaController.text,
          anotaciones: anotacionesController.text,
          color: colorCita.value,
          idpersona: personaSeleccionada!.idpersona!,
        );
        await (operacion == 'Edicion'
                ? DB.actualizarCita(evento)
                : DB.insertarCita(evento))
            .then((respuesta) {
              respuesta > 0
                  ? manejarRespuesta(
                      context,
                      'OK',
                      'Cita Agendada',
                      'Se agendó correctamente la cita "${lugarController.text}"',
                    )
                  : manejarRespuesta(
                      context,
                      'FALLO',
                      'Error al Agendar',
                      'Ocurrió un problema al agendar "${lugarController.text}"',
                    );
            });

        setState(() {
          lugarController.clear();
          fechaController.clear();
          horaController.clear();
          anotacionesController.clear();
          actualizarListaCitas();
        });
      },
      btnOkText: 'Crear',
      btnOkColor: Colors.green,

      btnCancelOnPress: () {
        lugarController.clear();
        fechaController.clear();
        horaController.clear();
        anotacionesController.clear();
      },
      btnCancelText: 'Cancelar',
    ).show();
  }

  void mostrarColorPicker(BuildContext context) {
    pickerColorTemporal = colorCita;

    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      title: 'Elige el Color de tu Nota',

      body: StatefulBuilder(
        builder: (BuildContext context, StateSetter setStateInterno) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Text("Color Actual:"),
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: pickerColorTemporal,
                    shape: BoxShape.circle,
                  ),
                ),
                BlockPicker(
                  pickerColor: pickerColorTemporal,
                  availableColors: [
                    Colors.red.shade300,
                    Colors.pink.shade300,
                    Colors.orange.shade300,
                    Colors.amber.shade300,
                    Colors.yellow.shade300,
                    Colors.lightGreen.shade300,
                    Colors.teal.shade300,
                    Colors.blue.shade300,
                    Colors.indigo.shade300,
                    Colors.purple.shade300,
                    Colors.brown.shade300,
                    Colors.grey.shade300,
                  ],
                  onColorChanged: (color) {
                    setStateInterno(() {
                      pickerColorTemporal = color;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),

      btnOk: TextButton(
        onPressed: () {
          setState(() {
            colorCita = pickerColorTemporal;
          });
          Navigator.of(context).pop();
        },
        child: Text('Aceptar'),
      ),
      btnOkColor: Theme.of(context).colorScheme.primary,
    ).show();
  }

  Future<void> llamar(String numero) async {
    final Uri url = Uri(scheme: 'tel', path: numero.replaceAll(' ', ''));

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint('No hay app para manejar llamadas');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo iniciar la llamada.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget cardCitas(int contador, Persona persona) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Card(
        color: Color(citas[contador].color!),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                'Cita "${citas[contador].lugar}"',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(height: 6),
              Text(
                'Con ${persona.nombre} ${persona.telefono.isNotEmpty ? "- ${persona.telefono}" : ""}',
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Chip(
                    label: Text(citas[contador].fecha),
                    backgroundColor: Color(
                      citas[contador].color!,
                    ).withOpacity(0.5),
                  ),
                  SizedBox(width: 10),
                  Chip(
                    label: Text(citas[contador].hora),
                    backgroundColor: Color(
                      citas[contador].color!,
                    ).withOpacity(0.5),
                  ),
                ],
              ),
              SizedBox(height: 10),
              (citas[contador].anotaciones != null &&
                      citas[contador].anotaciones!.trim().isNotEmpty)
                  ? Text(citas[contador].anotaciones!)
                  : Text(
                      'No hay anotaciones',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                    ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
