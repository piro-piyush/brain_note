import 'dart:async';
import 'package:brain_note/colors.dart';
import 'package:brain_note/models/document_model.dart';
import 'package:brain_note/repostiory/auth_repository.dart';
import 'package:brain_note/repostiory/document_repository.dart';
import 'package:brain_note/repostiory/socket_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;

  const DocumentScreen({super.key, required this.id});

  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  final TextEditingController titleController = TextEditingController(
    text: 'Untitled Document',
  );

  quill.QuillController? _controller;

  late FocusNode _focusNode;
  late ScrollController _scrollController;
  late Timer _autoSaveTimer;

  final SocketRepository socketRepository = SocketRepository();

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _scrollController = ScrollController();

    socketRepository.joinRoom(widget.id);

    fetchDocumentData();

    socketRepository.changeListener((data) {
      if (_controller == null) return;
      final delta = Delta.fromJson(data['delta']);
      _controller!.compose(
        delta,
        _controller!.selection,
        quill.ChangeSource.remote,
      );
    });

    _autoSaveTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_controller == null) return;

      socketRepository.autoSave({
        'delta': _controller!.document.toDelta(),
        'room': widget.id,
      });
    });
  }

  Future<void> fetchDocumentData() async {
    final errorModel = await ref
        .read(docsRepositoryProvider)
        .getDocument(widget.id);

    if (errorModel.data != null) {
      final document = errorModel.data as DocumentModel;

      titleController.text = document.title;

      final quillDocument = document.content.isEmpty
          ? quill.Document()
          : quill.Document.fromDelta(Delta.fromJson(document.content));

      _controller = quill.QuillController(
        document: quillDocument,
        selection: const TextSelection.collapsed(offset: 0),
      );

      setState(() {});

      /// 🔥 LISTEN ONLY AFTER CONTROLLER IS CREATED
      _controller!.document.changes.listen((change) {
        if (change.source == quill.ChangeSource.local) {
          socketRepository.typing({
            'delta': change.change.toJson(),
            'room': widget.id,
          });
        }
      });
    }
  }

  void updateTitle(String title) {
    final user = ref.read(userProvider);

    if (user == null) return;

    ref.read(docsRepositoryProvider).updateTitle(widget.id, title);
  }

  @override
  void dispose() {
    _autoSaveTimer.cancel();
    _focusNode.dispose();
    _scrollController.dispose();
    _controller?.dispose();
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xffF1F3F4),
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Routemaster.of(context).replace('/');
              },
              child: Image.asset('assets/images/docs-logo.png', height: 36),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 200,
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                onSubmitted: updateTitle,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'http://localhost:3000/#/document/${widget.id}',
                    ),
                  );

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Link copied!')));
                },
                icon: const Icon(Icons.lock, size: 18, color: kWhiteColor),
                label: const Text(
                  'Share',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: kWhiteColor,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlueColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 0.5),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          quill.QuillSimpleToolbar(
            controller: _controller!,
            config: const quill.QuillSimpleToolbarConfig(),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 750,
                child: Card(
                  elevation: 3,
                  color: kWhiteColor,
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: quill.QuillEditor(
                      controller: _controller!,
                      focusNode: _focusNode,
                      scrollController: _scrollController,
                      config: quill.QuillEditorConfig(
                        expands: true,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
