import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/case_entity.dart';

class LocalCaseRepository {
  static const _storageKey = 'saved_cases_v1';

  final SharedPreferences _prefs;

  LocalCaseRepository(this._prefs);

  Future<List<CaseEntity>> getCases() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => CaseEntity.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCase(CaseEntity caseData) async {
    final cases = await getCases();
    cases.removeWhere((c) => c.id == caseData.id);
    cases.insert(0, caseData);
    await _prefs.setString(
      _storageKey,
      jsonEncode(cases.map((c) => c.toJson()).toList()),
    );
  }
}
