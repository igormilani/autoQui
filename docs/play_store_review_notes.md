# Play Store Review Notes - AutoQui

Ultimo aggiornamento: 25 maggio 2026

Checklist interna per preparare la revisione Google Play.

## Video demo da registrare

- Mostrare la schermata iniziale con disclosure privacy/permessi.
- Toccare "Continua" e mostrare la richiesta permessi Android.
- Mostrare l'abilitazione del rilevamento automatico.
- Simulare o mostrare uscita dall'auto.
- Mostrare la notifica locale di possibile parcheggio.
- Toccare "Salva" sulla notifica.
- Riaprire AutoQui e mostrare il parcheggio salvato sulla mappa.
- Toccare "Vai all'auto" e mostrare l'apertura della navigazione.
- Mostrare la schermata "Privacy e Permessi".
- Mostrare come disattivare rilevamento automatico e notifiche.

## Screenshot necessari

- Home con mappa e pulsanti principali.
- Stato con auto parcheggiata salvata.
- Dialog disclosure prima dei permessi.
- Schermata "Privacy e Permessi".
- Sezione info batteria/background.
- Eventuale notifica di parcheggio rilevato.

## Permessi richiesti

- ACCESS_COARSE_LOCATION
- ACCESS_FINE_LOCATION
- ACCESS_BACKGROUND_LOCATION
- ACTIVITY_RECOGNITION
- POST_NOTIFICATIONS
- FOREGROUND_SERVICE
- FOREGROUND_SERVICE_LOCATION
- INTERNET per Google Maps e AdMob

## Core functionality

AutoQui consente di salvare la posizione del parcheggio, ritrovare l'auto su mappa e rilevare automaticamente un possibile parcheggio tramite posizione, rilevamento attivita e notifiche locali.

## Note operative

- Verificare che la privacy policy pubblica sia raggiungibile da URL prima della pubblicazione.
- Verificare che la Data Safety di Play Console includa anche i dati trattati dagli SDK Google Maps e AdMob.
- Preparare una descrizione breve e coerente per la richiesta background location.
- Usare device reale Android 11+ per testare il flusso background location.
