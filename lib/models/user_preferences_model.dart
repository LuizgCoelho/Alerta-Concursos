class UserPreferencesModel {
  final String nome;
  final String telefone;
  final String areaInteresse;
  final String estadoUf;
  final String escolaridade;
  final bool optIn;

  UserPreferencesModel({
    required this.nome,
    required this.telefone,
    required this.areaInteresse,
    required this.estadoUf,
    required this.escolaridade,
    required this.optIn,
  });

  // Converte o objeto para um Map pronto para o Supabase (INSERT)
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'telefone': telefone,
      'area_interesse': areaInteresse,
      'estado_uf': estadoUf,
      'escolaridade': escolaridade,
      'opt_in': optIn,
    };
  }
}