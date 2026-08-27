import 'dart:convert';
import 'dart:io';

import '../../../core/database/app_database.dart';
import 'holdings_repository.dart';

class RatesRepository {
  RatesRepository(this._holdingsRepository);

  final HoldingsRepository _holdingsRepository;

  Future<RateSnapshot> fetchAndSave() async {
    final client = HttpClient();
    try {
      final usdResponse = await _getJson(
        client,
        Uri.parse('https://open.er-api.com/v6/latest/USD'),
      );
      final goldResponse = await _getJson(
        client,
        Uri.parse('https://api.gold-api.com/price/XAU'),
      );

      final usdToEgp = (usdResponse['rates'] as Map?)?['EGP'];
      final goldUsdPerOunce = goldResponse['price'];
      if (usdToEgp is! num || goldUsdPerOunce is! num ||
          usdToEgp <= 0 || goldUsdPerOunce <= 0) {
        throw const FormatException('Incomplete rates response');
      }

      final goldPricePerGram24k =
          goldUsdPerOunce.toDouble() * usdToEgp.toDouble() / 31.1034768;
      await _holdingsRepository.saveRate(
        usdToEgp: usdToEgp.toDouble(),
        goldPricePerGram24k: goldPricePerGram24k,
        source: 'open.er-api.com + gold-api.com',
      );
      return (await _holdingsRepository.getLatestRate())!;
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>> _getJson(HttpClient client, Uri uri) async {
    final request = await client.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final response = await request.close().timeout(const Duration(seconds: 10));
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('Rates request failed: ${response.statusCode}');
    }
    return jsonDecode(await response.transform(utf8.decoder).join())
        as Map<String, dynamic>;
  }
}