enum DiaSemana {
  segunda,
  terca,
  quarta,
  quinta,
  sexta,
  sabado,
  domingo;

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
      case DiaSemana.domingo:
        return 'Domingo';
    }
  }

  String get sigla {
    switch (this) {
      case DiaSemana.segunda:
        return 'SEG';
      case DiaSemana.terca:
        return 'TER';
      case DiaSemana.quarta:
        return 'QUA';
      case DiaSemana.quinta:
        return 'QUI';
      case DiaSemana.sexta:
        return 'SEX';
      case DiaSemana.sabado:
        return 'SÁB';
      case DiaSemana.domingo:
        return 'DOM';
    }
  }
}