class AttendanceState {
  final List<DateTime> sessions;

  // sessionKey -> set of present usernames
  final Map<String, Set<String>> _presentBySessionKey;

  AttendanceState._(this.sessions, this._presentBySessionKey);

  static AttendanceState bootstrap({
    required List<String> studentUsernames,
    required List<DateTime> sessions,
  }) {
    final map = <String, Set<String>>{};
    for (final s in sessions) {
      // mock: mặc định 80% có mặt
      final present = <String>{};
      for (var i = 0; i < studentUsernames.length; i++) {
        if (i % 5 != 0) present.add(studentUsernames[i]);
      }
      map[_key(s)] = present;
    }
    return AttendanceState._([...sessions], map);
  }

  void addSession(DateTime d) {
    sessions.insert(0, d);
    _presentBySessionKey[_key(d)] = <String>{};
  }

  Set<String> presentSet(DateTime session) {
    return _presentBySessionKey[_key(session)] ?? <String>{};
  }

  void setPresentForSession(DateTime session, Set<String> presentUsernames) {
    _presentBySessionKey[_key(session)] = {...presentUsernames};
  }

  double percentFor(String username) {
    if (sessions.isEmpty) return 0;
    var presentCount = 0;
    for (final s in sessions) {
      if (presentSet(s).contains(username)) presentCount++;
    }
    return presentCount / sessions.length;
  }

  static String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}-${d.hour.toString().padLeft(2, '0')}-${d.minute.toString().padLeft(2, '0')}';
}
