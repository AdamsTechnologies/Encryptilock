typedef PubSubCallback = void Function(List<dynamic> args, Map<String, dynamic> kwargs);

class PubSub {
  final Map<String, List<PubSubCallback>> _subscribers = {};

  /// Subscribes to a given topic with a callback.
  void subscribe(String topic, PubSubCallback callback) {
    _subscribers.putIfAbsent(topic, () => []).add(callback);
  }

  /// Publishes an event to a topic, notifying all subscribers.
  /// [args] is a list of positional arguments passed to the callbacks.
  /// [kwargs] is a map of named arguments passed to the callbacks.
  void publish(String topic, {List<dynamic>? args, Map<String, dynamic>? kwargs}) {
    final errors = <Exception>[];
    if (_subscribers.containsKey(topic)) {
      for (final callback in _subscribers[topic]!) {
        try{
          callback(args ?? [], kwargs ?? {});
        } catch (e) {
          errors.add(e is Exception ? e : Exception(e.toString()));
        }
      }
    }
    if (errors.isNotEmpty) {
      throw MultipleCallbackException(errors);
    }
  }
  
  /// Unsubscribes a specific callback from a topic.
  bool unsubscribe(String topic, PubSubCallback callback) {
    if (_subscribers.containsKey(topic)) {
      return _subscribers[topic]!.remove(callback);
    }
    return false;
  }

  /// Clears all subscribers for a specific topic.
  void clearSubscribers(String topic) {
    _subscribers.remove(topic);
  }

  /// Clears all subscribers for all topics.
  void clearAllSubscribers() {
    _subscribers.clear();
  }

  /// Checks if there are any subscribers for a topic.
  bool hasSubscribers(String topic) {
    return _subscribers.containsKey(topic) && _subscribers[topic]!.isNotEmpty;
  }

  /// Gets the number of subscribers for a specific topic.
  int subscriberCount(String topic) {
    return _subscribers[topic]?.length ?? 0;
  }
}


class MultipleCallbackException implements Exception {
  final List<Exception> causes;
  MultipleCallbackException(this.causes);

  @override
  String toString() => 'MultipleCallbackException: $causes';
}