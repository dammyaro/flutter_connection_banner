import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_connection_banner/src/detection/connection_detector.dart';
import 'package:flutter_connection_banner/src/models/connection_status.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ConnectionDetector', () {
    late MockConnectivity mockConnectivity;

    setUp(() {
      mockConnectivity = MockConnectivity();
    });

    test('checkConnection returns isConnected false when connectivity is none', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      final connectionDetector = ConnectionDetector(connectivity: mockConnectivity);
      final status = await connectionDetector.checkConnection();
      expect(status.isConnected, false);
    });
  });
}