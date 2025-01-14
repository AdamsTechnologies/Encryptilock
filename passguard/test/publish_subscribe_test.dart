import 'package:flutter_test/flutter_test.dart';
import 'package:passguard/backend/pubSub/publish_subscribe.dart';

void main() {
  group('PubSub MultipleCallbackException Test', () {
    test('Publishes to multiple callbacks that throw, collects all errors', () {
      final pubSub = PubSub();

      // First callback throws "error 1"
      pubSub.subscribe('throwTopic', (args, kwargs) {
        throw Exception('error 1');
      });

      // Second callback throws "error 2"
      pubSub.subscribe('throwTopic', (args, kwargs) {
        throw Exception('error 2');
      });

      // We expect a MultipleCallbackException with both exceptions aggregated
      try {
        pubSub.publish('throwTopic');
        fail('Expected a MultipleCallbackException but no exception was thrown.');
      } catch (e) {
        // Ensure the type is correct
        expect(e, isA<MultipleCallbackException>());

        final multiple = e as MultipleCallbackException;
        // We should have 2 causes in this scenario
        expect(multiple.causes.length, 2);

        // Check each cause's message
        expect(multiple.causes[0].toString(), contains('error 1'));
        expect(multiple.causes[1].toString(), contains('error 2'));
      }
    });
  });
  group('PubSub Tests', () {
    late PubSub pubSub;

    setUp(() {
      pubSub = PubSub();
    });

    test('Subscribes and publishes events', () {
      String? result;
      pubSub.subscribe('testTopic', (args, kwargs) {
        result = '${args[0]} - ${kwargs['key']}';
      });

      pubSub.publish('testTopic', args: ['Event'], kwargs: {'key': 'Value'});

      expect(result, 'Event - Value');
    });

    test('Handles multiple subscribers', () {
      final results = <String>[];

      pubSub.subscribe('testTopic', (args, kwargs) {
        results.add('Subscriber 1');
      });

      pubSub.subscribe('testTopic', (args, kwargs) {
        results.add('Subscriber 2');
      });

      pubSub.publish('testTopic');
      expect(results, ['Subscriber 1', 'Subscriber 2']);
    });

    test('Unsubscribes a specific callback', () {
      final callback = (args, kwargs) => print('This should not be called');
      pubSub.subscribe('testTopic', callback);
      pubSub.unsubscribe('testTopic', callback);

      expect(pubSub.subscriberCount('testTopic'), 0);
    });

    test('Clears subscribers for a topic', () {
      pubSub.subscribe('testTopic', (args, kwargs) {});
      pubSub.clearSubscribers('testTopic');

      expect(pubSub.subscriberCount('testTopic'), 0);
    });

    test('Clears all subscribers', () {
      pubSub.subscribe('topic1', (args, kwargs) {});
      pubSub.subscribe('topic2', (args, kwargs) {});
      pubSub.clearAllSubscribers();

      expect(pubSub.subscriberCount('topic1'), 0);
      expect(pubSub.subscriberCount('topic2'), 0);
    });

    test('Publishes to an unsubscribed topic does nothing', () {
      expect(() => pubSub.publish('unknownTopic'), returnsNormally);
    });
  });
}
