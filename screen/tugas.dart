import 'package:flutter/material.dart';
import '../database/tugas_database.dart';
import 'package:intl/intl.dart';

class TugasScreen extends StatefulWidget {
  const TugasScreen({super.key});

  @override
  State<TugasScreen> createState() => _TugasScreenState();
}

class _TugasScreenState extends State<TugasScreen> {
  List<Tugas> _tugas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    refreshTugas();
  }

  Future refreshTugas() async {
    setState(() => _isLoading = true);
    _tugas = await TugasDatabase.instance.getAllTugas();
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
          'Daftar Tugas',
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
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tugas.length,
                      itemBuilder: (context, index) {
                        final tugas = _tugas[index];
                        return _buildTugasCard(tugas);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () => _showFormDialog(context),
      ),
    );
  }

  Widget _buildTugasCard(Tugas tugas) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      color: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tugas.mataKuliah,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Deadline: ${DateFormat('dd MMM yyyy HH:mm').format(tugas.deadline)}',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: tugas.progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                tugas.progress < 0.3
                    ? Colors.red
                    : tugas.progress < 0.7
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tugas.catatan,
              style: TextStyle(color: Colors.white),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () => _showFormDialog(context, tugas: tugas),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () async {
                    await TugasDatabase.instance.delete(tugas.id!);
                    refreshTugas();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFormDialog(BuildContext context, {Tugas? tugas}) async {
    final _formKey = GlobalKey<FormState>();
    final mataKuliahController = TextEditingController(text: tugas?.mataKuliah);
    final catatanController = TextEditingController(text: tugas?.catatan);
    DateTime? selectedDate = tugas?.deadline ?? DateTime.now();
    double progress = tugas?.progress ?? 0.0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tugas == null ? 'Tambah Tugas' : 'Edit Tugas'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: mataKuliahController,
                  decoration: const InputDecoration(labelText: 'Mata Kuliah'),
                  validator: (value) =>
                      value!.isEmpty ? 'Mata kuliah tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: catatanController,
                  decoration: const InputDecoration(labelText: 'Catatan'),
                  validator: (value) =>
                      value!.isEmpty ? 'Catatan tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Deadline'),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy HH:mm').format(selectedDate!),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2025),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate!),
                      );
                      if (time != null) {
                        setState(() {
                          selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text('Progress: ${(progress * 100).toStringAsFixed(0)}%'),
                Slider(
                  value: progress,
                  onChanged: (value) => setState(() => progress = value),
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
                final newTugas = Tugas(
                  id: tugas?.id,
                  mataKuliah: mataKuliahController.text,
                  deadline: selectedDate!,
                  catatan: catatanController.text,
                  progress: progress,
                );

                if (tugas == null) {
                  await TugasDatabase.instance.create(newTugas);
                } else {
                  await TugasDatabase.instance.update(newTugas);
                }

                Navigator.pop(context);
                refreshTugas();
              }
            },
            child: Text(tugas == null ? 'Simpan' : 'Update'),
          ),
        ],
      ),
    );
  }
}
