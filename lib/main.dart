import 'package:flutter/material.dart';
import 'core/ai/kernel/ai_core_kernel.dart';
import 'core/ai/runtime/model_runtime.dart';
import 'chat_master_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final kernel = AiCoreKernel();
  await kernel.init(runtime: MockModelRuntime());
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: ChatMasterPage(),
  ));
}      );

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
