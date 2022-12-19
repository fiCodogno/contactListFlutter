import 'dart:io';

import 'package:contact_list/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;
  const ContactPage({this.contact, super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late Contact _editedContact;
  bool _userEdited = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact!.toMap());

      _nameController.text = _editedContact.name!;
      _emailController.text = _editedContact.email!;
      _phoneController.text = _editedContact.phone!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 77, 183, 229),
            title: Text(_editedContact.name ?? "Novo Contato"),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 77, 183, 229),
            onPressed: () {
              if (_editedContact.name!.isNotEmpty &&
                  _editedContact.name != null) {
                Navigator.pop(context, _editedContact);
              } else {
                FocusScope.of(context).requestFocus(_nameFocus);
              }
            },
            child: const Icon(Icons.save),
          ),
          body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: _editedContact.img != null
                                  ? FileImage(File(_editedContact.img!))
                                      as ImageProvider
                                  : const AssetImage(
                                      "assets/images/user_img.png"),
                            ))),
                    onTap: () {
                      ImagePicker()
                          .pickImage(source: ImageSource.gallery)
                          .then((file) {
                        if (file != null) {
                          setState(() {
                            _editedContact.img = file.path;
                          });
                        }
                      });
                    },
                  ),
                  TextField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    decoration: const InputDecoration(labelText: "Nome"),
                    onChanged: (text) {
                      _userEdited = true;
                      setState(() {
                        _editedContact.name = text;
                      });
                    },
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    onChanged: (text) {
                      _userEdited = true;
                      _editedContact.email = text;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: "Phone"),
                    onChanged: (text) {
                      _userEdited = true;
                      _editedContact.phone = text;
                    },
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ))),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Descartar Alterações?"),
              content: const Text("Se sair, as alterações serão perdidas."),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancelar")),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text("Sim")),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
