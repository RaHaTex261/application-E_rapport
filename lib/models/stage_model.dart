class Stage {
  final String id;
  final DateTime date;
  final String lieu;
  final String activites;
  final String competences;

  Stage({
    required this.id,
    required this.date,
    required this.lieu,
    required this.activites,
    required this.competences,
  });

  // Méthode pour convertir les données du stage en Map pour Firebase
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'lieu': lieu,
      'activites': activites,
      'competences': competences,
    };
  }

  // Méthode pour créer un objet Stage à partir d'un Map
  factory Stage.fromMap(Map<dynamic, dynamic> map, String id) {
    return Stage(
      id: id,
      date: DateTime.parse(map['date']),
      lieu: map['lieu'],
      activites: map['activites'],
      competences: map['competences'],
    );
  }
}
