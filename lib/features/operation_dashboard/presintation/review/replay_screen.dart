import 'package:flutter/material.dart';
import 'package:disctop_app/core/api_service.dart';

class ReplyScreen extends StatefulWidget {
  final String reviewId;
  final void Function(String reply)? onReplySent;

  const ReplyScreen({Key? key, required this.reviewId, this.onReplySent}) : super(key: key);

  @override
  State<ReplyScreen> createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رد على التقييم'),
        backgroundColor: const Color(0xFF5C8D4E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('اكتب ردك للمستخدم:'),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'اكتب ردك هنا...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSending ? null : _sendReply,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5C8D4E)),
              child: _isSending ? const CircularProgressIndicator(color: Colors.white) : const Text('إرسال الرد'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendReply() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء كتابة الرد أولاً')));
      return;
    }

    setState(() => _isSending = true);

    try {
      await _apiService.replyToReview(widget.reviewId, text); // new ApiService method
      setState(() => _isSending = false);

      widget.onReplySent?.call(text);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الإرسال: ${e.toString()}')));
      }
    }
  }
}
