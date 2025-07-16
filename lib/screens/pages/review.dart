import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//submit reviews for the clinics visited
class ReviewPage extends StatefulWidget {
  final String clinicId;
  final String clinicName;

  const ReviewPage({Key? key, required this.clinicId, required this.clinicName})
    : super(key: key);

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    if (_formKey.currentState!.validate()) {
      final reviewText = _reviewController.text;
      final rating = _rating;
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to submit a review'),
          ),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('reviews').add({
          'userId': user.uid,
          'email': user.email,
          'rating': rating,
          'comment': reviewText,
          'clinicId': widget.clinicId,
          'clinicName': widget.clinicName,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Review submitted!')));

        setState(() {
          _rating = 0;
        });
        _reviewController.clear();
      } catch (e) {
        print('Error submitting review: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit review.')),
        );
      }
    }
  }

  Widget _buildStar(int index) {
    return IconButton(
      icon: Icon(
        index <= _rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
      ),
      onPressed: () {
        setState(() {
          _rating = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Review')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Rate your experience',
                style: TextStyle(fontSize: 18),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => _buildStar(index + 1)),
              ),
              TextFormField(
                controller: _reviewController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Write your review',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter a review'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _rating == 0 ? null : _submitReview,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
