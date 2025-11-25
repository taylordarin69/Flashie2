import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const FlashieApp());

class FlashieApp extends StatelessWidget {
  const FlashieApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: "Flashie",
    theme: ThemeData.dark(),
    home: const FlashieHome(),
  );
}

class FlashieHome extends StatefulWidget {
  const FlashieHome({super.key});
  @override State<FlashieHome> createState() => _FlashieHomeState();
}

class _FlashieHomeState extends State<FlashieHome> {
  String backend = "https://YOUR_BACKEND_URL";
  String log = "";
  bool busy = false;

  final initiator = TextEditingController();
  final amount = TextEditingController(text:"0.1");

  void add(String msg){
    setState(()=>log = msg + "\n" + log);
  }

  Future status() async {
    setState(()=>busy=true);
    try {
      final r = await http.get(Uri.parse("$backend/status"));
      add("STATUS: ${r.body}");
    } catch(e){ add("ERR: $e"); }
    setState(()=>busy=false);
  }

  Future start() async {
    if(initiator.text.isEmpty){ add("Enter wallet"); return; }
    setState(()=>busy=true);
    try {
      final r = await http.post(
        Uri.parse("$backend/start"),
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "initiator": initiator.text,
          "amount": amount.text
        })
      );
      add("START: ${r.body}");
    } catch(e){ add("ERR: $e"); }
    setState(()=>busy=false);
  }

  @override
  Widget build(_) => Scaffold(
    appBar: AppBar(title: const Text("Flashie")),
    body: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(controller: initiator, decoration: const InputDecoration(labelText:"Initiator Wallet")),
          TextField(controller: amount, decoration: const InputDecoration(labelText:"Loan Amount (ETH)")),
          Row(children:[
            Expanded(child: ElevatedButton(onPressed: busy?null:status, child: const Text("Status"))),
            const SizedBox(width:10),
            Expanded(child: ElevatedButton(onPressed: busy?null:start, child: const Text("Start Flash")))
          ]),
          const SizedBox(height:10),
          Expanded(child: SingleChildScrollView(child: Text(log)))
        ],
      ),
    ),
  );
}
