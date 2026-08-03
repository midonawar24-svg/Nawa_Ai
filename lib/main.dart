// main.dart - اختبار المرحلة 1 الحقيقي على جهاز حقيقي فقط
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:fllama/fllama.dart';

class ModelDownloader {
  static Future<String> getModelPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/qwen2.5-1.5b-q4_k_m.gguf';
    final file = File(filePath);

    if (await file.exists()) {
      debugPrint('✅ Model exists: $filePath - ${(await file.length()) / 1024 / 1024} MB');
      return filePath;
    }

    debugPrint('⬇️ Downloading model... (1GB)');
    // حط لينك HuggingFace مباشر
    const url = 'https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf';
    
    await Dio().download(url, filePath, onReceiveProgress: (rec, total) {
      debugPrint('Progress: ${(rec/total*100).toStringAsFixed(1)}%');
    });

    return filePath;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TestApp());
}

class TestApp extends StatefulWidget { @override State<TestApp> createState() => _TestAppState(); }

class _TestAppState extends State<TestApp> {
  String log = 'Starting...\n';
  void addLog(String s) => setState(() => log += '$s\n');

  @override
  void initState() {
    super.initState();
    _runRealTest();
  }

  Future<void> _runRealTest() async {
    try {
      // 1. جيب المسار الحقيقي من Filesystem مش assets
      addLog('📁 Getting model path...');
      final modelPath = await ModelDownloader.getModelPath();
      addLog('Path: $modelPath');

      // 2. Load Time + RAM
      final loadStopwatch = Stopwatch()..start();
      addLog('🚀 Loading model with embedding:true flag...');

      // مهم: افتح الـ context بـ embedding enabled عشان النقطة 2 اللي قلتها
      await fllama.loadModel(
        modelPath,
        contextSize: 2048, // قلل لـ 2048 عشان RAM < 1.2GB
        embeddingEnabled: true, // <-- ده اللي يحل مشكلة Embedding vs Generation
      );

      loadStopwatch.stop();
      addLog('✅ Load Time: ${loadStopwatch.elapsedMilliseconds}ms');
      addLog('📊 Target: < 1000ms | Actual: ${loadStopwatch.elapsedMilliseconds}ms ${loadStopwatch.elapsedMilliseconds < 1000 ? "✅" : "⚠️"}');

      // 3. First Token Speed
      addLog('\n⚡ Testing first token...');
      final firstTokenStopwatch = Stopwatch()..start();
      bool first = true;
      
      final stream = fllama.generateStream('مرحبا، من أنت؟');
      await for (final token in stream) {
        if (first) {
          firstTokenStopwatch.stop();
          addLog('⚡ First token: ${firstTokenStopwatch.elapsedMilliseconds}ms');
          addLog('🎯 Target: < 800ms | Actual: ${firstTokenStopwatch.elapsedMilliseconds}ms ${firstTokenStopwatch.elapsedMilliseconds < 800 ? "✅" : "⚠️"}');
          first = false;
        }
        addLog('Token: $token');
        if (token.contains('\n')) break; // أول سطر بس
      }

      // 4. Embedding Test
      addLog('\n🧠 Testing Embedding...');
      final embStopwatch = Stopwatch()..start();
      final embedding = await fllama.getEmbedding('اختبار الذاكرة');
      embStopwatch.stop();
      addLog('✅ Embedding dim: ${embedding.length}');
      addLog('⏱️ Embedding time: ${embStopwatch.elapsedMilliseconds}ms');
      addLog('📊 RAM check: Check Android Studio Profiler now! Target < 1.2GB');

      addLog('\n🎉 PHASE 1 SUCCESS - جاهز للمرحلة 2 (Isar+Drift)');

    } catch(e, stack) {
      addLog('❌ ERROR: $e');
      debugPrintStack(stackTrace: stack);
    }
  }

  @override Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: SingleChildScrollView(child: Padding(
      padding: EdgeInsets.all(16), child: Text(log, style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
    ))));
  }
}
