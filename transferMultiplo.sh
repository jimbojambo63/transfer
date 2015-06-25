#!/bin/bash

#Questa versione dello script permette upload di file multipli tramite richiesta PUT http
#a tutte le destinazioni specificate o al server http://transfer.sh

#Curl offre upload con quasi tutti i protocolli esistenti. questo script evita di scrivere i suoi argomenti.

#Da implementare la gestione di upload diversi per destinazioni diverse.
#scrivere argWget() linea 82 per la versione con wget

#formato parametri: <source> [{dest}]
#FTP: gestire le destinazioni ftp trattate ora come http
#SCP: richiedere user e password/passphrase/publicKey


SH_PID=$$
SITO="https://transfer.sh/"
UTILIZZO="UTILIZZO: transfer.sh {<file da caricare>} {[url-destinazione]}\n\nSe la destinazione non è specificata i file verranno caricati su http://transfer.sh\n\ttransfer.sh <~/file_locale> <~/file_locale> ..\n\n altrimenti i file vengono inviati alle destinazioni specificate subito dopo\n\ttransfer.sh <~/file1_locale> <http://url.remoto.net> <~/file2_locale> <http://altro.url.com>\n\n È possibile inviare più file per destinazione elencando i file e specificando la destinazione \nsolo una volta, oppure inviare gli stessi file a più destinazioni specificandole sequenzialmente\n\ttransfer.sh <~/file_locale> <http://url.remoto.net> <http://altro.url.com> ..\n\nPer un utilizzo con maggiori configurazioni usare invece curl\n\n"


timer()
{   #timer [start|stop] <"stringa che precede conteggio">
    #quando lo si stoppa se si scrive testo subito prima di stopparlo il
    #conteggio viene sovrascritto, altrimenti subito dopo il contegio rimane
    #scritto nella riga precedente
    #NON SI PUÒ AVVIARE DUE TIMER CONTEMPORANEAMENTE
    case $1 in
    start | on)
      second=1
      introduz="$2"
      (while true
        do
          if [ ! -z $(ps -o pid= -p $SH_PID) ]
            then
              echo "$introduz  $second \r\c"
              second=$((second+1))
              sleep 1
            else
              exit
          fi
      done) &
        BG_PID=$!
    ;;
    stop | off)
        #eval chiusura="$(echo $2 | sed 's|%sec|$second|g')"
        chiusura=$2
        echo $chiusura
        kill -9 $BG_PID
    ;;
    esac
}

argCurl(){
					cont_path=$((cont_path-1))
					cont_dest=$((cont_dest-1))

					if [ "${#dest[@]}" -ge 1 ]
					then 
						#la destinazione è specificata

						for i in $(seq $cont_dest)
						do
							for a in $(seq $cont_path)
							do
								url=${dest[$i]}/${file[$a]}
								echo -n "-T ${path[$a]} $url "
							
							done
						done
					else 
						#la destinazione non è specificata
						#viene usata la destinazione default $SITO

						for n in $(seq $cont_path)
							do
								url=$SITO${file[$n]}
								echo -n "-T ${path[$n]} $url " 
							done
					fi
}

#argWget(){}


if [ "$#" -gt 0 ]
	then 
	#acquisizione dei parametri in tre vettori: dest[], path[], file[]
	#########################

	cont_path=1
	cont_dest=1
	for cont in `seq $#`
	do
		case $1 in
		http://*|https://*)		dest[$cont_dest]=$1
								cont_dest=$((cont_dest+1))

								#num_path_dest è un array che tiene conto per ogni destinazione
								#quanti file gli vengono inviati. verrebbe utilizzato nella costruzione
								#degli argomenti di curl
								num_path_dest[$cont_dest]=$cont_path

								
		;;
		ftp://*)				dest[$cont_dest]=$1
								cont_dest=$((cont_dest+1))
							
								num_path_dest[$cont_dest]=$cont_path


		;;
		*)
					path[$cont_path]=$1
    				file[$cont_path]=$(basename "${path[$cont_path]}" | sed -e 's/[^a-zA-Z0-9._-]/-/g')
					cont_path=$((cont_path+1))
		;;
		esac		

		shift
	done
	########################


	#upload dei file con curl o se assente wget
	###############

    link=$( mktemp -t transferXXX )

	if [ -f "$(which curl)" ]
    then
		
		argomentiCurl=$(argCurl)

		#--progress-bar sostituito con '-#', aggiunto --conect-timeout 5 per rinunciare
		#a stabilire una connessione con un server che non risponde dopo 5 secondi
		#invece --connect-timeout non funziona, pare che non si limiti a contare il tempo di connessione

		curl -# $(echo "$argomentiCurl") > $link
    else
		
		#argomentiWget=$(argWget)

       	timer start "upload in corso:    sec  "
       	wget --method PUT --body-file="$path[1]" "$url[1]" -q -O - > $link \
       	&& timer stop "upload terminato in"
    fi
    ###############

		if [ -s $link ]; then cat $link; else echo "niente è stato caricato"; fi
 
else  printf "$UTILIZZO"
fi
exit
