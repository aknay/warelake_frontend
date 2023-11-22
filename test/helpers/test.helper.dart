
  import 'dart:math';

final random = Random();

  String generateRandomEmail() {
    const String domain = 'example.com'; // Change to your desired email domain
    const String characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    const int length = 10; // Length of the random part of the email

    String randomEmail = '';

    for (int i = 0; i < length; i++) {
      randomEmail += characters[random.nextInt(characters.length)];
    }

    return '$randomEmail@$domain';
  }