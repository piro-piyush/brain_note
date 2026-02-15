import 'package:brain_note/colors.dart';
import 'package:brain_note/common/widgets/loader_widget.dart';
import 'package:brain_note/models/document_model.dart';
import 'package:brain_note/repostiory/auth_repository.dart';
import 'package:brain_note/repostiory/document_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late Future<List<DocumentModel>> _docsFuture;

  @override
  void initState() {
    super.initState();
    _docsFuture = _fetchDocs();
  }

  Future<List<DocumentModel>> _fetchDocs() async {
    final repo = ref.read(docsRepositoryProvider);
    final result = await repo.getAllMyDocuments();

    if (result.data != null) {
      return result.data as List<DocumentModel>;
    } else {
      throw Exception(result.error);
    }
  }

  void signOut(WidgetRef ref, BuildContext context) async {
    final repo = ref.read(authRepositoryProvider);

    await repo.signOut();
    ref.read(userProvider.notifier).clear();

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logged out')));
    }
  }

  void createDoc(WidgetRef ref, BuildContext context) async {
    final repo = ref.read(docsRepositoryProvider);
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context);

    final result = await repo.createDocument();

    if (result.data != null) {
      navigator.push('/document/${result.data.id}');
    } else {
      snackbar.showSnackBar(SnackBar(content: Text(result.error!)));
    }
  }

  void navigateToDocument(String id, BuildContext context) async {
    Routemaster.of(context).push('/document/$id');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => createDoc(ref, context),
            icon: const Icon(Icons.add, color: kBlackColor),
          ),
          IconButton(
            onPressed: () => signOut(ref, context),
            icon: const Icon(Icons.logout, color: kRedColor),
          ),
        ],
      ),
      body: user == null
          ? const Center(
              child: Text('Not logged in 😕', style: TextStyle(fontSize: 18)),
            )
          : FutureBuilder<List<DocumentModel>>(
              future: _docsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoaderWidget();
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final docs = snapshot.data ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No documents yet 📄',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = docs[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => navigateToDocument(doc.id, context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // 📄 Icon Container
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.description_rounded,
                                color: Colors.blue,
                              ),
                            ),

                            const SizedBox(width: 16),

                            // 📌 Title + Date
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    doc.createdAt.toLocal().toString().split(
                                      '.',
                                    )[0],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
