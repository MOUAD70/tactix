import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/formation.dart';
import 'package:flutter_application_1/models/opponent_player.dart';
import 'package:flutter_application_1/models/player.dart';
import 'package:flutter_application_1/models/player_position.dart';
import 'package:flutter_application_1/models/training.dart';

class TactixAppState extends ChangeNotifier {
  static const double _pitchSnapStep = 0.02;

  TactixAppState() {
    final starterIds = _players.take(11).map((player) => player.id).toList(growable: false);
    _savedFormations.addAll(Formation.presetSamples(starterIds));
    _formation = _savedFormations.first;
    _activeFormationId = _formation.id;
  }

  bool _isAuthenticated = true;
  String _coachName = 'Coach Karim';
  String _coachEmail = 'coach@tactix.app';
  String? _profilePhoto;

  final List<Player> _players = <Player>[
    Player(id: 1, name: 'Yassine Bounou', jerseyNumber: 1, position: PlayerRole.gk),
    Player(id: 2, name: 'Achraf Hakimi', jerseyNumber: 2, position: PlayerRole.rb),
    Player(id: 3, name: 'Romain Saiss', jerseyNumber: 6, position: PlayerRole.cb),
    Player(id: 4, name: 'Nayef Aguerd', jerseyNumber: 5, position: PlayerRole.cb),
    Player(id: 5, name: 'Noussair Mazraoui', jerseyNumber: 3, position: PlayerRole.lb),
    Player(id: 6, name: 'Sofyan Amrabat', jerseyNumber: 4, position: PlayerRole.cm),
    Player(id: 7, name: 'Azzedine Ounahi', jerseyNumber: 8, position: PlayerRole.cm),
    Player(id: 8, name: 'Selim Amallah', jerseyNumber: 15, position: PlayerRole.cm),
    Player(id: 9, name: 'Hakim Ziyech', jerseyNumber: 7, position: PlayerRole.rw),
    Player(id: 10, name: 'Youssef En-Nesyri', jerseyNumber: 19, position: PlayerRole.st),
    Player(id: 11, name: 'Sofiane Boufal', jerseyNumber: 17, position: PlayerRole.lw),
    Player(id: 12, name: 'Abde Ezzalzouli', jerseyNumber: 16, position: PlayerRole.lw),
    Player(id: 13, name: 'Bilal El Khannouss', jerseyNumber: 14, position: PlayerRole.am),
    Player(id: 14, name: 'Jawad El Yamiq', jerseyNumber: 18, position: PlayerRole.cb),
  ];

  Formation _formation = const Formation(
    id: 'empty',
    name: 'Empty',
    schemeId: '4-3-3',
    positions: <PlayerPosition>[],
  );
  String _activeFormationId = 'empty';
  final List<Formation> _savedFormations = <Formation>[];

  final List<OpponentPlayer> _opponentPlayers = <OpponentPlayer>[
    OpponentPlayer(id: 'o1', label: 'O1', x: 0.30, y: 0.22),
    OpponentPlayer(id: 'o2', label: 'O2', x: 0.50, y: 0.28),
    OpponentPlayer(id: 'o3', label: 'O3', x: 0.70, y: 0.22),
    OpponentPlayer(id: 'o4', label: 'O4', x: 0.25, y: 0.44),
    OpponentPlayer(id: 'o5', label: 'O5', x: 0.75, y: 0.44),
  ];

  final List<Training> _trainingSessions = <Training>[
    Training(
      id: 't1',
      title: 'High Press Drill',
      focusArea: 'Pressing',
      date: DateTime(2026, 3, 10),
      description: 'Compact block work with quick recovery runs.',
      durationMinutes: 90,
    ),
    Training(
      id: 't2',
      title: 'Transition Waves',
      focusArea: 'Transitions',
      date: DateTime(2026, 3, 12),
      description: 'Fast attacking transitions from midfield overloads.',
      durationMinutes: 75,
    ),
  ];

