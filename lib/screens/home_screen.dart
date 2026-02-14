import 'package:brain_note/colors.dart';
import 'package:brain_note/models/user_model.dart';
import 'package:brain_note/repostiory/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserModel? user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add, color: kBlackColor),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.logout, color: kBlackColor),
          ),
        ],
      ),

      body: user == null
          ? const Center(
              child: Text('Not logged in 😕', style: TextStyle(fontSize: 18)),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Avatar
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: NetworkImage(user.profileUrl),
                    ),

                    const SizedBox(height: 20),

                    /// Name
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// Email
                    Text(
                      user.email,
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 30),

                    /// Logout button
                    ElevatedButton(
                      onPressed: () async {
                        final repo = ref.read(authRepositoryProvider);

                        await repo.signOut();

                        ref.read(userProvider.notifier).clear();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Logged out')),
                          );
                        }
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
