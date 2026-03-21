/// Placeholder for HTTP interceptors.
///
/// In this project we use a simple ApiClient, and the interceptor layer is
/// represented by the client itself. This file exists to hold any future
/// request/response interception logic (e.g. retry, token refresh, logging).

class ApiInterceptors {
  /// Called before each request is sent.
  static void onRequest(String method, String url, Map<String, dynamic>? body) {
    // TODO: Add logging or request transformation here.
  }

  /// Called after a response is received.
  static void onResponse(int statusCode, String url, dynamic body) {
    // TODO: Add response logging or analytics here.
  }

  /// Called when an error occurs during the request.
  static void onError(Object error, StackTrace? stackTrace) {
    // TODO: Add error reporting or retry logic here.
  }
}