  bool get isAuthenticated => _isAuthenticated;
  String get coachName => _coachName;
  String get coachEmail => _coachEmail;
  String? get profilePhoto => _profilePhoto;
  List<Player> get players => List<Player>.unmodifiable(_players);
  Formation get formation => _formation;
  String get activeFormationId => _activeFormationId;
  List<Formation> get savedFormations => List<Formation>.unmodifiable(_savedFormations);
  List<OpponentPlayer> get opponentPlayers => List<OpponentPlayer>.unmodifiable(_opponentPlayers);
  List<Training> get trainingSessions => List<Training>.unmodifiable(_trainingSessions);

  List<Player> get benchPlayers {
    final startingIds = _formation.positions.map((position) => position.playerId).whereType<int>().toSet();
    return _players.where((player) => !startingIds.contains(player.id)).toList(growable: false);
  }

  Player? playerById(int? id) {
    for (final player in _players) {
      if (player.id == id) return player;
    }
    return null;
  }

  double _clampCoordinate(double value) => value.clamp(0.0, 1.0).toDouble();

  double _snapCoordinate(double value) {
    final snapped = (_clampCoordinate(value) / _pitchSnapStep).round() * _pitchSnapStep;
    return double.parse(_clampCoordinate(snapped).toStringAsFixed(2));
  }

  void _storeActiveFormation(Formation updatedFormation) {
    final index = _savedFormations.indexWhere((formation) => formation.id == _activeFormationId);
    if (index != -1) {
      _savedFormations[index] = updatedFormation;
    }
    _formation = updatedFormation;
  }

  Formation? formationById(String formationId) {
    for (final formation in _savedFormations) {
      if (formation.id == formationId) return formation;
    }
    return null;
  }

  void login(String email, String password) {
    _coachEmail = email;
    _isAuthenticated = true;
    notifyListeners();
  }

