import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/core/supabase/supabase_tables.dart';
import 'package:stay_alive/features/coach/domain/entities/coach_entities.dart';
import 'package:stay_alive/features/coach/domain/services/coach_local_fallback.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

abstract class CoachRemoteDataSource {
  Future<CoachResponse> invoke({
    required CoachMode mode,
    required CoachContextPayload context,
    required bool isPremium,
  });
}

class CoachRemoteDataSourceImpl implements CoachRemoteDataSource {
  CoachRemoteDataSourceImpl({
    required supabase.FunctionsClient functions,
    required AppLogger logger,
  })  : _functions = functions,
        _logger = logger;

  final supabase.FunctionsClient _functions;
  final AppLogger _logger;

  @override
  Future<CoachResponse> invoke({
    required CoachMode mode,
    required CoachContextPayload context,
    required bool isPremium,
  }) async {
    // Any failure (function not deployed, 503 without an OpenAI key, network)
    // degrades to the local heuristic — the coach never hard-fails.
    try {
      final supabase.FunctionResponse response = await _functions.invoke(
        SupabaseFunctions.aiCoach,
        body: <String, dynamic>{
          'mode': mode.name,
          'isPremium': isPremium,
          'context': context.toJson(),
        },
      );

      final Object? decoded = response.data;
      if (decoded is Map<String, dynamic>) {
        return CoachResponse.fromJson(decoded);
      }
      if (decoded is Map) {
        return CoachResponse.fromJson(Map<String, dynamic>.from(decoded));
      }
      return CoachLocalFallback.respond(mode: mode, context: context);
    } catch (error, stackTrace) {
      _logger.warning(
        'AI coach invoke failed — fallback',
        data: <String, Object?>{
          'error': error.toString(),
          'stack': stackTrace.toString(),
        },
      );
      return CoachLocalFallback.respond(mode: mode, context: context);
    }
  }
}
