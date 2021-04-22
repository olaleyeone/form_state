import 'dart:async';

import './validator.dart';
import './form_control_state.dart';

class FormControl<T> {
  Validator<T> _validator;
  FormControlState<T> _state;
  T _value;
  StreamController<FormControlState<T>> _stream;

  FormControl({
    T value,
    Validator<T> validator,
  }) {
    _value = value;
    _stream = StreamController<FormControlState<T>>.broadcast();
    if (validator != null) {
      _validator = validator;
      _validator(value).then(
        (error) {
          _state = FormControlState(
            value: value,
            error: error,
          );
          _stream.sink.add(_state);
        },
      );
    } else {
      _state = FormControlState(value: value);
      _stream.sink.add(_state);
    }
  }

  Future<FormControlState<T>> setValue(T value) {
    _value = value;
    FormControlState<T> state = _state;
    if (_validator != null) {
      _stream.sink.add(null);
      return _validator(value).then(
        (error) {
          if (_state != state) {
            return _state;
          }
          _state = FormControlState(
            value: value,
            visited: state.visited,
            error: error,
          );
          _stream.sink.add(_state);
          return _state;
        },
      );
    } else {
      _state = FormControlState(
        value: value,
        visited: state.visited,
      );
      _stream.sink.add(_state);
    }
    return Future.value(_state);
  }

  setInFocus(bool focus) {
    if (focus) {
      return;
    }
    _markAsVisited();
  }

  _markAsVisited() {
    _state = FormControlState(
      value: _state.value,
      visited: true,
      error: _state.error,
    );
    _stream.sink.add(_state);
  }

  T get value => _value;

  close() {
    _stream.close();
  }

  FormControlState<T> get state => _state;

  Stream<FormControlState<T>> get stateStream => _stream.stream;
}