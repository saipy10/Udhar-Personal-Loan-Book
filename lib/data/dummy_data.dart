// lib/data/dummy_data.dart

class UdharUser {
  final String name;
  final double amount;
  final bool isGive; // true = you have to pay, false = you have to receive
  final String description;

  const UdharUser({
    required this.name,
    required this.amount,
    required this.isGive,
    required this.description,
  });
}

// A simple hardcoded dummy list
const List<UdharUser> dummyUsers = [
  UdharUser(
    name: 'Person1',
    amount: 500,
    isGive: false,
    description: 'Cab share',
  ),
  
];
