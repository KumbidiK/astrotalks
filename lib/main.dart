import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

// Main application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AstroTalk',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// Data model for user input.
class UserInput {
  final String name;
  final String starSign;
  final DateTime dob;
  final String question;

  UserInput({
    required this.name,
    required this.starSign,
    required this.dob,
    required this.question,
  });
}

// First screen for user input.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _questionController = TextEditingController();
  String? _selectedStarSign;
  DateTime _selectedDate = DateTime.now();

  // List of zodiac signs for the dropdown menu.
  final List<String> _starSigns = [
    'അശ്വതി', 'ഭരണി', 'കാർത്തിക', 'ോഹിണി', 'മകയിരം', 'തിരുവാതിര',
    ' പുണർത', 'പൂയം', 'ആയില്യം', 'മകം', 'പൂരം', 'ഉത്രം', 'അത്തം','ചിത്തിര',' ചോതി','വിശാഖം', 'അനിഴം', 'തൃക്കേട്ട',
    'മൂലം',  'ഉത്രാടം', 'തിരുവോണ', 'അവിട്ടം', 'അവിട്ടം', 'ചതയം', 'പൂരൂരുട്ടാതി', 'ഉത്രട്ടാതി', 'രേവതി'
  ];

  // Function to show the date picker.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Function to handle form submission.
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final userInput = UserInput(
        name: _nameController.text,
        starSign: _selectedStarSign!,
        dob: _selectedDate,
        question: _questionController.text,
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultScreen(userInput: userInput),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ജ്യോത്സ്യനോട് ചോദിക്കൂ'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'നിന്റെ നാമം',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ദയവായി നാമം പറയുക';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'നിന്റെ ജന്മനക്ഷത്രം',
                ),
                value: _selectedStarSign,
                items: _starSigns.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStarSign = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'ദയവായി നക്ഷത്രം പറയുക';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'നിന്റെ ജന്മദിനം',
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    controller: TextEditingController(
                      text: DateFormat('yMMMd').format(_selectedDate),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'നിന്റെ ചോദ്യം',
                  hintText: 'എന്താണ് അറിയേണ്ടത് ?',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ദയവായി ചോദ്യം പൂരിപ്പിക്കുക';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('എന്റെ രാശി പറയു'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Second screen to show the results.
class ResultScreen extends StatefulWidget {
  final UserInput userInput;
  const ResultScreen({super.key, required this.userInput});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    // Start playing the audio automatically as soon as the screen is loaded.
    _playAudio();
  }

  // Function to play the audio.
  void _playAudio() async {
    // You can provide your audio file here. Make sure it's in the assets folder
    // and you've added it to pubspec.yaml.
    await _audioPlayer.play(AssetSource('jyo1_2.mp3'));
  }

  @override
  void dispose() {
    // Stop the audio and dispose of the player when the screen is closed.
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ഗുണപരിശോധനയ്ക്ക് ശേഷം'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // You can provide your image here.
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/dever.png',
                  height: 600,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.error_outline,
                      size: 300,
                      color: Colors.red,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'നമസ്കാരം, ${widget.userInput.name}!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              
              const SizedBox(height: 32),
              // We've replaced the buttons with a simple text message.
              Text(
                'നിന്റെ ജാതകം ഓതുന്നു...',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}