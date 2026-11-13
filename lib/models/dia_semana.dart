enum DiaSemana {
  segunda,
  terca,
  quarta,
  quinta,
  sexta,
  sabado;

  String get label {
    switch (this) {
      case DiaSemana.segunda:
        return 'Segunda-feira';
      case DiaSemana.terca:
        return 'Terça-feira';
      case DiaSemana.quarta:
        return 'Quarta-feira';
      case DiaSemana.quinta:
        return 'Quinta-feira';
      case DiaSemana.sexta:
        return 'Sexta-feira';
      case DiaSemana.sabado:
        return 'Sábado';
    }
  }
}