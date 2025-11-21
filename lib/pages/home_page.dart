import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:udhaar/data/dummy_data.dart';
import 'package:udhaar/widgets/add_udhar_dialog.dart';
import 'package:udhaar/widgets/edit_udhar_dialog.dart';
import 'package:udhaar/widgets/udhar_total_box.dart';
import 'package:udhaar/widgets/user_list_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search = '';
  final TextEditingController _searchController = TextEditingController();
  static const String _storageKey = 'udhaar_user_list';
  bool _loading = true;

  // Local mutable list starting from _users
  late List<UdharUser> _users;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) {
        // first run -> use existing dummyUsers
        _users = List<UdharUser>.from(dummyUsers);
        await _saveUsers(); // persist initial data
      } else {
        final List<dynamic> decoded = jsonDecode(raw);
        _users = decoded.map((e) {
          // if e is a map coming from toMap-like structure
          final Map<String, dynamic> m = Map<String, dynamic>.from(e);
          // adapt these field names if your UdharUser uses different names
          return UdharUser(
            name: m['name'] ?? '',
            amount: (m['amount'] is num)
                ? (m['amount'] as num).toDouble()
                : double.tryParse('${m['amount']}') ?? 0.0,
            isGive: m['isGive'] == true,
            description: m['description'] ?? '',
          );
        }).toList();
      }
    } catch (err) {
      // fallback to dummy if anything goes wrong
      _users = List<UdharUser>.from(dummyUsers);
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _users.map((u) {
        // adapt property access if your UdharUser uses different names
        return {
          'name': u.name,
          'amount': u.amount,
          'isGive': u.isGive,
          'description': u.description,
        };
      }).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UdharUser> get _filteredUsers {
    if (_search.trim().isEmpty) return _users;
    final q = _search.toLowerCase();
    return _users.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.description.toLowerCase().contains(q);
    }).toList();
  }

  double get totalToReceive => _users
      .where((u) => u.isGive == false)
      .fold(0.0, (sum, u) => sum + u.amount);

  double get totalToPay => _users
      .where((u) => u.isGive == true)
      .fold(0.0, (sum, u) => sum + u.amount);

  Future<void> _openAddDialog() async {
    await showDialog(
      context: context,
      builder: (ctx) => AddUdharDialog(
        onAdd: (UdharUser newUser) async {
          setState(() {
            _users.insert(0, newUser);
          });
          await _saveUsers();
          Navigator.of(ctx).pop();
        },
        onCancel: () {
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  // User Tile Tap ----> Adjust and Delete
  Future<void> _onUserTileTap(UdharUser user) async {
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Udhar: ${user.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current: ₹ ${user.amount.toStringAsFixed(0)} '
              '(${user.isGive ? "To Pay" : "To Receive"})',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Text("What would you like to do?"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('adjust'),
            child: const Text("Adjust Amount"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop("delete"),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete Udhar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('cancel'),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );

    if (!mounted || action == null || action == 'cancel') return;

    if (action == "delete") {
      await _deleteUdhar(user);
    } else if (action == "adjust") {
      await _adjustUdharAmount(user);
    }
  }

  // Delete Udhar function
  Future<void> _deleteUdhar(UdharUser user) async {
    setState(() {
      _users.remove(user);
    });
    await _saveUsers();
  }

  Future<void> _adjustUdharAmount(UdharUser user) async {
    final result = await showDialog<UdharAdjustmentResult>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => EditUdharDialog(
        title: user.name,
        currentAmount: user.amount,
        isGive: user.isGive,
        initialDescription: user.description,
      ),
    );

    if (result == null) return; // User cancelled

    // Represent current state as signed balance:
    // Positive => should receive; negative => should pay.
    final double currentBalance = user.isGive ? -user.amount : user.amount;

    // Add signed adjustment: + means receive more; - means pay more.
    final double newBalance =
        currentBalance + result.adjustment; // ✅ Use result.adjustment

    final bool finalIsGive = newBalance < 0;
    final double finalAmount = newBalance.abs();

    // Replace in list
    final index = _users.indexOf(user);
    if (index == -1) return;

    setState(() {
      _users[index] = UdharUser(
        name: user.name,
        amount: finalAmount,
        isGive: finalIsGive,
        description: result.description,
      );
    });
    await _saveUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Udhaar"),
        elevation: 1,
        shadowColor: Colors.black45,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12), // FIXED
          child: Column(
            children: [
              // Search Bar Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _search = value;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: 'Search',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),

                          // Search icon
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: null,
                            tooltip: 'Search',
                          ),

                          // Add icon
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_rounded,
                              size: 28,
                              color: Colors.purple,
                            ),
                            onPressed: _openAddDialog,
                            tooltip: 'Add Udhar',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Totals Section
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: UdharTotalBox(
                      title: "Total To Pay",
                      amount: totalToPay,
                      isReceive: false,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: UdharTotalBox(
                      title: "Total To Receive",
                      amount: totalToReceive,
                      isReceive: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              // LIST OF USERS
              Expanded(
                child: _filteredUsers.isEmpty
                    ? const Center(child: Text("No Udhaar Found"))
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return UserListTile(
                            name: user.name,
                            amount: user.amount,
                            isGive: user.isGive,
                            description: user.description,
                            onTap: () => _onUserTileTap(user),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
