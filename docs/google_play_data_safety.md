# Google Play Data Safety - AutoQui

Ultimo aggiornamento: 25 maggio 2026

Documento tecnico di preparazione alla compilazione della sezione Data Safety di Google Play Console.

## Dati usati direttamente da AutoQui

| Categoria | Dato | Uso | Raccolta backend AutoQui | Condivisione applicativa |
| --- | --- | --- | --- | --- |
| Posizione | Posizione approssimativa | Localizzare l'utente e salvare il parcheggio | No | No |
| Posizione | Posizione precisa | Salvare e ritrovare l'auto con maggiore precisione | No | No |
| Attivita fisica | Activity Recognition | Rilevare possibile discesa dall'auto | No | No |
| Notifiche | Notifiche locali | Avvisare di un possibile parcheggio rilevato | No | No |

## Dichiarazioni tecniche

- AutoQui non ha backend proprietario.
- AutoQui non invia dati di posizione a server AutoQui.
- AutoQui non vende dati dell'utente.
- AutoQui salva il parcheggio localmente sul dispositivo.
- AutoQui usa i permessi posizione e activity recognition per la funzionalita principale di rilevamento parcheggio.
- AutoQui usa notifiche locali per confermare o ignorare un parcheggio rilevato.

## SDK di terze parti

### Google Maps SDK

Google Maps SDK e usato per mostrare mappe e marker del parcheggio. Il trattamento dei dati da parte di Google dipende dal funzionamento degli SDK Google e dalle impostazioni dell'utente.

### Google Mobile Ads SDK / AdMob

AdMob e usato per mostrare annunci. Secondo la documentazione Google, Google Mobile Ads SDK puo raccogliere dati quali identificatori del dispositivo o advertising ID, dati pubblicitari, diagnostica e altri dati tecnici necessari all'erogazione degli annunci.

Per la compilazione finale della Data Safety, verificare sempre la pagina ufficiale aggiornata di Google:

- https://developers.google.com/admob/android/privacy/play-data-disclosure
- https://support.google.com/googleplay/android-developer/answer/10787469

## Note per Play Console

- Dichiarare l'uso della posizione approssimativa e precisa.
- Dichiarare l'uso di Activity Recognition se richiesto nella sezione permessi o policy.
- Dichiarare l'uso di notifiche locali dove pertinente.
- Dichiarare AdMob e i dati raccolti/condivisi dal Google Mobile Ads SDK secondo la documentazione Google aggiornata.
- Allineare privacy policy, Data Safety e permessi nel manifest.
