import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

final messengerKey = GlobalKey<ScaffoldMessengerState>();

class Utils {
  static showErrorSnackBar(String? text) {
    if (text == null) return;

    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: Colors.red,
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static showSuccessSnackBar(String? text) {
    if (text == null) return;

    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: Colors.grey,
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static Future<void> createExcel({
    required List<String> members,
    required List<List<String>> attendance,
    required List<String> dates,
    required List<int> guests,
  }) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    for (int i = 0; i < members.length; i++) {
      sheet.getRangeByIndex(i + 2, 1).setText(members[i]);

      for (int j = 0; j < attendance.length; j++) {
        bool isPresent = attendance[j].contains(members[i]);

        sheet.getRangeByIndex(1, j + 2).setText(
              DateFormat('dd.MM.yy').format(
                DateTime.parse(dates[j]),
              ),
            );
        sheet.getRangeByIndex(1, j + 2).cellStyle.rotation = 90;
        sheet.getRangeByIndex(1, j + 2).cellStyle.vAlign = VAlignType.center;
        sheet.getRangeByIndex(1, j + 2).cellStyle.hAlign = HAlignType.center;
        sheet.getRangeByIndex(i + 2, j + 2).setText(
              isPresent ? 'X' : '',
            );
        sheet.getRangeByIndex(i + 2, j + 2).cellStyle.vAlign =
            VAlignType.center;
        sheet.getRangeByIndex(i + 2, j + 2).cellStyle.hAlign =
            HAlignType.center;
        sheet.getRangeByIndex(members.length + 2, j + 2).setText(
              guests[j].toString(),
            );
        sheet.getRangeByIndex(members.length + 3, j + 2).setText(
              (attendance[j].length + guests[j]).toString(),
            );
        sheet.autoFitColumn(j + 2);
      }
    }
    sheet.getRangeByIndex(members.length + 2, 1).setText('Guests');
    sheet.getRangeByIndex(members.length + 3, 1).setText('Total Visitors');
    sheet.autoFitColumn(1);

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/attendance.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open(fileName);
  }
}
