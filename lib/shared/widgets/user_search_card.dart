import 'package:flutter/material.dart';

import '../../core/theme/game_theme_data.dart';
import '../../data/models/public_user.dart';
class UserSearchCard extends StatelessWidget {
  const UserSearchCard({
    super.key,
    required this.user,
    required this.theme,
    required this.onAction,
    this.rank,
    this.busy = false,
  });

  final PublicUser user;
  final GameThemeData theme;
  final int? rank;
  final bool busy;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    final glow = rank != null && rank! <= 3;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.scoreBackground.withValues(alpha: 0.25),
        border: Border.all(
          color: glow ? theme.uiAccent : theme.boardBorder,
          width: glow ? 2 : 1,
        ),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: theme.uiAccent.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          if (rank != null) ...[
            SizedBox(
              width: 28,
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: rank! <= 3 ? theme.uiAccent : theme.scoreLabel,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          CircleAvatar(
            radius: 20,
            backgroundColor: theme.uiSecondary,
            backgroundImage:
                user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null
                ? Icon(Icons.person, size: 20, color: theme.uiPrimary)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: TextStyle(
                    color: theme.uiPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'BEST ${user.bestScore.toString().padLeft(4, '0')}',
                  style: TextStyle(
                    color: theme.scoreLabel,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          _actionButton(context),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context) {
    if (user.relation == SocialRelation.self) {
      return Text('YOU', style: TextStyle(color: theme.scoreLabel, fontSize: 10));
    }
    final label = switch (user.relation) {
      SocialRelation.friends => 'FRIENDS',
      SocialRelation.pendingSent => 'PENDING',
      SocialRelation.pendingReceived => 'INCOMING',
      SocialRelation.none => 'ADD',
      SocialRelation.self => '',
    };
    final enabled = user.relation == SocialRelation.none ||
        user.relation == SocialRelation.pendingReceived;
    final actionLabel = user.relation == SocialRelation.pendingReceived
        ? 'ACCEPT'
        : label;
    return Material(
      color: enabled ? theme.uiSecondary : theme.scoreBackground,
      child: InkWell(
        onTap: busy || !enabled ? null : () => onAction(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: enabled ? theme.uiAccent : theme.boardBorder,
            ),
          ),
          child: busy
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.uiPrimary,
                  ),
                )
              : Text(
                  actionLabel,
                  style: TextStyle(
                    color: enabled ? theme.uiAccent : theme.scoreLabel,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
        ),
      ),
    );
  }
}
