import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

List<int> _selectedIndexes = [1, 2, 3, 4];

class ChooseLanguage extends StatefulWidget {
  @override
  _ChooseLanguageState createState() => _ChooseLanguageState();

  Set<int> getSelectedIndex() {
    Set<int> uniqueSet = Set<int>.from(_selectedIndexes);
    return uniqueSet;
  }
}

class LanguageModel {
  final String language;
  final Icon imagePath;
  final int value;
  LanguageModel(
      {required this.language, required this.imagePath, required this.value});
}

List<LanguageModel> languages = [
  LanguageModel(
      language: "Cricket",
      imagePath: Icon(
        Icons.sports_cricket,
        color: Colors.white,
      ),
      value: 1),
  LanguageModel(
      language: "Basketball",
      imagePath: Icon(
        Icons.sports_basketball,
        color: Colors.white,
      ),
      value: 2),
  LanguageModel(
      language: "Football",
      imagePath: Icon(
        Icons.sports_football,
        color: Colors.white,
      ),
      value: 3),
  LanguageModel(
      language: "Table Tennis",
      imagePath: Icon(
        Icons.sports_tennis,
        color: Colors.white,
      ),
      value: 4),
  LanguageModel(
      language: "Hockey",
      imagePath: Icon(
        Icons.sports_hockey,
        color: Colors.white,
      ),
      value: 5),
];

class _ChooseLanguageState extends State<ChooseLanguage> {
  late SharedPreferences _prefs;
  int _activeIndex = -1;

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSelectedIndex();
  }

  _loadSelectedIndex() {
    setState(() {
      _activeIndex = _prefs.getInt('selected_index') ?? -1;
    });
  }

  _saveSelectedIndex() {
    _prefs.setInt('selected_index', _activeIndex);
    _selectedIndexes.remove(_activeIndex);
  }

  _saveSelectedIndex2() {
    _prefs.setInt('selected_index', _activeIndex);
    _selectedIndexes.add(_activeIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.75),
      ),
      width: MediaQuery.of(context).size.width * 0.75,
      height: MediaQuery.of(context).size.height * 0.68,
      child: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.75,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select the Sports",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.07,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.07,
                ),
                ...languages.map((language) {
                  int _currentIndex = languages.indexOf(language);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeIndex = _currentIndex;
                      });
                    },
                    child: LanguageSelector(
                      language: language.language,
                      imagePath: language.imagePath,
                      value: language.value,
                    ),
                  );
                }).toList(),
                AnimatedCrossFade(
                  crossFadeState: _activeIndex == -1
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: Duration(milliseconds: 450),
                  firstChild: Container(
                    height: 50.0,
                  ),
                  secondChild: TextButton(
                    child: Text(""),
                    onPressed: () {},
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LanguageSelector extends StatefulWidget {
  final String language;
  final Icon imagePath;
  final int value;
  LanguageSelector(
      {Key? key,
      required this.language,
      required this.imagePath,
      required this.value})
      : super(key: key);

  @override
  _LanguageSelectorState createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  late SharedPreferences _prefs;
  late bool isActive = true;

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  _initPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      setState(() {
        isActive = _prefs.getBool('${widget.language}_active') ?? false;
      });
    } catch (e) {
      print('Error initializing SharedPreferences: $e');
    }
  }

  _toggleActive() {
    setState(() {
      isActive = !isActive;
    });
    _prefs.setBool('${widget.language}_active', isActive);

    // Update the active index based on the selected language's value
    final _ChooseLanguageState? chooseLanguageState =
        context.findAncestorStateOfType<_ChooseLanguageState>();
    if (isActive) {
      chooseLanguageState?._activeIndex = widget.value; // Use widget.value here
      chooseLanguageState?._saveSelectedIndex2();
    }
    if (!isActive) {
      chooseLanguageState?._activeIndex = widget.value; // Use widget.value here
      chooseLanguageState?._saveSelectedIndex();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _toggleActive();
          // Save the selected index when a language is tapped
          if (!isActive) {
            final _ChooseLanguageState? chooseLanguageState =
                context.findAncestorStateOfType<_ChooseLanguageState>();
            chooseLanguageState?._saveSelectedIndex();
          }
          if (isActive) {
            final _ChooseLanguageState? chooseLanguageState =
                context.findAncestorStateOfType<_ChooseLanguageState>();
            chooseLanguageState?._saveSelectedIndex2();
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 7.0),
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.065),
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.1,
        decoration: BoxDecoration(
          color: Color.fromARGB(200, 20, 21, 24),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(107, 23, 23, 23),
              spreadRadius: 0,
              blurRadius: 8,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        child: Center(
          child: Row(
            children: [
              widget.imagePath,
              SizedBox(
                width: 10.0,
              ),
              Text(
                widget.language,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Container(
                child: isActive
                    ? Icon(
                        Icons.donut_small,
                        color: Colors.white,
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
