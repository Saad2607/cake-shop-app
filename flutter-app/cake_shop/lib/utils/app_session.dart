/// Tracks whether the app has finished its cold-start splash in this process.
/// Resets when the app is fully killed — splash shows again on next launch.
/// Stays true when the app only goes to background and is resumed.
class AppSession {
  static bool coldStartComplete = false;

  static void markColdStartComplete() {
    coldStartComplete = true;
  }
}
