class EnvironmentConfig {
  static const agoraId = String.fromEnvironment(
    'AGORA_ID',
    defaultValue: 'AGORA_ID',
  );
  static const agoraChannelName = String.fromEnvironment(
    'AGORA_CHANNEL_NAME',
    defaultValue: 'test',
  );
  static const agoraToken =
      String.fromEnvironment('AGORA_TOKEN', defaultValue: 'test');
}
