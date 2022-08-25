import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import "../widgets/menu.dart";
import '../providers/location.dart';
import "../routes.dart";

class CodePage extends StatefulWidget {
  static const String routeName = '/code';
  @override
  State<CodePage> createState() => new CodePageState();
}

class CodePageState extends State<CodePage> {
  String answer = '';
  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();

  final snackBar = SnackBar(
    content: Text('Yay! A SnackBar!'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Menu(),
        floatingActionButton:
            new FloatingActionButton.extended(
              onPressed: () => Navigator.pushReplacementNamed(context, Routes.map),
              label: Icon(Icons.map)
            ),
        body: Consumer<LocationModel>(builder: (context, model, child) {
          return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 50.0, horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      // The validator receives the text that the user has entered.
                      controller: myController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter code';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate returns true if the form is valid, or false otherwise.
                          if (_formKey.currentState.validate()) {
                            // If the form is valid, display a snackbar. In the real world,
                            // you'd often call a server or save the information in a database.

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Processing Data')),
                            );
                            model.handleCode(myController.text);
                          }
                        },
                        child: const Text('YES'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate returns true if the form is valid, or false otherwise.
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing Data')),
                          );
                          model.handleCode('START');
                        },
                        child: const Text('RESET'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate returns true if the form is valid, or false otherwise.
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing Data')),
                          );
                          model.manualSubmit();
                        },
                        child: const Text('MANUAL'),
                      ),
                    )
                  ],
                ),
              ));
        }
        )
    );
  }
}
