import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quotes_generator_app/quotes_model.dart';
import 'package:http/http.dart' as http;

class ApiHomePage extends StatefulWidget {
  const ApiHomePage({super.key});

  @override
  State<ApiHomePage> createState() => _ApiHomePageState();
}

class _ApiHomePageState extends State<ApiHomePage> {
  int imageSelected = 0;
  List<String> images = [
    'images/1.jpg',
    'images/2.png',
    'images/3.jpg',
    'images/4.jpg',
  ];
  List<QuotesModel> quotesList = [];
  final grey = Colors.blueGrey[800];
  Future<List<dynamic>>? quoteData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //if quoteData is null fetch data
    quoteData = getQuotesAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(children: [
        Container(
            alignment: Alignment.center,
            child: ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Image.asset(
                    height: MediaQuery.of(context).size.height,
                    images[imageSelected],
                    fit: BoxFit.cover,
                  );
                })),
        Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        imageSelected = Random().nextInt(images.length);
                      });
                    },
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                      size: 45,
                    ))
              ],
            )),
        FutureBuilder(
          future: quoteData!,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }

            final data = snapshot.data!;
            final randomIndex = Random().nextInt(data.length);
            return Center(
              child: Text(
                '${data[randomIndex].q.toString()} - ${data[randomIndex].a.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ]),
    ));
  }

  Future<List<QuotesModel>> getQuotesAPI() async {
    try {
      final response =
          await http.get(Uri.parse('https://zenquotes.io/api/quotes'));
      final data = jsonDecode(response.body.toString());
      if (response.statusCode == 200) {
        for (Map<String, dynamic> i in data) {
          quotesList.add(QuotesModel.fromJson(i));
        }

        return quotesList;
      } else {
        throw Exception('Failed to load quotes');
      }
    } catch (e) {
      throw Exception('Error fetching quotes: $e');
    }
  }
}
