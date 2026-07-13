import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;

  final segments = [
    {
      'id': 'seg_x0',
      'multiplier': 0.0,
      'probability': 0.349,
      'label': 'x0',
      'colorHex': '#757575', // Grey
    },
    {
      'id': 'seg_x0_5',
      'multiplier': 0.5,
      'probability': 0.20,
      'label': 'x0.5',
      'colorHex': '#E57373', // Light Red
    },
    {
      'id': 'seg_x1',
      'multiplier': 1.0,
      'probability': 0.18,
      'label': 'x1',
      'colorHex': '#81C784', // Light Green
    },
    {
      'id': 'seg_x1_5',
      'multiplier': 1.5,
      'probability': 0.12,
      'label': 'x1.5',
      'colorHex': '#4FC3F7', // Light Blue
    },
    {
      'id': 'seg_x2',
      'multiplier': 2.0,
      'probability': 0.08,
      'label': 'x2',
      'colorHex': '#64B5F6', // Blue
    },
    {
      'id': 'seg_x3',
      'multiplier': 3.0,
      'probability': 0.04,
      'label': 'x3',
      'colorHex': '#BA68C8', // Purple
    },
    {
      'id': 'seg_x5',
      'multiplier': 5.0,
      'probability': 0.02,
      'label': 'x5',
      'colorHex': '#FFB74D', // Orange
    },
    {
      'id': 'seg_x10',
      'multiplier': 10.0,
      'probability': 0.011,
      'label': 'JACKPOT x10',
      'colorHex': '#FFD54F', // Gold
    },
  ];

  double totalProb = 0;
  double totalEv = 0;
  for (var s in segments) {
    totalProb += s['probability'] as double;
    totalEv += (s['multiplier'] as double) * (s['probability'] as double);
  }

  print('Total Probability: $totalProb');
  print('Total EV: $totalEv');

  if ((totalProb - 1.0).abs() > 0.0001) {
    print('WARNING: Total probability is not exactly 1.0');
  }

  await firestore.collection('spin_wheel_configs').doc('default_config').set({
    'id': 'default_config',
    'segments': segments,
    'minBet': 10000.0,
    'maxBet': 500000.0,
    'isActive': true,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  print('Seed SpinWheelConfig successfully!');
}
