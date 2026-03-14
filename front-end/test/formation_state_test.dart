import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/core/state/app_state.dart';

void main() {
  group('Tactix formation state', () {
    test('assigns a bench player to a position and benches previous occupant', () {
      final state = TactixAppState();

      expect(state.benchPlayers.any((player) => player.id == 'p12'), isTrue);

      state.assignPlayerToPosition(playerId: 'p12', positionId: 'lw');

      expect(state.formation.findPosition('lw')?.playerId, 'p12');
      expect(state.benchPlayers.any((player) => player.id == 'p9'), isTrue);
      expect(state.benchPlayers.any((player) => player.id == 'p12'), isFalse);
    });

    test('moves and resets formation positions', () {
      final state = TactixAppState();

      state.movePosition('st', x: 0.90, y: 0.12);
      expect(state.formation.findPosition('st')?.x, closeTo(0.90, 0.001));
      expect(state.formation.findPosition('st')?.y, closeTo(0.12, 0.001));

      state.resetFormationLayout();

      expect(state.formation.findPosition('st')?.x, closeTo(0.50, 0.001));
      expect(state.formation.findPosition('st')?.y, closeTo(0.18, 0.001));
    });

    test('swaps players between occupied positions', () {
      final state = TactixAppState();

      state.swapPositionAssignments(fromPositionId: 'lw', toPositionId: 'rw');

      expect(state.formation.findPosition('lw')?.playerId, 'p11');
      expect(state.formation.findPosition('rw')?.playerId, 'p9');
    });

    test('switches between saved formation setups', () {
      final state = TactixAppState();

      state.activateFormation('3-5-2');

      expect(state.activeFormationId, '3-5-2');
      expect(state.formation.schemeId, '3-5-2');
      expect(state.formation.positions.length, 11);
      expect(state.formation.findPosition('lwb'), isNotNull);
    });

    test('preserves formation edits when switching between saved setups', () {
      final state = TactixAppState();

      state.movePosition('st', x: 0.88, y: 0.16);
      state.activateFormation('4-2-3-1');
      state.activateFormation('4-3-3');

      expect(state.formation.findPosition('st')?.x, closeTo(0.88, 0.001));
      expect(state.formation.findPosition('st')?.y, closeTo(0.16, 0.001));
    });

    test('saves and deletes a custom formation setup', () {
      final state = TactixAppState();
      final initialCount = state.savedFormations.length;

      state.saveCurrentFormationAs('Late Game Press');

      expect(state.savedFormations.length, initialCount + 1);
      expect(state.formation.name, 'Late Game Press');
      expect(state.formation.isPreset, isFalse);

      final customFormationId = state.activeFormationId;
      state.deleteSavedFormation(customFormationId);

      expect(state.savedFormations.length, initialCount);
      expect(state.activeFormationId, isNot(customFormationId));
    });

    test('snaps dragged positions to a clean tactical grid', () {
      final state = TactixAppState();

      state.movePosition('st', x: 0.913, y: 0.127);
      state.snapPosition('st');

      expect(state.formation.findPosition('st')?.x, closeTo(0.92, 0.001));
      expect(state.formation.findPosition('st')?.y, closeTo(0.12, 0.001));
    });

    test('adds and removes opponent players', () {
      final state = TactixAppState();
      final initialCount = state.opponentPlayers.length;

      final newId = state.addOpponentPlayer();
      expect(state.opponentPlayers.length, initialCount + 1);

      state.removeOpponentPlayer(newId);
      expect(state.opponentPlayers.length, initialCount);
    });
  });
}