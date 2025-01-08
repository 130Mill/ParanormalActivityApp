import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleThemeMode() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(color: Colors.deepPurple),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      themeMode: _themeMode,
      home: FirstScreen(toggleThemeMode: _toggleThemeMode),
    );
  }
}

class FirstScreen extends StatefulWidget {
  final VoidCallback toggleThemeMode;

  const FirstScreen({required this.toggleThemeMode, super.key});

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  String? selectedActivity;
  final List<String> activities = [
    'Ghost',
    'Demon',
    'Spirit',
    'Poltergeist',
    'Goblin',
    'Ghoul',
    'Monster'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paranormal Activity Detector'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: widget.toggleThemeMode,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "What type of Paranormal Activity Would You Like To Detect?",
              style: TextStyle(fontSize: 22.5, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedActivity,
              hint: Text("Select Activity"),
              items: activities.map((String activity) {
                return DropdownMenuItem<String>(
                  value: activity,
                  child: Text(activity),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedActivity = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedActivity == null
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SecondScreen(
                      activityType: selectedActivity!,
                    ),
                  ),
                );
              },
              child: Text("Start Scan"),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  final String activityType;

  const SecondScreen({required this.activityType, super.key});

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  List<double> gaugeValues = [0, 0, 0, 0, 0, 0];
  String status = "Analyzing Paranormal Indicators.....";
  bool detectionComplete = false;

  @override
  void initState() {
    super.initState();

    List<int> durations = [4500, 4100, 4300, 3800, 4000, 4200];
    List<int> maxValues = [120, 150, 100, 100, 80, 360];
    List<Timer> timers = [];

    for (int i = 0; i < gaugeValues.length; i++) {
      timers.add(Timer.periodic(Duration(milliseconds: 200), (timer) {
        setState(() {
          gaugeValues[i] = (gaugeValues[i] + (i + 1) * 10) % maxValues[i];
        });
        if (timer.tick * 200 >= durations[i]) {
          timer.cancel();
          setState(() {
            gaugeValues[i] = 0;
          });
        }
      }));
    }

    Future.delayed(Duration(milliseconds: durations.reduce((a, b) => a > b ? a : b)), () {
      setState(() {
        gaugeValues = [0, 0, 0, 0, 0, 0];
      });
    });

    Future.delayed(Duration(milliseconds: durations.reduce((a, b) => a > b ? a : b) + 1000), () {
      setState(() {
        status = "Result: No ${widget.activityType} Activity In This Area";
        detectionComplete = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Activity Detector')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              padding: const EdgeInsets.all(16.0),
              children: [
                buildSpeedometerGauge(gaugeValues[0], Colors.green, Colors.yellow, Colors.red, 120, 60, 80),
                buildRectangularGauge(gaugeValues[1], Colors.blue, Colors.purple, 150),
                buildHorizontalBarGauge(gaugeValues[2], Colors.blue, Colors.purple, 100),
                buildSpeedometerGauge(gaugeValues[3], Colors.green, Colors.yellow, Colors.red, 100, 50, 70),
                buildSpeedometerGauge(gaugeValues[4], Colors.green, Colors.yellow, Colors.red, 80, 40, 60),
                buildSonarGauge(gaugeValues[5], 360),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                color: detectionComplete ? Colors.lightGreenAccent : Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.all(16),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: detectionComplete ? 28.125 : 22.5,
                  fontWeight: FontWeight.bold,
                  color: detectionComplete ? Colors.black : Colors.blue,
                  fontFamily: detectionComplete ? 'Arial' : null,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSpeedometerGauge(double value, Color startColor, Color midColor, Color endColor, double maxValue, double yellowStart, double redStart) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: maxValue,
          pointers: <GaugePointer>[
            NeedlePointer(
              value: value,
              enableAnimation: true,
              animationDuration: 500,
              needleColor: endColor,
            ),
          ],
          ranges: <GaugeRange>[
            GaugeRange(
              startValue: 0,
              endValue: yellowStart,
              color: startColor,
            ),
            GaugeRange(
              startValue: yellowStart,
              endValue: redStart,
              color: midColor,
            ),
            GaugeRange(
              startValue: redStart,
              endValue: maxValue,
              color: endColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildRectangularGauge(double value, Color startColor, Color endColor, double maxValue) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 100,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.zero,
            color: Colors.grey.withOpacity(0.3),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: (value / maxValue) * 100 + 5,
              width: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [startColor, endColor],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildHorizontalBarGauge(double value, Color startColor, Color endColor, double maxValue) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 20,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.zero,
            color: Colors.grey.withOpacity(0.3),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: (value / maxValue) * 100 + 5,
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [startColor, endColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSonarGauge(double value, double maxValue) {
    return CustomPaint(
      size: Size(100, 100),
      painter: SonarGaugePainter(value: value, maxValue: maxValue),
    );
  }
}

class SonarGaugePainter extends CustomPainter {
  final double value;
  final double maxValue;

  SonarGaugePainter({required this.value, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    Paint radarLinePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);
    canvas.drawCircle(size.center(Offset.zero), size.width / 2, radarLinePaint);
    canvas.drawCircle(size.center(Offset.zero), size.width / 3, radarLinePaint);
    canvas.drawCircle(size.center(Offset.zero), size.width / 6, radarLinePaint);

    double sweepAngle = (value / maxValue) * 360;
    Paint radarSweepPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.green.withOpacity(0.5), Colors.transparent],
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
      ).createShader(Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2));

    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
      -3.14 / 2,
      sweepAngle * (3.14 / 180),
      true,
      radarSweepPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

