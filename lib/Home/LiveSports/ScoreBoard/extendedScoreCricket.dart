import 'package:flutter/material.dart';

import 'dart:ui';

// ignore: must_be_immutable
class MyTableWidget extends StatelessWidget {
  final int rowCount;
  final whatisit;
  final teambattersnames;
  final teambattersruns;
  final balls;
  final fours;
  final sixes;
  String caption;
  MyTableWidget(
      {required this.rowCount,
      required this.teambattersnames,
      required this.teambattersruns,
      required this.fours,
      required this.sixes,
      required this.balls,
      required this.whatisit,
      required this.caption});

  @override
  Widget build(BuildContext context) {
    if (rowCount == 0) {
      return SizedBox(
        height: 1,
      );
    }
    if (teambattersnames.first == "Batter" || teambattersnames.first == "") {
      return SizedBox(
        height: 1,
      );
    }
    if (teambattersnames.first == "Baller") {
      return SizedBox(
        height: 1,
      );
    }
    return Container(
        margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(5, 22, 22, 22).withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.03,
                    bottom: MediaQuery.of(context).size.width * 0.02,
                    left: MediaQuery.of(context).size.width * 0.01,
                    right: MediaQuery.of(context).size.width * 0.01),
                color: Colors.white.withOpacity(0.1),
                child: Column(
                  children: [
                    Text(
                      '$caption',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Table(
                        children: _buildRows(),
                        columnWidths: {
                          0: FlexColumnWidth(2.4),
                          1: FlexColumnWidth(1.3),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                        },
                      ),
                    )
                  ],
                ))));
  }

  List<TableRow> _buildRows() {
    List<TableRow> rows = [];
    // Add header row

    rows.add(
      TableRow(
        children: [
          (whatisit == "batters")
              ? TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Players',
                      style: TextStyle(color: Colors.white, fontSize: 17),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                )
              : TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Players',
                      style: TextStyle(color: Colors.white, fontSize: 17),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),
          (whatisit == "batters")
              ? TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Runs',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                )
              : TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Wickets',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),
          (whatisit == "batters")
              ? TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Balls',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                )
              : TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Overs',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),
          (whatisit == "batters")
              ? TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '4s',
                      style: TextStyle(color: Colors.white, fontSize: 17),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                )
              : TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Runs',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),
          (whatisit == "batters")
              ? TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '6s',
                      style: TextStyle(color: Colors.white, fontSize: 17),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                )
              : TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      ' E!',
                      style: TextStyle(color: Colors.white, fontSize: 17),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),
        ],
      ),
    );

    // Add data rows
    for (int i = 0; i < rowCount; i++) {
      rows.add(
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 18,
                  right: 8,
                  top: 8,
                  bottom: 8,
                ),
                child: Text(
                  '${teambattersnames[i]}',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: 8,
                  bottom: 8,
                ),
                child: Text(
                  '${teambattersruns[i]}',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            (whatisit == "batters")
                ? TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        top: 8,
                        bottom: 8,
                      ),
                      child: Text(
                        '${balls[teambattersnames[i]]}',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        top: 8,
                        bottom: 8,
                      ),
                      child: Text(
                        '${(balls[teambattersnames[i]] != null) ? balls[teambattersnames[i]]! ~/ 6 : ""}.${(balls[teambattersnames[i]] != null) ? balls[teambattersnames[i]] % 6 : ""}',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: 8,
                  bottom: 8,
                ),
                child: Text(
                  '${fours[teambattersnames[i]] ?? 0}',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            (whatisit == "batters")
                ? TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        top: 8,
                        bottom: 8,
                      ),
                      child: Text(
                        '${sixes[teambattersnames[i]] ?? 0}',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        top: 8,
                        bottom: 8,
                      ),
                      child: Text(
                        '   ${(fours[teambattersnames[i]] != null) ? fours[teambattersnames[i]] / balls[teambattersnames[i]] : ""}',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          ],
        ),
      );
    }

    return rows;
  }
}
