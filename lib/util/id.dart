// Copyright 2026 Evan Li Zhen Feng. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:math';

final _rand = Random();

/// Lightweight unique id, avoids pulling in the `uuid` package.
String generateId() {
  final now = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final salt = _rand.nextInt(1 << 32).toRadixString(36);
  return '$now$salt';
}
