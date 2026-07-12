import 'dart:io';
import 'package:betwise/data/remote/football_api/football_api_client.dart';
import 'package:flutter/material.dart';
import 'package:betwise/core/constants/api_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file
  try {
    if (await File('.env').exists()) {
      await dotenv.load(fileName: '.env');
      print('Loaded .env successfully');
      print('API URL: ${ApiConstants.footballBaseUrl}');
      print('API Key: ${ApiConstants.footballApiKey.substring(0, 8)}...');
    } else {
      print('.env file not found');
    }
  } catch (e) {
    print('Error loading .env: $e');
  }

  try {
    final client = FootballApiClient();
    final matches = await client.fetchMatches();
    print('Success! Fetched ${matches.length} matches.');
    for (var i = 0; i < matches.length && i < 5; i++) {
      print('Match $i: ${matches[i].homeTeam} vs ${matches[i].awayTeam} (${matches[i].status.name})');
    }
  } catch (e, stack) {
    print('Failed with error: $e');
    print(stack);
  }
}
