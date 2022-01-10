import 'service_listener.dart';

abstract class ServiceProvider<Type> {
  final String key;
  final List<ServiceListener> _listeners = [];
  Type? _data;

  ServiceProvider(this.key);

  void update(Type? data) {
    _data = data;
    for (var listener in _listeners) {
      listener.notify(key, _data);
    }
  }

  void registerListener(ServiceListener listener) {
    _listeners.add(listener);
    listener.notify(key, _data);
  }

  void unregisterListener(ServiceListener listener) {
    _listeners.removeWhere((element) => identical(element, listener));
  }

  Type? get data => _data;
}
