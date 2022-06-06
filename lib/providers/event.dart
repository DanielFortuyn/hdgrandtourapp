import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import "../classes/Event.dart";


import "../helpers/dio.dart";

class EventModel with ChangeNotifier {
  List<Event> _events = [];

  List<Event> get scores => _events;

  EventModel() {
    fetchEvent();
  }

  void fetchEvent() async {
      Response response = await dio.get('/event');
      List s = response.data;

      for (int i=0; i<s.length; i++) {
          _events.add(Event.fromJson(s[i]));
      }          
      // print(jsonDecode(response.data));
      notifyListeners();
  } 
}