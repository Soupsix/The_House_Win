class GameSessionConfig {
  final Duration openDuration;
  final Duration lockBuffer;
  final bool isMultiPlayer;
  const GameSessionConfig({
    required this.openDuration,
    required this.lockBuffer,
    required this.isMultiPlayer,
  });
}

class GameSessionConfigs {
  static const dice = GameSessionConfig(
    openDuration: Duration(seconds: 60),
    lockBuffer: Duration(seconds: 12),
    isMultiPlayer: true,
  );
  static const spinSlot = GameSessionConfig(
    openDuration: Duration.zero,
    lockBuffer: Duration.zero,
    isMultiPlayer: false,
  );
}
