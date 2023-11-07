import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:w10_sqlite/database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> myData = [];

  bool _isLoading = true;

  void _refreshData() async {
    final data = await DatabaseHelper.fetchAll();

    setState(() {
      myData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _prodiController = TextEditingController();
  final TextEditingController _angkatanController = TextEditingController();

  void showMyForm(int? id) async {
    if (id != null) {
      final existingData = myData.firstWhere((element) => element['id'] == id);

      _nimController.text = existingData['nim'].toString();
      _namaController.text = existingData['nama'];
      _prodiController.text = existingData['prodi'];
      _angkatanController.text = existingData['angkatan'].toString();
    }

    showModalBottomSheet(
        context: context,
        elevation: 0,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _nimController,
                    decoration: const InputDecoration(hintText: 'NIM'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _namaController,
                    decoration: const InputDecoration(hintText: 'Nama'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _prodiController,
                    decoration: const InputDecoration(hintText: 'Prodi'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _angkatanController,
                    decoration: const InputDecoration(hintText: 'Angkatan'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          await insertItem();
                        }
                        if (id != null) {
                          await updateItem(id);
                        }

                        _nimController.text = '';
                        _namaController.text = '';
                        _prodiController.text = '';
                        _angkatanController.text = '';

                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'Create New' : 'Update')),
                ],
              ),
            ));
  }

  Future<void> insertItem() async {
    await DatabaseHelper.insertItem(
        int.parse(_nimController.text), _namaController.text, _prodiController.text, int.parse(_angkatanController.text));
  }

  Future<void> updateItem(int id) async {
    await DatabaseHelper.update(
        id, int.parse(_nimController.text), _namaController.text, _prodiController.text, int.parse(_angkatanController.text));

    _refreshData();
  }

  void deleteItem(int id) async {
    await DatabaseHelper.destroy(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully Deleted'),
      backgroundColor: Colors.green,
    ));

    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : myData.isEmpty
              ? const Center(
                  child: Text("No data is available"),
                )
              : ListView.builder(
                  itemCount: myData.length,
                  itemBuilder: (context, index) => Card(
                    color:
                        index % 2 == 0 ? Colors.green : Colors.green.shade200,
                    margin: const EdgeInsets.all(15),
                    child: ListTile(
                      title: Text(myData[index]['nama']),
                      subtitle: Text('${myData[index]['nim']}/${myData[index]['prodi']}/${myData[index]['angkatan']}'),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () =>
                                    showMyForm(myData[index]['id']),
                                icon: const Icon(Icons.edit)),
                            IconButton(
                                onPressed: () =>
                                    deleteItem(myData[index]['id']),
                                icon: const Icon(Icons.delete))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showMyForm(null),
      ),
    );
  }
}
