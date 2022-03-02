import 'package:flutter/material.dart';

class customSearchDelegate extends SearchDelegate {

  List<String> searchTerms = [
    'gym',
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      onPressed: () {
      close(context, null);
      },
     icon: AnimatedIcon(
       icon: AnimatedIcons.menu_arrow,
       progress: transitionAnimation,
      )
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    List<String> matchQuery = [];
    for(var gym in searchTerms) {
      if (gym.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(gym);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      }
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    List<String> matchQuery = [];
    for(var gym in searchTerms) {
      if (gym.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(gym);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      }
    );
  }
  
}