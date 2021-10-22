import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(HomeScreen());

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage = 0;
  final PageController pageController = new PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [Listar(), AgregarLibro(), Acerca()]),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentPage,
          onTap: (index) {
            currentPage = index;
            pageController.animateToPage(
              index,
              duration: const Duration(seconds: 1),
              curve: Curves.easeOut,
            );
            setState(() {});
          },
          fixedColor: Colors.black,
          backgroundColor: Colors.teal,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.article_outlined),
                label: 'Listar',
                activeIcon: Icon(Icons.article)),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_outlined),
                label: 'Agregar Libro',
                activeIcon: Icon(Icons.add)),
            BottomNavigationBarItem(
                icon: Icon(Icons.info_outline),
                label: 'Acerca',
                activeIcon: Icon(Icons.info)),
          ]),
    );
  }
}

class Listar extends StatefulWidget {
  @override
  State<Listar> createState() => _ListarState();
}

class _ListarState extends State<Listar> {
  List data = [];
  getBooks() async {
    http.Response response = await http.get(
        Uri.parse('https://crud-mongo-biblioteca.herokuapp.com/api/books'));

    data = json.decode(response.body);
    setState(() {
      data;
    });
  }

  @override
  void initState() {
    super.initState();
    getBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white54,
      child: Center(
          child:
              // Text('First'),
              ListView.builder(
        itemCount: data == null ? 0 : data.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("${index + 1}"),
                ),
                CircleAvatar(
                  backgroundImage: NetworkImage(data[index]["imgUrl"]),
                ),
                Column(
                  children: [
                    Text(
                      " Titulo: ${data[index]["title"].toString().toUpperCase()}",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text("      Autor: ${data[index]["author"]}"),
                    Text("Paginas: ${data[index]["pages"]}"),
                  ],
                ),
              ],
            ),
          );
        },
      )),
    );
  }
}

class AgregarLibro extends StatefulWidget {
  @override
  State<AgregarLibro> createState() => _AgregarLibroState();
}

class _AgregarLibroState extends State<AgregarLibro> {
  final title = TextEditingController();
  final author = TextEditingController();
  final year = TextEditingController();
  final imgUrl = TextEditingController();
  final pages = TextEditingController();

  /////////////////////
  postBook(String title, String author, String year, String imgUrl,
      String pages) async {
    final response = await http.post(
      Uri.parse('https://crud-mongo-biblioteca.herokuapp.com/api/books'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        "author": author,
        "publication_year": year,
        "imgUrl": imgUrl,
        "pages": pages,
      }),
    );

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      showDialog<void>(
        context: context,
        // false = user must tap button, true = tap outside dialog
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text('Agregar Libro'),
            content: Text('Libro Creado!'),
            actions: <Widget>[
              TextButton(
                child: Text('Aceptar'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                },
              ),
            ],
          );
        },
      );
      return const Text("Created");
    } else {
      //If the server did not return a 201 CREATED response,
      //then throw an exception.
      throw Exception('Failed to create Book.');
    }
  }

  /////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(3),
        color: Colors.white54,
        child: Form(
            child: Column(
          children: [
            TextFormField(
              controller: title,
              decoration: const InputDecoration(
                  labelText: "Titulo", border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 3,
            ),
            TextFormField(
              controller: author,
              decoration: const InputDecoration(
                  labelText: "Autor", border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 3,
            ),
            TextFormField(
              controller: year,
              decoration: const InputDecoration(
                  labelText: "Año", border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 3,
            ),
            TextFormField(
              controller: imgUrl,
              decoration: const InputDecoration(
                  hintText: "http://clipart-library.com/images/6Tpo6G8TE.jpg",
                  labelText: "Imagen",
                  border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 3,
            ),
            TextFormField(
              controller: pages,
              decoration: const InputDecoration(
                  labelText: "Paginas", border: OutlineInputBorder()),
            ),
            ElevatedButton(
              onPressed: () {
                postBook(title.text, author.text, year.text, imgUrl.text,
                    pages.text);
              },
              child: const Text("Send"),
            )
          ],
        )));
  }
}

class Acerca extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white70,
      child: const Center(
        child: Text('Stack Flutter - Node - Mongo'),
      ),
    );
  }
}
