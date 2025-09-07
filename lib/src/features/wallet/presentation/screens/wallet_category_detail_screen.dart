import 'package:flutter/material.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/wallet/presentation/screens/boost_screen.dart';

class WalletCategoryDetailScreen extends StatelessWidget {
  final Category category;
  const WalletCategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${category.name} Wallet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.rocket_launch_outlined),
              label: const Text('Boost Wallet'),
              onPressed: () {
                // V-- Update the navigation logic to push the new screen
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => BoostScreen(toCategory: category),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}