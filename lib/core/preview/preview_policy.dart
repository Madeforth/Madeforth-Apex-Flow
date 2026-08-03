abstract final class PreviewPolicy {
  static const browser = 'Google Chrome';
  static const statement =
      'Development preview and manual validation target Google Chrome only.';
  static const excludedTargets = [
    'Safari',
    'Firefox',
    'Edge',
    'Mobile browsers',
  ];
}
