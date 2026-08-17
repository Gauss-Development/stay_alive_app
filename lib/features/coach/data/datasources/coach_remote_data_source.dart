import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/features/coach/domain/entities/coach_entities.dart';
import 'package:stay_alive/features/coach/domain/services/coach_local_fallback.dart';

abstract class CoachRemoteDataSource {
  Future<CoachResponse> invoke({
    required CoachMode mode,
    required CoachContextPayload context,
    required bool isPremium,
  });
}

class CoachRemoteDataSourceImpl implements CoachRemoteDataSource {
  CoachRemoteDataSourceImpl({
    required Functions functions,
    required EnvConfig envConfig,
    required AppLogger logger,
  }) : _functions = functions,
       _envConfig = envConfig,
       _logger = logger;

  final Functions _functions;
  final EnvConfig _envConfig;
  final AppLogger _logger;

  @override
  Future<CoachResponse> invoke({
    required CoachMode mode,
    required CoachContextPayload context,
    required bool isPremium,
  }) async {
    final String functionId = _envConfig.aiCoachFunctionId;
    if (functionId.isEmpty) {
      _logger.info('AI coach function unset — using local fallback');
      return CoachLocalFallback.respond(mode: mode, context: context);
    }

    try {
      final appwrite_models.Execution execution = await _functions
          .createExecution(
            functionId: functionId,
            body: jsonEncode(<String, dynamic>{
              'mode': mode.name,
              'isPremium': isPremium,
              'context': context.toJson(),
            }),
            xasync: false,
          );

      final bool ok =
          execution.status == 'completed' &&
          execution.responseStatusCode >= 200 &&
          execution.responseStatusCode < 300;
      if (!ok) {
        _logger.warning(
          'AI coach execution failed — fallback',
          data: <String, Object?>{
            'status': execution.status,
            'code': execution.responseStatusCode,
            'errors': execution.errors,
          },
        );
        return CoachLocalFallback.respond(mode: mode, context: context);
      }

      final Object? decoded = jsonDecode(execution.responseBody);
      if (decoded is Map<String, dynamic>) {
        return CoachResponse.fromJson(decoded);
      }
      if (decoded is Map) {
        return CoachResponse.fromJson(Map<String, dynamic>.from(decoded));
      }
      return CoachLocalFallback.respond(mode: mode, context: context);
    } catch (error, stackTrace) {
      _logger.error(
        'AI coach invoke error — fallback',
        error: error,
        data: <String, Object?>{'stack': stackTrace.toString()},
      );
      return CoachLocalFallback.respond(mode: mode, context: context);
    }
  }
}
