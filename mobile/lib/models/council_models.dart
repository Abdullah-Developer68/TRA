import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The free models that answer each question. Mirrors the backend council.
class CouncilModelInfo {
  final String name;
  final String provider;
  final Color color;

  const CouncilModelInfo(this.name, this.provider, this.color);
}

const List<CouncilModelInfo> councilModels = [
  CouncilModelInfo('Nemotron 3.5 Lightning', 'Nvidia', AppTheme.info),
  CouncilModelInfo('Cohere North Mini', 'Cohere', AppTheme.success),
  CouncilModelInfo('Nemotron Ultra', 'Nvidia', AppTheme.warning),
];

const List<(IconData, String)> examplePrompts = [
  (
    Icons.hub_outlined,
    'Compare Raft vs Paxos consensus with network partition edge cases',
  ),
  (
    Icons.code_rounded,
    'Design a concurrency-safe LRU Cache with O(1) ops in TypeScript',
  ),
  (
    Icons.public_rounded,
    'Explain the difference between TCP and UDP with a real-world scenario',
  ),
  (
    Icons.shield_outlined,
    'Analyze JWT vs Session Cookie architectures for security and revocation',
  ),
];
