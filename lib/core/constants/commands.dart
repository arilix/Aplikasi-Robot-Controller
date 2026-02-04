class RobotCommands {
  // Movement commands
  static const String maju = 'MAJU';
  static const String mundur = 'MUNDUR';
  static const String kiri = 'KIRI';
  static const String kanan = 'KANAN';
  static const String majuKiri = 'MAJU_KIRI';
  static const String majuKanan = 'MAJU_KANAN';
  static const String mundurKiri = 'MUNDUR_KIRI';
  static const String mundurKanan = 'MUNDUR_KANAN';
  static const String stop = 'STOP';

  // Speed commands
  static const String speedNormal = 'SPEED_NORMAL';
  static const String speedFast = 'SPEED_FAST';
  static const String boostOn = 'BOOST_ON';
  static const String boostOff = 'BOOST_OFF';

  // Special commands
  static const String kick = 'KICK';
  static const String ping = 'PING';

  // Pro mode
  static String tuning({
    required int pwmMax,
    required int frequency,
    required int speedNormal,
    required int speedFast,
    required int failsafeTimeout,
  }) {
    return 'TUNING:$pwmMax,$frequency,$speedNormal,$speedFast,$failsafeTimeout';
  }
}
