import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

enum SoundCue { open, correct, wrong, win }

class AppFeedback {
  static Future<void> play(SoundCue cue) async {
    final patterns = <SoundCue, List<double>>{
      SoundCue.open: [523.25, 659.25, 783.99],
      SoundCue.correct: [659.25, 783.99],
      SoundCue.wrong: [392.0, 293.66],
      SoundCue.win: [523.25, 659.25, 783.99, 1046.5],
    };
    final notes = patterns[cue]!;
    final bytes = _makeWave(notes);
    final player = AudioPlayer();
    try {
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.play(BytesSource(bytes));
      await Future<void>.delayed(Duration(milliseconds: notes.length * 210 + 100));
    } catch (_) {
      // Audio is optional; the game remains usable if the device blocks playback.
    } finally {
      await player.dispose();
    }
  }

  static Uint8List _makeWave(List<double> notes) {
    const sampleRate = 22050;
    const noteMs = 180;
    const gapMs = 28;
    final samplesPerNote = sampleRate * noteMs ~/ 1000;
    final gapSamples = sampleRate * gapMs ~/ 1000;
    final totalSamples = notes.length * samplesPerNote + (notes.length - 1) * gapSamples;
    final dataSize = totalSamples * 2;
    final bytes = Uint8List(44 + dataSize);
    final header = ByteData.sublistView(bytes);
    void ascii(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        bytes[offset + i] = value.codeUnitAt(i);
      }
    }
    ascii(0, 'RIFF');
    header.setUint32(4, 36 + dataSize, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, 1, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate * 2, Endian.little);
    header.setUint16(32, 2, Endian.little);
    header.setUint16(34, 16, Endian.little);
    ascii(36, 'data');
    header.setUint32(40, dataSize, Endian.little);
    var cursor = 44;
    for (final frequency in notes) {
      for (var i = 0; i < samplesPerNote; i++) {
        final t = i / sampleRate;
        final edge = math.min(1.0, math.min(i / 500.0, (samplesPerNote - i) / 900.0));
        final sample = (math.sin(2 * math.pi * frequency * t) * 10500 * edge).round();
        header.setInt16(cursor, sample, Endian.little);
        cursor += 2;
      }
      for (var i = 0; i < gapSamples; i++) {
        header.setInt16(cursor, 0, Endian.little);
        cursor += 2;
      }
    }
    return bytes;
  }
}

class ReminderService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> initialize() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Aden'));
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: settings);
    _ready = true;
  }

  static Future<bool> scheduleDaily() async {
    await initialize();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission() ?? false;
    if (!granted) return false;

    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, 19);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id: 2099,
      title: 'حان وقت التحدي!',
      body: 'افتح ALQOUD TOOLS وجرب سؤالاً جديداً اليوم.',
      scheduledDate: next,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'alqoud_daily_reminder',
          'تذكير القعود اليومي',
          channelDescription: 'تذكير يومي لطيف للعودة إلى التحديات',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    return true;
  }

  static Future<void> cancelDaily() async {
    await initialize();
    await _plugin.cancel(id: 2099);
  }
}
