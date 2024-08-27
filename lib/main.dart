import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:recipeapp/Model/Recipe.dart';
import 'package:http/http.dart' as http;
import 'package:recipeapp/RecipeDetailPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String apiKey = '88b4ea3b1300473d8badf1072377b40b';

  Future<List<Recipe>> fetchRecipes() async {
    final response = await http.get(Uri.parse(
        'https://api.spoonacular.com/recipes/complexSearch?apiKey=$apiKey'));

    if (response.statusCode == 200) {
      List<dynamic> recipesList = json.decode(response.body)['results'];
      return recipesList.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 176, 229, 30),
        title: Text('Spoonacular Recipes'),
      ),
      body: FutureBuilder<List<Recipe>>(
          future: fetchRecipes(),
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error:${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text('No recipe found'),
              );
            } else {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var recipe = snapshot.data![index];
                    return ListTile(
                      title: Text(recipe.title),
                      leading: Image.network(
                        recipe.imageUrl,
                        width: 130,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecipeDetailPage(recipe: recipe),
                          ),
                        );
                      },
                    );
                  });
            }
          })),
    );
  }
}
