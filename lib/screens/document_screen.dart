import 'package:brain_note/colors.dart';
import 'package:brain_note/models/document_model.dart';
import 'package:brain_note/models/error_model.dart';
import 'package:brain_note/repostiory/document_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  const DocumentScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  final TextEditingController _controller = TextEditingController(
    text: "Untitled Document",
  );
  final quill.QuillController _quillController = quill.QuillController.basic();
  late ErrorModel _errorModel;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void getDocument() async {
    final repo = ref.read(docsRepositoryProvider);
    final result = await repo.getDocument(widget.id);
    if (result.data != null) {
      _errorModel = result;
    }
  }

  void updateTitle(String title) async {
    final result = await ref
        .read(docsRepositoryProvider)
        .updateTitle(widget.id, title);
    if (result.data != null) {
      _errorModel = result.data;
      _controller.text = _errorModel.data.title;
      setState(() {

      });
    }
  }

  @override
  void initState() {
    super.initState();
    getDocument();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            spacing: 10,
            children: [
              Image.asset('assets/images/docs-logo.png', height: 40),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (value) => updateTitle(value),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    // focusedBorder: OutlineInputBorder(
                    //   borderSide: BorderSide(
                    //     color: kBlueColor,
                    //
                    //   )
                    //
                    // ),
                    contentPadding: EdgeInsets.only(left: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              height: 42,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'http://localhost:3000/#/document/${widget.id}',
                    ),
                  ).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied!')),
                    );
                  });
                },
                icon: const Icon(Icons.lock, size: 18, color: kWhiteColor),
                label: const Text(
                  'Share',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kWhiteColor,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlueColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: kBlueColor, width: .1),
            ),
          ),
        ),
      ),
      backgroundColor: kWhiteColor,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 10),
            quill.QuillSimpleToolbar(
              controller: _quillController,
              config: const quill.QuillSimpleToolbarConfig(),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SizedBox(
                width: 750,
                child: Card(
                  color: kWhiteColor,
                  elevation: 5,
                  child: quill.QuillEditor.basic(
                    controller: _quillController,
                    config: const quill.QuillEditorConfig(
                      padding: EdgeInsetsGeometry.all(30),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
