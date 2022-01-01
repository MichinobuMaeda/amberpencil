import 'service_listener.dart';

abstract class ServiceProvider<Type> {
  final List<ServiceListener> _listeners = [];
  Type _data;

  ServiceProvider(Type data) : _data = data;

  void notify(Type data) {
    _data = data;
    for (var listener in _listeners) {
      listener.notify(_data);
    }
  }

  void registerListener(ServiceListener listener) {
    _listeners.add(listener);
    listener.notify(_data);
  }

  void unregisterListener(ServiceListener listener) {
    _listeners.removeWhere((element) => identical(element, listener));
  }

  Type get data => _data;
}
