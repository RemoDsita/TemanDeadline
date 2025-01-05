import 'package:flutter/material.dart';
import '../database/note_database.dart';
import 'package:intl/intl.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  Future refreshNotes() async {
    setState(() => _isLoading = true);
    _notes = await NoteDatabase.instance.getAllNotes();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.8),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Catatan',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.pink.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return _buildNoteCard(note);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () => _showFormDialog(context),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.judul,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(note.tanggalDibuat),
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.subjek,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              note.catatan,
              style: TextStyle(fontSize: 14),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showFormDialog(context, note: note),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await NoteDatabase.instance.delete(note.id!);
                    refreshNotes();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFormDialog(BuildContext context, {Note? note}) async {
    final _formKey = GlobalKey<FormState>();
    final judulController = TextEditingController(text: note?.judul);
    final subjekController = TextEditingController(text: note?.subjek);
    final catatanController = TextEditingController(text: note?.catatan);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note == null ? 'Tambah Catatan' : 'Edit Catatan'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: judulController,
                  decoration: const InputDecoration(labelText: 'Judul'),
                  validator: (value) =>
                      value!.isEmpty ? 'Judul tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: subjekController,
                  decoration: const InputDecoration(labelText: 'Subjek'),
                  validator: (value) =>
                      value!.isEmpty ? 'Subjek tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: catatanController,
                  decoration: const InputDecoration(labelText: 'Catatan'),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'Catatan tidak boleh kosong' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final newNote = Note(
                  id: note?.id,
                  judul: judulController.text,
                  subjek: subjekController.text,
                  catatan: catatanController.text,
                  tanggalDibuat: note?.tanggalDibuat ?? DateTime.now(),
                );

                if (note == null) {
                  await NoteDatabase.instance.create(newNote);
                } else {
                  await NoteDatabase.instance.update(newNote);
                }

                Navigator.pop(context);
                refreshNotes();
              }
            },
            child: Text(note == null ? 'Simpan' : 'Update'),
          ),
        ],
      ),
    );
  }
}
