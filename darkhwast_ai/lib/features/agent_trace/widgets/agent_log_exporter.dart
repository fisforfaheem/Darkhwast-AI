import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/pipeline_state.dart';

class AgentLogExportResult {
  final String jsonString;
  final String? filePath;

  const AgentLogExportResult({required this.jsonString, this.filePath});
}

class AgentLogExporter {
  static Future<AgentLogExportResult> exportLog(PipelineState state) async {
    final jsonString = state.toJsonString();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/antigravity_trace_${state.runId}.json',
      );
      await file.writeAsString(jsonString);
      return AgentLogExportResult(jsonString: jsonString, filePath: file.path);
    } catch (_) {
      return AgentLogExportResult(jsonString: jsonString);
    }
  }

  static Future<void> shareLog(PipelineState state) async {
    final result = await exportLog(state);
    final fileName = 'antigravity_trace_${state.runId}.json';

    if (result.filePath != null) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(result.filePath!, name: fileName)],
          subject: 'DarkhwastAI Antigravity Agent Trace',
          text:
              'Antigravity-style agent reasoning trace (Challenge 1) — DarkhwastAI AISeekho 2026',
        ),
      );
      return;
    }

    await SharePlus.instance.share(
      ShareParams(
        text: result.jsonString,
        subject: 'DarkhwastAI Agent Trace',
      ),
    );
  }

  static Future<void> copyToClipboard(PipelineState state) async {
    await Clipboard.setData(ClipboardData(text: state.toJsonString()));
  }
}
