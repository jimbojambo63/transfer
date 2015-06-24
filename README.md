# transferMultiplo.sh

#Questa versione dello script permette upload di file multipli tramite richiesta PUT http
#a tutte le destinazioni specificate o al server http://transfer.sh

#Curl offre upload con quasi tutti i protocolli esistenti. questo script evita di scrivere i suoi argomenti.

#Da implementare la gestione di upload diversi per destinazioni diverse.
#scrivere argWget() linea 82 per la versione con wget

#formato parametri: <source> [{dest}]
#FTP: gestire le destinazioni ftp trattate ora come http
#SCP: richiedere user e password/passphrase/publicKey


UTILIZZO: 
transferMultiplo.sh {<file da caricare>} {[url-destinazione]}

Se la destinazione non è specificata i file verranno caricati su http://transfer.sh
	transferMultiplo.sh <~/file_locale> <~/file_locale> ..

altrimenti i file vengono inviati alle destinazioni specificate subito dopo
	transferMultiplo.sh <~/file1_locale> <http://url.remoto.net> <~/file2_locale> <http://altro.url.com>
	
È possibile inviare più file per destinazione elencando i file e specificando la destinazione 
solo una volta, oppure inviare gli stessi file a più destinazioni specificandole sequenzialmente
	transferMultiplo.sh <~/file_locale> <http://url.remoto.net> <http://altro.url.com> ..
	
Per un utilizzo con maggiori configurazioni usare invece curl
