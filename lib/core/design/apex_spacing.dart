abstract final class ApexSpacing {
  static const double x1 = 8;
  static const double x2 = 16;
  static const double x3 = 24;
  static const double x4 = 32;
  static const double x5 = 40;
  static const double radius = 16;

  /// Bottom clearance for scrollable content on screens shown under
  /// [ApexAppShell]'s floating nav bar (56 height + 16 bottom margin,
  /// rounded up with breathing room) — the bar floats via `Positioned` in
  /// a `Stack` rather than reserving layout space, so a plain small bottom
  /// padding lets the last card/row sit behind it.
  static const double navBarClearance = 88;
}
