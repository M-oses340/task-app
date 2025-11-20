import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/home/cubit/tasks_cubit.dart';
import 'package:frontend/features/home/pages/home_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNewTaskPage extends StatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
    builder: (context) => const AddNewTaskPage(),
  );
  const AddNewTaskPage({super.key});

  @override
  State<AddNewTaskPage> createState() => _AddNewTaskPageState();
}

class _AddNewTaskPageState extends State<AddNewTaskPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Keep a single DateTime (local) for both date and time selection
  DateTime selectedDateTime = DateTime.now();

  Color selectedColor = const Color.fromRGBO(246, 222, 194, 1);

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Combines the selected local date & time, then converts to UTC before sending
  void createNewTask() async {
    if (formKey.currentState!.validate()) {
      final user = context.read<AuthCubit>().state as AuthLoggedIn;

      // selectedDateTime is in local time; convert to UTC for backend
      final utcDueAt = selectedDateTime.toUtc();

      await context.read<TasksCubit>().createNewTask(
        uid: user.user.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        color: selectedColor,
        token: user.user.token,
        dueAt: utcDueAt,
      );
    }
  }

  // Show date picker then time picker, and update selectedDateTime (local)
  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    final newDate = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
      initialDate: selectedDateTime,
    );

    if (newDate == null) return;

    final initialTime = TimeOfDay.fromDateTime(selectedDateTime);

    final newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    // If user cancels time picker, keep previous time
    final finalTime = newTime ?? initialTime;

    final combined = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      finalTime.hour,
      finalTime.minute,
    );

    setState(() {
      selectedDateTime = combined;
    });
  }

  String get _formattedDateTime =>
      DateFormat('MMM d, y — h:mm a').format(selectedDateTime);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        actions: [
          GestureDetector(
            onTap: _pickDateTime,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Text(
                  _formattedDateTime,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<TasksCubit, TasksState>(
          listener: (context, state) {
            if (state is TasksError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            } else if (state is AddNewTaskSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Task added successfully!")),
              );
              Navigator.pushAndRemoveUntil(
                  context, HomePage.route(), (_) => false);
            }
          },
          builder: (context, state) {
            if (state is TasksLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Title cannot be empty";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Description cannot be empty";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Select Color",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ColorPicker(
                      color: selectedColor,
                      heading: const Text(''),
                      subheading: const Text(''),
                      onColorChanged: (color) => setState(() {
                        selectedColor = color;
                      }),
                      pickersEnabled: const {
                        ColorPickerType.wheel: true,
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: createNewTask,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'SUBMIT',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
