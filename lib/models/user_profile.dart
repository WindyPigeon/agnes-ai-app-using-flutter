// Copyright 2026 Evan Li Zhen Feng. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class UserProfile {
  UserProfile({
    this.username = '',
    this.email = '',
    this.phone = '',
    this.nickname = '',
    this.occupation = '',
    this.about = '',
    this.customInstructions = '',
  });

  String username;
  String email;
  String phone;
  String nickname;
  String occupation;
  String about;
  String customInstructions;

  bool get hasPersonalization =>
      nickname.isNotEmpty ||
      occupation.isNotEmpty ||
      about.isNotEmpty ||
      customInstructions.isNotEmpty;

  /// Built from the personalization fields, prepended as a system message
  /// on every chat request so Personalization has a real effect on replies.
  String buildSystemPrompt() {
    final parts = <String>[];
    if (nickname.isNotEmpty) parts.add('The user\'s preferred name is $nickname.');
    if (occupation.isNotEmpty) parts.add('The user works as: $occupation.');
    if (about.isNotEmpty) parts.add('About the user: $about');
    if (customInstructions.isNotEmpty) {
      parts.add('Custom instructions from the user: $customInstructions');
    }
    return parts.join(' ');
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'phone': phone,
        'nickname': nickname,
        'occupation': occupation,
        'about': about,
        'customInstructions': customInstructions,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        username: json['username'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        nickname: json['nickname'] as String? ?? '',
        occupation: json['occupation'] as String? ?? '',
        about: json['about'] as String? ?? '',
        customInstructions: json['customInstructions'] as String? ?? '',
      );
}
