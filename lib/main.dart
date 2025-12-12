import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Toll Gate App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF181928),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2E1C38),
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white10),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF69F0AE)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// SCREEN 1: WELCOME SCREEN
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.toll, size: 100, color: Color(0xFF69F0AE)),
              const SizedBox(height: 20),
              const Text(
                "TOLL GATE SYSTEM",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF69F0AE), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 15)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage())),
                child: const Text("LOG IN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.pinkAccent, width: 2), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage())),
                child: const Text("CREATE ACCOUNT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// SCREEN 2: LOG IN PAGE
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController rfidController = TextEditingController();
  bool isLoading = false;

  void login() async {
    String rfid = rfidController.text.trim();
    if (rfid.isEmpty) return;

    setState(() => isLoading = true);

    try {
      var querySnapshot = await FirebaseFirestore.instance.collection('users').where('rfid', isEqualTo: rfid).get();
      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data();
        String name = userData['firstName'];
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainContainer(userName: name, userRfid: rfid)),
            (route) => false,
          );
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("RFID not found! Please register.")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Login", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            MyTextField(controller: rfidController, label: "Scan RFID Number"),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF69F0AE)),
                onPressed: isLoading ? null : login,
                child: isLoading ? const CircularProgressIndicator(color: Colors.black) : const Text("LOG IN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// SCREEN 3: SIGN UP PAGE
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController fName = TextEditingController();
  final TextEditingController lName = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController sex = TextEditingController();
  final TextEditingController rfid = TextEditingController();
  bool isLoading = false;

  void register() async {
    if (fName.text.isEmpty || rfid.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name and RFID are required")));
        return;
    }
    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('users').add({
        'firstName': fName.text,
        'lastName': lName.text,
        'age': age.text,
        'sex': sex.text,
        'rfid': rfid.text,
        'balance': 0, 
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainContainer(userName: fName.text, userRfid: rfid.text)),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("Create Account", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Row(children: [Expanded(child: MyTextField(controller: fName, label: "First Name")), const SizedBox(width: 10), Expanded(child: MyTextField(controller: lName, label: "Last Name"))]),
            const SizedBox(height: 15),
            Row(children: [Expanded(child: MyTextField(controller: age, label: "Age", isNumber: true)), const SizedBox(width: 10), Expanded(child: MyTextField(controller: sex, label: "Sex"))]),
            const SizedBox(height: 15),
            MyTextField(controller: rfid, label: "RFID Number"),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                onPressed: isLoading ? null : register,
                child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("REGISTER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// SCREEN 4: MAIN CONTAINER
class MainContainer extends StatefulWidget {
  final String userName;
  final String userRfid;

  const MainContainer({super.key, required this.userName, required this.userRfid});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardScreen(userName: widget.userName, userRfid: widget.userRfid),
      const PlaceholderScreen(title: "History", icon: Icons.history),
      const PlaceholderScreen(title: "Reload Stations", icon: Icons.map),
      ProfileScreen(userName: widget.userName, userRfid: widget.userRfid),
    ];
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pinkAccent : Colors.transparent, 
          borderRadius: BorderRadius.circular(15), 
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isSelected ? Colors.white : Colors.grey,
              size: 26,
            ),
            const SizedBox(height: 4),
            
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 10,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Color(0xFF181928),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), 
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround, // Spread items evenly
          children: [
            _buildNavItem(0, Icons.dashboard, "Home"),
            _buildNavItem(1, Icons.history, "History"),
            _buildNavItem(2, Icons.payment, "Reload"),
            _buildNavItem(3, Icons.person, "Profile"),
          ],
        ),
      ),
    );
  }
}

// SCREEN 4.1: DASHBOARD
class DashboardScreen extends StatefulWidget {
  final String userName;
  final String userRfid;

  const DashboardScreen({super.key, required this.userName, required this.userRfid});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void showAddBalanceDialog() {
    TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2E1C38),
          title: const Text("Load Balance", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: "Enter Amount", prefixText: "₱ ", prefixStyle: TextStyle(color: Color(0xFF69F0AE))),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
              onPressed: () async {
                if (amountController.text.isNotEmpty) {
                  int addAmount = int.parse(amountController.text);
                  var query = await FirebaseFirestore.instance.collection('users').where('rfid', isEqualTo: widget.userRfid).get();
                  if (query.docs.isNotEmpty) {
                    var docId = query.docs.first.id;
                    int currentBal = query.docs.first.data()['balance'] ?? 0;
                    await FirebaseFirestore.instance.collection('users').doc(docId).update({'balance': currentBal + addAmount});
                    if (mounted) Navigator.pop(context);
                  }
                }
              },
              child: const Text("LOAD", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pinkAccent, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${widget.userName}', 
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'RFID: ${widget.userRfid}', 
                        style: const TextStyle(color: Colors.white70, fontSize: 16)
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications, color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').where('rfid', isEqualTo: widget.userRfid).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const CircularProgressIndicator(color: Colors.pinkAccent);
                }
                var userDoc = snapshot.data!.docs.first;
                int balance = userDoc['balance'] ?? 0;

                return Center(
                  child: Container(
                    height: 280, width: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF222232),
                      boxShadow: [
                         BoxShadow(color: const Color(0xFF69F0AE).withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
                         BoxShadow(color: Colors.pinkAccent.withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
                      ],
                      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF222232), Color(0xFF222232)]),
                      border: Border.all(width: 5, style: BorderStyle.solid),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [Colors.pinkAccent, Color(0xFF69F0AE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF181928)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Available Balance", style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 10),
                              Text("$balance", style: const TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold)),
                              const Text("PTS", style: TextStyle(color: Color(0xFF69F0AE), fontSize: 24, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, shape: const CircleBorder(), padding: const EdgeInsets.all(12)),
                                onPressed: showAddBalanceDialog,
                                child: const Icon(Icons.add, color: Colors.white, size: 30),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// SCREEN 4.2: PROFILE SCREEN
class ProfileScreen extends StatelessWidget {
  final String userName;
  final String userRfid;

  const ProfileScreen({super.key, required this.userName, required this.userRfid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFF2E1C38),
                child: Icon(Icons.person, size: 60, color: Colors.pinkAccent),
              ),
              const SizedBox(height: 20),
              Text(userName, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              Text("RFID: $userRfid", style: const TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 60),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text("Account Settings", style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.help, color: Colors.white),
                title: const Text("Help & Support", style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text("LOGOUT", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  const PlaceholderScreen({super.key, required this.title, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.pinkAccent),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 24)),
          const Text("Coming Soon", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isNumber;
  const MyTextField({super.key, required this.controller, required this.label, this.isNumber = false});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(labelText: label),
    );
  }
}