import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart' show basicLocaleListResolution;
import 'package:stay_alive/core/l10n/l10n.dart';
import 'package:stay_alive/features/coach/domain/services/coach_local_fallback.dart';

/// The coach also speaks from places that have no `BuildContext` — the offline
/// fallback in the data source and the free-limit guard in the cubit. Resolve
/// the locale the same way `MaterialApp` does, from the platform's preferred
/// list against [supportedLocales], so the copy matches the rest of the UI.
AppLocalizations coachL10n() => lookupAppLocalizations(
      basicLocaleListResolution(
        PlatformDispatcher.instance.locales,
        supportedLocales,
      ),
    );

/// Localized copy for the offline coach. Tear-offs, so a signature drift in the
/// generated strings fails the build instead of the fallback.
CoachFallbackStrings coachFallbackStrings(AppLocalizations l10n) =>
    CoachFallbackStrings(
      nudgeWilting: l10n.coachFallbackNudgeWilting,
      nudgeNextStep: l10n.coachFallbackNudgeNextStep,
      nudgeAllDone: l10n.coachFallbackNudgeAllDone,
      chatIntro: l10n.coachFallbackChatIntro,
      chatGaps: l10n.coachFallbackChatGaps,
      chatAllDone: l10n.coachFallbackChatAllDone,
      weeklyMessage: l10n.coachFallbackWeeklyMessage,
      weeklyStreakTitle: l10n.coachFallbackWeeklyStreakTitle,
      weeklyStreakBody: l10n.coachFallbackWeeklyStreakBody,
      weeklyStreakKeepRhythm: l10n.coachFallbackWeeklyStreakKeepRhythm,
      weeklyStreakComeBack: l10n.coachFallbackWeeklyStreakComeBack,
      weeklyGapsTitle: l10n.coachFallbackWeeklyGapsTitle,
      weeklyGapsNone: l10n.coachFallbackWeeklyGapsNone,
      weeklyGapsList: l10n.coachFallbackWeeklyGapsList,
      weeklyAdviceTitle: l10n.coachFallbackWeeklyAdviceTitle,
      weeklyAdviceBody: l10n.coachFallbackWeeklyAdviceBody,
      challengeMessage: l10n.coachFallbackChallengeMessage,
      challengeTitle: l10n.coachFallbackChallengeTitle,
      challengeDescription: l10n.coachFallbackChallengeDescription,
      educationTip: l10n.coachFallbackEducationTip,
    );
