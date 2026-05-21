import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/friend_request.dart';
import '../models/public_user.dart';
import '../models/user_profile.dart';
import '../repositories/friend_repository.dart';
import '../repositories/username_repository.dart';
import '../utils/username_validator.dart';

class SocialController extends ChangeNotifier {
  SocialController._();
  static final SocialController instance = SocialController._();

  final UsernameRepository _usernames = UsernameRepository();
  final FriendRepository _friends = FriendRepository();

  Timer? _debounce;
  bool _searching = false;
  bool _checkingAvailability = false;
  List<PublicUser> _searchResults = [];
  String? _searchError;
  bool? _usernameAvailable;
  String? _availabilityMessage;

  bool get isSearching => _searching;
  List<PublicUser> get searchResults => _searchResults;
  String? get searchError => _searchError;
  bool get isCheckingAvailability => _checkingAvailability;
  bool? get usernameAvailable => _usernameAvailable;
  String? get availabilityMessage => _availabilityMessage;

  void debouncedSearch(String query, {required String? myUid}) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(searchUsers(query, myUid: myUid));
    });
  }

  Future<void> searchUsers(String query, {required String? myUid}) async {
    final trimmed = UsernameValidator.normalize(query);
    if (trimmed.length < 2) {
      _searchResults = [];
      _searchError = null;
      _searching = false;
      notifyListeners();
      return;
    }
    _searching = true;
    _searchError = null;
    notifyListeners();

    try {
      final hits = await _usernames.searchByPrefix(trimmed, excludeUid: myUid);
      if (myUid == null) {
        _searchResults = hits
            .map(
              (h) => PublicUser(
                uid: h.uid,
                username: h.username,
                photoUrl: h.photoUrl,
                bestScore: h.bestScore,
                favoriteTheme: h.favoriteTheme,
              ),
            )
            .toList();
      } else {
        final relations = await _friends.relationsFor(
          myUid,
          hits.map((h) => h.uid).toList(),
        );
        _searchResults = hits.map((h) {
          final rel = relations[h.uid] ?? SocialRelation.none;
          final pendingId = switch (rel) {
            SocialRelation.pendingSent =>
              FriendRepository.requestId(myUid, h.uid),
            SocialRelation.pendingReceived =>
              FriendRepository.requestId(h.uid, myUid),
            _ => null,
          };
          return PublicUser(
            uid: h.uid,
            username: h.username,
            photoUrl: h.photoUrl,
            bestScore: h.bestScore,
            favoriteTheme: h.favoriteTheme,
            relation: rel,
            pendingRequestId: pendingId,
          );
        }).toList();
      }
    } on Object {
      _searchError = 'Search failed';
      _searchResults = [];
    } finally {
      _searching = false;
      notifyListeners();
    }
  }

  void debouncedAvailability(String raw, {String? excludeUid}) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(checkAvailability(raw, excludeUid: excludeUid));
    });
  }

  Future<void> checkAvailability(String raw, {String? excludeUid}) async {
    final validation = UsernameValidator.validate(raw);
    if (!validation.isValid) {
      _usernameAvailable = false;
      _availabilityMessage = validation.message;
      notifyListeners();
      return;
    }
    _checkingAvailability = true;
    notifyListeners();
    try {
      final available = await _usernames.isAvailable(
        validation.normalized!,
        excludeUid: excludeUid,
      );
      _usernameAvailable = available;
      _availabilityMessage =
          available ? 'Username available' : 'Username taken';
    } on Object {
      _usernameAvailable = false;
      _availabilityMessage = 'Could not verify';
    } finally {
      _checkingAvailability = false;
      notifyListeners();
    }
  }

  void resetAvailability() {
    _usernameAvailable = null;
    _availabilityMessage = null;
    notifyListeners();
  }

  Future<bool> claimUsername(UserProfile profile, String raw) async {
    final validation = UsernameValidator.validate(raw);
    if (!validation.isValid || validation.normalized == null) return false;
    final ok = await _usernames.claimUsername(
      uid: profile.uid,
      rawUsername: validation.normalized!,
      baseProfile: profile.copyWith(username: validation.normalized),
    );
    return ok;
  }

  Future<String?> sendFriendRequest(UserProfile from, PublicUser to) async {
    return _friends.sendRequest(
      from: from,
      toUid: to.uid,
      toUsername: to.username,
    );
  }

  Future<bool> acceptRequest(FriendRequest request, UserProfile me) =>
      _friends.acceptRequest(request: request, myProfile: me);

  Future<bool> rejectRequest(FriendRequest request, String myUid) =>
      _friends.rejectRequest(request, myUid);

  Future<bool> cancelSent(String requestId, String myUid) =>
      _friends.cancelSentRequest(requestId, myUid);

  Stream<List<FriendRequest>> watchIncoming(String uid) =>
      _friends.watchIncoming(uid);

  Stream<List<FriendRequest>> watchSent(String uid) => _friends.watchSent(uid);

  Stream<int> watchIncomingCount(String uid) => _friends.watchIncomingCount(uid);

  FriendRepository get friendsRepo => _friends;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