  void register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? teamId,
  }) {
    _coachName = name;
    _coachEmail = email;
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  void updateCoachProfile({required String name, required String email, String? profilePhoto}) {
    _coachName = name;
    _coachEmail = email;
    _profilePhoto = profilePhoto ?? _profilePhoto;
    notifyListeners();
  }

  void addPlayer(Player player) {
    _players.add(player);
    notifyListeners();
  }

  void updatePlayer(Player updatedPlayer) {
    final index = _players.indexWhere((player) => player.id == updatedPlayer.id);
    if (index == -1) return;
    _players[index] = updatedPlayer;
    notifyListeners();
  }

  void deletePlayer(int playerId) {
    _players.removeWhere((player) => player.id == playerId);
    for (var index = 0; index < _savedFormations.length; index++) {
      _savedFormations[index] = _savedFormations[index].copyWith(
        positions: _savedFormations[index].positions
            .map(
              (position) => position.playerId == playerId ? position.copyWith(playerId: null) : position,
            )
            .toList(growable: false),
      );
    }
    _formation = formationById(_activeFormationId) ?? _formation;
    notifyListeners();
  }

  void activateFormation(String formationId) {
    final selectedFormation = formationById(formationId);
    if (selectedFormation == null || formationId == _activeFormationId) return;

    _activeFormationId = formationId;
    _formation = selectedFormation;
    notifyListeners();
  }

  void saveCurrentFormationAs(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;

    final savedFormation = _formation.copyWith(
      id: 'saved_${DateTime.now().microsecondsSinceEpoch}',
      name: trimmedName,
      isPreset: false,
    );
    _savedFormations.add(savedFormation);
    _activeFormationId = savedFormation.id;
    _formation = savedFormation;
    notifyListeners();
  }

  void deleteSavedFormation(String formationId) {
    final formation = formationById(formationId);
    if (formation == null || formation.isPreset || _savedFormations.length == 1) return;

    _savedFormations.removeWhere((item) => item.id == formationId);
    if (_activeFormationId == formationId) {
      _activeFormationId = _savedFormations.first.id;
      _formation = _savedFormations.first;
    }
    notifyListeners();
  }

  void assignPlayerToPosition({required int playerId, required String positionId}) {
    _storeActiveFormation(_formation.copyWith(
      positions: _formation.positions
          .map((position) {
            if (position.id == positionId) {
              return position.copyWith(playerId: playerId);
            }
            if (position.playerId == playerId && position.id != positionId) {
              return position.copyWith(playerId: null);
            }
            return position;
          })
          .toList(growable: false),
    ));
    notifyListeners();
  }

  void clearPositionAssignment(String positionId) {
    _storeActiveFormation(_formation.copyWith(
      positions: _formation.positions
          .map(
            (position) => position.id == positionId ? position.copyWith(playerId: null) : position,
          )
          .toList(growable: false),
    ));
    notifyListeners();
  }

  void movePosition(String positionId, {required double x, required double y}) {
    _storeActiveFormation(_formation.copyWith(
      positions: _formation.positions
          .map(
            (position) => position.id == positionId
                ? position.copyWith(x: _clampCoordinate(x), y: _clampCoordinate(y))
                : position,
          )
          .toList(growable: false),
    ));
    notifyListeners();
  }

  void snapPosition(String positionId) {
    _storeActiveFormation(_formation.copyWith(
      positions: _formation.positions
          .map(
            (position) => position.id == positionId
                ? position.copyWith(
                    x: _snapCoordinate(position.x),
                    y: _snapCoordinate(position.y),
                  )
                : position,
          )
          .toList(growable: false),
    ));
    notifyListeners();
  }

  void swapPositionAssignments({required String fromPositionId, required String toPositionId}) {
    if (fromPositionId == toPositionId) return;

    final fromPosition = _formation.findPosition(fromPositionId);
    final toPosition = _formation.findPosition(toPositionId);
    if (fromPosition == null || toPosition == null) return;

    _storeActiveFormation(_formation.copyWith(
      positions: _formation.positions
          .map((position) {
            if (position.id == fromPositionId) {
              return position.copyWith(playerId: toPosition.playerId);
            }
            if (position.id == toPositionId) {
              return position.copyWith(playerId: fromPosition.playerId);
            }
            return position;
          })
          .toList(growable: false),
    ));
    notifyListeners();
  }

  void resetFormationLayout() {
    final currentById = <String, PlayerPosition>{
      for (final position in _formation.positions) position.id: position,
    };

    _storeActiveFormation(_formation.copyWith(
      positions: Formation.defaultPositionsForScheme(_formation.schemeId)
          .map((defaultPosition) {
            final current = currentById[defaultPosition.id];
            return defaultPosition.copyWith(
              playerId: current?.playerId,
              instructions: current?.instructions ?? '',
            );
          })
          .toList(growable: false),
    ));
    notifyListeners();
  }

  String addOpponentPlayer() {
    var nextNumber = 1;
    for (final opponent in _opponentPlayers) {
      final value = int.tryParse(opponent.label.replaceFirst('O', ''));
      if (value != null && value >= nextNumber) nextNumber = value + 1;
    }

    final id = 'o${DateTime.now().microsecondsSinceEpoch}';
    final slot = _opponentPlayers.length % 4;
    _opponentPlayers.add(
      OpponentPlayer(
        id: id,
        label: 'O$nextNumber',
        x: 0.22 + (slot * 0.18),
        y: 0.10 + ((_opponentPlayers.length % 3) * 0.10),
      ),
    );
    notifyListeners();
    return id;
  }

  void moveOpponentPlayer(String opponentId, {required double x, required double y}) {
    final index = _opponentPlayers.indexWhere((opponent) => opponent.id == opponentId);
    if (index == -1) return;
    _opponentPlayers[index] = _opponentPlayers[index].copyWith(
      x: x.clamp(0.0, 1.0),
      y: y.clamp(0.0, 1.0),
    );
    notifyListeners();
  }

  void removeOpponentPlayer(String opponentId) {
    _opponentPlayers.removeWhere((opponent) => opponent.id == opponentId);
    notifyListeners();
  }

  void updateInstructions(String positionId, String instructions) {
    _storeActiveFormation(_formation.copyWith(
      positions: _formation.positions
          .map(
            (position) => position.id == positionId
                ? position.copyWith(instructions: instructions)
                : position,
          )
          .toList(growable: false),
    ));
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<TactixAppState> {
  const AppStateScope({super.key, required super.notifier, required super.child});

  static TactixAppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope was not found in the widget tree.');
    return scope!.notifier!;
  }
}