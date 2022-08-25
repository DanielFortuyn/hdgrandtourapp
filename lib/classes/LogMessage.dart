import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class LogMessage {
  String _title;
  String _description;
  String subTitle;
  IconData icon;
  String img;
  int level;


  LogMessage(title, description, {this.icon = Icons.arrow_drop_down_circle, this.img, this.subTitle, this.level = 0}) {
    _title = title;
    _description = description;

    if(this.subTitle == '' || this.subTitle == null) {
      final currentTime = new DateTime.now();
      this.subTitle = timeago.format(currentTime, locale: 'nl', allowFromNow: false).toString();
    }
  }

  String get title => _title;
  String get description => _description;
}
