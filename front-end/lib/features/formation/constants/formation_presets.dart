import '../data/models/formation_position_model.dart';

class FormationPresets {
  static const Map<String, List<FormationPositionModel>> presets = {
    '4-3-3': [
      FormationPositionModel(id: 0, role: 'GK', x: 50.0, y: 5.0),
      FormationPositionModel(id: 0, role: 'RB', x: 15.0, y: 25.0),
      FormationPositionModel(id: 0, role: 'CB', x: 38.0, y: 20.0),
      FormationPositionModel(id: 0, role: 'CB', x: 62.0, y: 20.0),
      FormationPositionModel(id: 0, role: 'LB', x: 85.0, y: 25.0),
      FormationPositionModel(id: 0, role: 'CM', x: 30.0, y: 45.0),
      FormationPositionModel(id: 0, role: 'CDM', x: 50.0, y: 40.0),
      FormationPositionModel(id: 0, role: 'CM', x: 70.0, y: 45.0),
      FormationPositionModel(id: 0, role: 'RW', x: 20.0, y: 75.0),
      FormationPositionModel(id: 0, role: 'ST', x: 50.0, y: 85.0),
      FormationPositionModel(id: 0, role: 'LW', x: 80.0, y: 75.0),
    ],
    '4-4-2': [
      FormationPositionModel(id: 0, role: 'GK', x: 50.0, y: 5.0),
      FormationPositionModel(id: 0, role: 'RB', x: 15.0, y: 25.0),
      FormationPositionModel(id: 0, role: 'CB', x: 38.0, y: 20.0),
      FormationPositionModel(id: 0, role: 'CB', x: 62.0, y: 20.0),
      FormationPositionModel(id: 0, role: 'LB', x: 85.0, y: 25.0),
      FormationPositionModel(id: 0, role: 'RM', x: 15.0, y: 50.0),
      FormationPositionModel(id: 0, role: 'CM', x: 40.0, y: 50.0),
      FormationPositionModel(id: 0, role: 'CM', x: 60.0, y: 50.0),
      FormationPositionModel(id: 0, role: 'LM', x: 85.0, y: 50.0),
      FormationPositionModel(id: 0, role: 'ST', x: 40.0, y: 80.0),
      FormationPositionModel(id: 0, role: 'ST', x: 60.0, y: 80.0),
    ],
    '3-5-2': [
      FormationPositionModel(id: 0, role: 'GK', x: 50.0, y: 5.0),
      FormationPositionModel(id: 0, role: 'CB', x: 30.0, y: 20.0),
      FormationPositionModel(id: 0, role: 'CB', x: 50.0, y: 20.0),
      FormationPositionModel(id: 0, role: 'CB', x: 70.0, y: 20.0),
      FormationPositionModel(id: 0, role: 'RWB', x: 10.0, y: 45.0),
      FormationPositionModel(id: 0, role: 'CM', x: 35.0, y: 50.0),
      FormationPositionModel(id: 0, role: 'CDM', x: 50.0, y: 40.0),
      FormationPositionModel(id: 0, role: 'CM', x: 65.0, y: 50.0),
      FormationPositionModel(id: 0, role: 'LWB', x: 90.0, y: 45.0),
      FormationPositionModel(id: 0, role: 'ST', x: 40.0, y: 80.0),
      FormationPositionModel(id: 0, role: 'ST', x: 60.0, y: 80.0),
    ],
  };
}
