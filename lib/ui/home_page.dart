import 'dart:io';

import 'package:contact_list/helpers/contact_helper.dart';
import 'package:contact_list/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderAZ, orderZA }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contacts = [];

  @override
  void initState() {
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contatos"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 77, 183, 229),
        actions: [
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                  value: OrderOptions.orderAZ, child: Text("Ordenar de A-Z")),
              const PopupMenuItem<OrderOptions>(
                  value: OrderOptions.orderZA, child: Text("Ordenar de Z-A"))
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: _showContactPage,
        backgroundColor: const Color.fromARGB(255, 77, 183, 229),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _contactCard(context, index);
          }),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: (contacts[index].img != null)
                            ? FileImage(File(contacts[index].img!))
                                as ImageProvider
                            : const AssetImage("assets/images/user_img.png"),
                      ))),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contacts[index].name ?? "",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            contacts[index].email ?? "",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            contacts[index].phone ?? "",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ])),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              launchUrl(
                                  Uri.parse("tel:${contacts[index].phone}"));
                            },
                            child: const Text(
                              "Ligar",
                              style:
                                  TextStyle(color: Colors.green, fontSize: 20),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showContactPage(contact: contacts[index]);
                            },
                            child: const Text(
                              "Editar",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 77, 183, 229),
                                  fontSize: 20),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                helper.deleteContact(contacts[index].id!);
                                contacts.removeAt(index);
                              });
                            },
                            child: Text(
                              "Excluir",
                              style: TextStyle(
                                  color: Colors.red.shade600, fontSize: 20),
                            )),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  void _getAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list.cast();
      });
    });
  }

  void _showContactPage({Contact? contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contact,
                )));

    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderAZ:
        contacts.sort((a, b) {
          if (a.name == null || b.name == null) {
            return -1;
          } else {
            return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
          }
        });
        break;
      case OrderOptions.orderZA:
        contacts.sort((a, b) {
          return b.name!.toLowerCase().compareTo(a.name!.toLowerCase());
        });
        break;
    }
    setState(() {});
  }
}
