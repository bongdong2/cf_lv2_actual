import 'dart:io';

const ACCESS_TOKEN_KEY = "ACCESS_TOKEN";
const REFRESH_TOKEN_KEY = "REFRESH_TOKEN";

final emulatorIp = '10.0.2.2:3000';
final simulatorIp = '127.0.0.1:3000';
final ip = Platform.isIOS == true ? simulatorIp : emulatorIp;