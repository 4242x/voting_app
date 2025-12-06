import 'package:flutter/material.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  final VotingService _votingService = VotingService();
  List<Map<String, dynamic>> _candidates = [];
  bool _isLoading = false;
  
  final String _privateKey = "YOUR_PRIVATE_KEY_HERE";

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    setState(() => _isLoading = true);
    
    try {
      final candidates = await _votingService.getCandidates();
      setState(() {
        _candidates = candidates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load candidates: $e');
    }
  }

  Future<void> _vote(int index) async {
    setState(() => _isLoading = true);

    try {
      final txHash = await _votingService.castVote(
        candidateIndex: index,
        privateKey: _privateKey,
      );

      _showSuccess('Vote cast successfully! TX: ${txHash.substring(0, 10)}...');
      
      await _loadCandidates();
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to cast vote: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _votingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blockchain Voting'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCandidates,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _candidates.isEmpty
              ? const Center(child: Text('No candidates found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _candidates.length,
                  itemBuilder: (context, index) {
                    final candidate = _candidates[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          candidate['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Votes: ${candidate['voteCount']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => _vote(index),
                          child: const Text('Vote'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}