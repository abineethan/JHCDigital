import 'package:flutter/material.dart';

class MyTableWidget extends StatelessWidget {
  final int rowCount;
  final List<String> teamshootersnames;
  final Map<String, num> teamshooterspoints;
  final Map<String, num> fouls;
  final String caption;
  final bool isDesktop;

  const MyTableWidget({
    Key? key,
    required this.rowCount,
    required this.teamshootersnames,
    required this.teamshooterspoints,
    required this.fouls,
    required this.caption,
    required this.isDesktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (rowCount == 0) {
      return const SizedBox(height: 1);
    }
    return Column(
      children: [
        Text(
          caption,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 18.0 : 16.0,
            color: Colors.white,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Table(
            border: TableBorder.all(),
            children: _buildRows(),
            columnWidths: const {
              0: FlexColumnWidth(2.4),
              1: FlexColumnWidth(1.3),
              2: FlexColumnWidth(1),
            },
          ),
        ),
      ],
    );
  }

  List<TableRow> _buildRows() {
    List<TableRow> rows = [];

    // Header row
    rows.add(
      TableRow(
        children: [
          TableCell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Players',
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: isDesktop ? 18 : 16
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          TableCell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Points',
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: isDesktop ? 16 : 14
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          TableCell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Fouls',
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: isDesktop ? 18 : 16
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );

    // Data rows
    for (int i = 0; i < rowCount; i++) {
      rows.add(
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 18, right: 8, top: 8, bottom: 8),
                child: Text(
                  teamshootersnames[i],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 16 : 14,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
                child: Text(
                  '${teamshooterspoints[teamshootersnames[i]] ?? 0}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 16 : 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
                child: Text(
                  '${fouls[teamshootersnames[i]] ?? 0}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 16 : 14,
                  ),
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