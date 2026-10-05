import 'package:flutter_test/flutter_test.dart';

abstract class Pessoa {
  late int _id;
  String nome;

  Pessoa(this.nome);

  int get id => _id;

  set id(int id) {
    if (id > 0) {
      _id = id;
    } else {
      throw ArgumentError('Identificador deve ser não negativo.');
    }
  }
}

mixin Ano {
  late int _ano;

  int get ano => _ano;

  set ano(int ano) {
    if (ano > 0) {
      _ano = ano;
    } else {
      throw ArgumentError('Ano deve ser não negativo.');
    }
  }
}

class Professor extends Pessoa {
  Professor(super.nome);
}

class Aluno extends Pessoa with Ano {
  Aluno(super.nome, int ano) {
    this.ano = ano;
  }
}

class Disciplina {
  String nome;
  Disciplina(this.nome);
}

class Turma with Ano {
  Disciplina disciplina;
  Professor professor;
  final List<Aluno> _alunos = [];

  Turma(this.disciplina, this.professor, int ano) {
    this.ano = ano;
  }

  void matricular(Aluno aluno) {
    if (aluno.ano == ano) {
      _alunos.add(aluno);
    } else {
      throw ArgumentError('Ano deve ser mesmo.');
    }
  }
}

class Historico extends Turma {
  Map<Aluno, List<double>> notas = {};

  Historico(super.disciplina, super.professor, super.ano);

  @override
  void matricular(Aluno aluno) {
    super.matricular(aluno);
    notas[aluno] = [];
  }

  double media(Aluno aluno) {
    final lista = notas[aluno]!;
    if (lista.isEmpty) return 0.0; // evita 0/0 = NaN

    double media = 0;
    for (double nota in lista) {
      media += nota;
    }
    media /= lista.length;
    return media;
  }

  bool isAprovado(Aluno aluno) {
    return media(aluno) > 6;
  }
}

void main() {
  test('Testar matrícula de alunos', () {
    Disciplina disciplina1 = Disciplina('Flutter');
    Professor professor1 = Professor('Walber');
    professor1.id = 10;
    Historico historico1 = Historico(disciplina1, professor1, 2023);

    // Cadastrar primeiro aluno sem erros
    Aluno aluno1 = Aluno('Maria', 2023);
    aluno1.id = 1;
    historico1.matricular(aluno1);
    expect(historico1.media(aluno1), 0.0);
    expect(historico1.isAprovado(aluno1), isFalse);

    // Cadastrar segundo aluno com erros
    Aluno aluno2 = Aluno('Paula', 2022);
    expect(() => aluno2.id = 0, throwsArgumentError);
    expect(() => historico1.matricular(aluno2), throwsArgumentError);
  });

  test('Testar aprovação', () {
    Historico historico = Historico(
      Disciplina('Flutter'),
      Professor('Walber'),
      2023,
    );

    Aluno aprovado = Aluno('Maria', 2023);
    Aluno reprovado = Aluno('João', 2023);
    historico.matricular(aprovado);
    historico.matricular(reprovado);

    historico.notas[aprovado]!.addAll([8.0, 7.0]);   // média 7.5
    historico.notas[reprovado]!.addAll([4.0, 5.0]);  // média 4.5

    expect(historico.media(aprovado), 7.5);
    expect(historico.isAprovado(aprovado), isTrue);
    expect(historico.isAprovado(reprovado), isFalse);
  });
}