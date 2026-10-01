import '../models/story_config.dart';

class StoryBuilder {
  static List<StoryPageData> build(StoryConfig config) {
    final name = config.childName.trim().isEmpty
        ? _defaultNameFor(config.protagonist)
        : config.childName.trim();
    final friendPhrase = _friendPhrase(config.friends);
    final primaryFriend = config.friends.isEmpty ? 'un piccolo amico' : config.friends.first.toLowerCase();

    return [
      StoryPageData(
        title: 'Una luce misteriosa',
        emoji: _settingEmoji(config.setting),
        sceneLabel: config.setting,
        imageAsset: 'assets/images/01_luce_misteriosa.png',
        text:
            'C\'era una volta $name, ${_articleFor(config.protagonist)} ${config.protagonist.toLowerCase()} dal cuore curioso. '
            'Un giorno, mentre esplorava ${_settingPhrase(config.setting)}, vide una luce dorata danzare tra le ombre. '
            '$friendPhrase decise di seguirla insieme a lui. La luce sembrava voler indicare l\'inizio di una grande avventura.',
      ),
      StoryPageData(
        title: 'Il sentiero segreto',
        emoji: primaryFriend == 'cagnolino' ? '🐶' : '✨',
        sceneLabel: 'Il viaggio comincia',
        imageAsset: 'assets/images/02_sentiero_segreto.png',
        text:
            'Seguendo piccoli segni luminosi, $name e i suoi amici trovarono un sentiero nascosto. '
            'Ogni passo faceva brillare il terreno come polvere di stelle. $primaryFriend si fermò all\'improvviso: '
            'davanti a loro c\'era una porta antichissima, chiusa da un simbolo che nessuno aveva mai visto prima.',
      ),
      StoryPageData(
        title: 'L\'incontro inatteso',
        emoji: _villainEmoji(config.villain),
        sceneLabel: config.villain,
        imageAsset: 'assets/images/03_incontro_inatteso.png',
        text:
            'Dietro la porta apparve ${_articleFor(config.villain)} ${config.villain.toLowerCase()}. '
            'Sembrava minaccioso, ma $name si accorse subito che qualcosa non tornava. '
            'Il suo sguardo non era cattivo: era triste. Aveva perso un oggetto prezioso e, per paura, aveva chiuso ogni passaggio del regno.',
      ),
      StoryPageData(
        title: 'La prova del coraggio',
        emoji: '🗝️',
        sceneLabel: 'La chiave incantata',
        imageAsset: 'assets/images/04_prova_del_coraggio.png',
        text:
            '$name decise di aiutare invece di scappare. Insieme a $friendPhrase, attraversò un ponte di nuvole, '
            'risolse un piccolo enigma e trovò una chiave dorata nascosta sotto una pietra che cantava. '
            'La chiave aprì uno scrigno pieno di luce: dentro c\'era proprio ciò che ${config.villain.toLowerCase()} stava cercando.',
      ),
      StoryPageData(
        title: 'Un nuovo amico',
        emoji: '🤝',
        sceneLabel: 'La sorpresa',
        imageAsset: 'assets/images/05_nuovo_amico.png',
        text:
            'Quando $name restituì l\'oggetto, ${config.villain.toLowerCase()} sorrise per la prima volta. '
            'Capì che non serviva spaventare gli altri per essere ascoltati. Le porte del regno si riaprirono e tutti festeggiarono insieme, '
            'con musica, lanterne e dolci profumati.',
      ),
      StoryPageData(
        title: 'Il ritorno a casa',
        emoji: '🌙',
        sceneLabel: 'Buonanotte',
        imageAsset: 'assets/images/06_ritorno_a_casa.png',
        text:
            'Quella sera $name tornò a casa con il cuore pieno di felicità. Aveva scoperto che il coraggio non significa non avere paura, '
            'ma scegliere di fare la cosa giusta anche quando qualcosa sembra difficile. '
            'E mentre le stelle brillavano sopra ${_settingPhrase(config.setting)}, $name chiuse gli occhi e sorrise. Fine.',
      ),
    ];
  }

  static String _defaultNameFor(String protagonist) {
    final lower = protagonist.toLowerCase();
    if (lower.contains('bambina') || lower.contains('principessa') || lower.contains('fatina')) {
      return 'Sofia';
    }
    return 'Leo';
  }

  static String _articleFor(String value) {
    final lower = value.toLowerCase();
    if (lower.startsWith('a') || lower.startsWith('e') || lower.startsWith('i') || lower.startsWith('o') || lower.startsWith('u')) {
      return 'un';
    }
    if (lower.contains('bambina') ||
        lower.contains('principessa') ||
        lower.contains('fatina') ||
        lower.contains('strega') ||
        lower.contains('scimmietta')) {
      return 'una';
    }
    return 'un';
  }

  static String _friendPhrase(List<String> friends) {
    if (friends.isEmpty) return 'un piccolo compagno di viaggio';
    if (friends.length == 1) return 'il suo ${friends.first.toLowerCase()}';
    if (friends.length == 2) {
      return 'i suoi amici ${friends.first.toLowerCase()} e ${friends.last.toLowerCase()}';
    }
    final allButLast = friends.sublist(0, friends.length - 1).map((e) => e.toLowerCase()).join(', ');
    return 'i suoi amici $allButLast e ${friends.last.toLowerCase()}';
  }

  static String _settingPhrase(String setting) {
    switch (setting) {
      case 'Castello':
        return 'il castello incantato';
      case 'Foresta':
        return 'la foresta magica';
      case 'Mondo di caramelle':
        return 'il mondo delle caramelle';
      case 'Spazio':
        return 'lo spazio tra pianeti luminosi';
      case 'Casa nel bosco':
        return 'la casa nel bosco';
      case 'Regno sottomarino':
        return 'il regno sottomarino';
      case 'Isola misteriosa':
        return 'l\'isola misteriosa';
      case 'Regno di ghiaccio':
        return 'il regno di ghiaccio';
      default:
        return setting.toLowerCase();
    }
  }

  static String _settingEmoji(String setting) {
    return switch (setting) {
      'Castello' => '🏰',
      'Foresta' => '🌲',
      'Mondo di caramelle' => '🍭',
      'Spazio' => '🚀',
      'Casa nel bosco' => '🏡',
      'Regno sottomarino' => '🌊',
      'Isola misteriosa' => '🏝️',
      'Regno di ghiaccio' => '❄️',
      _ => '✨',
    };
  }

  static String _villainEmoji(String villain) {
    return switch (villain) {
      'Strega' => '🧙‍♀️',
      'Drago' => '🐉',
      'Mago cattivo' => '🧙‍♂️',
      'Faraone' => '👑',
      'Orco' => '👹',
      'Fantasma dispettoso' => '👻',
      _ => '🌀',
    };
  }
}
