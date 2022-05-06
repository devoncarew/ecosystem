class YamlPrinter {
  const YamlPrinter();

  String print(Map<String, dynamic> data) {
    StringBuffer buffer = StringBuffer();
    _print('', data, buffer);
    return buffer.toString().trim();
  }

  void _print(String indent, Object data, StringBuffer buffer) {
    if (data is Map) {
      for (var key in data.keys) {
        Object? value = data[key];
        if (value is Map) {
          buffer.writeln();
          buffer.writeln('$indent$key:');
          _print('$indent  ', value, buffer);
        } else if (value is List) {
          buffer.writeln('$indent$key:');
          _print('$indent  ', value, buffer);
        } else {
          buffer.writeln('$indent$key: $value');
        }
      }
    } else if (data is List) {
      for (var item in data) {
        if (item is Map) {
          buffer.writeln('$indent-');
          _print('$indent  ', item, buffer);
        } else if (item is List) {
          throw 'unhandled - list in list';
        } else {
          buffer.writeln('$indent- $item');
        }
      }
    } else {
      buffer.writeln('$indent$data');
    }
  }
}

String relativeDateInDays({
  required DateTime dateUtc,
  bool short = false,
}) {
  final now = DateTime.now().toUtc();
  final hourToday = DateTime.now().hour;
  final dateText = '${dateUtc.year}-'
      '${dateUtc.month.toString().padLeft(2, '0')}-'
      '${dateUtc.day.toString().padLeft(2, '0')}';

  var hoursDiff = now.difference(dateUtc).inHours;

  // today
  if (hoursDiff <= hourToday) {
    return short ? 'today' : 'today ($dateText)';
  }

  // yesterday
  if (hoursDiff <= (hourToday + 24)) {
    return short ? 'yesterday' : 'yesterday ($dateText)';
  }

  // n days ago
  var days = (hoursDiff / 24.0).round();
  return short ? '$days days' : '$days days ago ($dateText)';
}