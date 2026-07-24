/// A single generated script with hook, body, and call-to-action.
class Script {
  final String hook;
  final String body;
  final String cta;

  const Script({
    required this.hook,
    required this.body,
    required this.cta,
  });

  factory Script.fromJson(Map<String, dynamic> json) {
    return Script(
      hook: json['hook'] as String? ?? '',
      body: json['body'] as String? ?? '',
      cta: json['cta'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'hook': hook,
        'body': body,
        'cta': cta,
      };

  @override
  String toString() => 'Script(hook: ${hook.substring(0, 30)}...)';
}
