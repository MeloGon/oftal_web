import 'dart:math';

BigInt generateRandomId(int length) {
  final random = Random.secure();
  final buffer = StringBuffer();
  buffer.write(random.nextInt(9) + 1);
  for (var i = 1; i < length; i++) {
    buffer.write(random.nextInt(10));
  }
  return BigInt.parse(buffer.toString());
}
