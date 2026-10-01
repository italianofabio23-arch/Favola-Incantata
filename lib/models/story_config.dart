class StoryConfig {
  StoryConfig({
    required this.childName,
    required this.protagonist,
    required this.setting,
    required this.villain,
    required this.friends,
    required this.voice,
    required this.length,
  });

  final String childName;
  final String protagonist;
  final String setting;
  final String villain;
  final List<String> friends;
  final String voice;
  final String length;
}

class StoryPageData {
  const StoryPageData({
    required this.title,
    required this.text,
    required this.emoji,
    required this.sceneLabel,
    this.imageAsset,
  });

  final String title;
  final String text;
  final String emoji;
  final String sceneLabel;

  // Immagine illustrata della pagina
  final String? imageAsset;
}
