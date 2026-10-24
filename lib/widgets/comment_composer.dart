import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

/// A field to write a comment in, with a button to send it. [onSend] tells
/// whether the comment was saved; the field is only cleared when it was.
class CommentComposer extends StatefulWidget {
  const CommentComposer({
    super.key,
    required this.hint,
    required this.onSend,
    this.autofocus = false,
  });

  final String hint;
  final Future<bool> Function(String text) onSend;
  final bool autofocus;

  @override
  State<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<CommentComposer> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    final sent = await widget.onSend(_controller.text.trim());
    if (!mounted) return;
    setState(() => _sending = false);
    if (sent) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 8,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            autofocus: widget.autofocus,
            enabled: !_sending,
            minLines: 1,
            maxLines: 6,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: widget.hint,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: _controller,
          builder: (context, value, _) => IconButton.filled(
            tooltip: context.l10n.send,
            onPressed: _sending || value.text.trim().isEmpty ? null : _send,
            icon: _sending
                ? const SizedBox.square(
                    dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send),
          ),
        ),
      ],
    );
  }
}
