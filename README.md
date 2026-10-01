# Favola Incantata V1

Starter Flutter per una app di favole personalizzate per bambini.

## Cosa contiene già

- Home con sfondo blu/notturno e libro magico animato.
- Creazione favola con:
  - nome protagonista;
  - protagonista;
  - ambientazione;
  - cattivo;
  - fino a 3 amici di viaggio;
  - voce Mamma / Nonna;
  - durata.
- Generatore locale di una storia demo coerente con le scelte.
- Libro animato con cambio pagina 3D.
- Scena illustrata che cambia a ogni pagina.
- Testo della storia sulla pagina opposta.
- Narrazione TTS italiana con flutter_tts.
- Avanzamento automatico alla pagina successiva al termine della lettura.
- Play/stop, pagina precedente/successiva e toggle "Auto pagina".

## Come avviarlo

1. Installa Flutter e Android Studio.
2. Apri un terminale nella cartella del progetto.
3. Esegui:

```bash
flutter pub get
flutter run
```

## Nota sulle voci

In questa V1 "Mamma" e "Nonna" usano il motore TTS installato sul telefono, con velocità e tono diversi.
Per la versione pubblicabile verranno sostituite/affiancate da voci neurali più realistiche.

## Prossimo step previsto

- collegare un backend AI per generare davvero una storia nuova a ogni combinazione;
- generare una vera illustrazione per ogni scena mantenendo coerenti personaggi e stile;
- cache di immagini/audio;
- salvataggio "Le mie favole";
- area genitori;
- profilo bambino e fascia d'età;
- musica ed effetti sonori delicati.
