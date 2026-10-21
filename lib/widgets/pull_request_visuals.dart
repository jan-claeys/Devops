import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/pull_request.dart';
import 'work_item_visuals.dart';

/// Colors and icons that match the Azure DevOps pull request statuses.
class PullRequestStatusStyle {
  const PullRequestStatusStyle(this.color, this.icon);

  final Color color;
  final IconData icon;

  static PullRequestStatusStyle of(PullRequestStatus status, ColorScheme scheme) =>
      switch (status) {
        PullRequestStatus.draft => PullRequestStatusStyle(scheme.outline, Icons.edit_note),
        PullRequestStatus.active => const PullRequestStatusStyle(Color(0xFF007ACC), Icons.call_merge),
        PullRequestStatus.completed =>
          const PullRequestStatusStyle(Color(0xFF339933), Icons.check_circle),
        PullRequestStatus.abandoned => PullRequestStatusStyle(scheme.outline, Icons.block),
      };
}

String pullRequestStatusLabel(AppLocalizations l10n, PullRequestStatus status) =>
    switch (status) {
      PullRequestStatus.draft => l10n.prDraft,
      PullRequestStatus.active => l10n.prActive,
      PullRequestStatus.completed => l10n.prCompleted,
      PullRequestStatus.abandoned => l10n.prAbandoned,
    };

/// Small tonal pill showing the status with its icon.
class PullRequestStatusBadge extends StatelessWidget {
  const PullRequestStatusBadge(this.status, {super.key});

  final PullRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = PullRequestStatusStyle.of(status, scheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, color: style.color, size: 14),
          const SizedBox(width: 6),
          Text(pullRequestStatusLabel(context.l10n, status),
              style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

/// Colors and icons of the votes, like the reviewer list in Azure DevOps.
class ReviewVoteStyle {
  const ReviewVoteStyle(this.color, this.icon);

  final Color color;
  final IconData icon;

  static ReviewVoteStyle of(ReviewVote vote, ColorScheme scheme) => switch (vote) {
        ReviewVote.approved => const ReviewVoteStyle(Color(0xFF339933), Icons.check_circle),
        ReviewVote.approvedWithSuggestions =>
          const ReviewVoteStyle(Color(0xFF339933), Icons.check_circle_outline),
        ReviewVote.none => ReviewVoteStyle(scheme.outline, Icons.radio_button_unchecked),
        ReviewVote.waitingForAuthor =>
          const ReviewVoteStyle(Color(0xFFFF9D00), Icons.schedule),
        ReviewVote.rejected => const ReviewVoteStyle(Color(0xFFCC293D), Icons.cancel),
      };
}

String reviewVoteLabel(AppLocalizations l10n, ReviewVote vote) => switch (vote) {
      ReviewVote.approved => l10n.voteApproved,
      ReviewVote.approvedWithSuggestions => l10n.voteApprovedWithSuggestions,
      ReviewVote.none => l10n.voteNone,
      ReviewVote.waitingForAuthor => l10n.voteWaitingForAuthor,
      ReviewVote.rejected => l10n.voteRejected,
    };

/// Avatar of a reviewer with their vote in the corner.
class ReviewerAvatar extends StatelessWidget {
  const ReviewerAvatar(this.reviewer, {super.key, this.radius = 12});

  final Reviewer reviewer;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = ReviewVoteStyle.of(reviewer.vote, scheme);
    final badge = radius * 0.9;
    return Tooltip(
      message: '${reviewer.identity.displayName}: '
          '${reviewVoteLabel(context.l10n, reviewer.vote)}',
      child: SizedBox.square(
        dimension: radius * 2 + badge / 3,
        child: Stack(
          children: [
            PersonAvatar(reviewer.identity, radius: radius),
            if (reviewer.vote != ReviewVote.none)
              Positioned(
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: scheme.surface, shape: BoxShape.circle),
                  child: Icon(style.icon, color: style.color, size: badge),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
