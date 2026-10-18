-- OP1: Aggiunta di un nuovo cittadino indicando tutti i suoi dati
INSERT INTO CITTADINO ("cfcittadino", "nomec", "cognomec",
    "sesso", "datan", "nomevia", "civico", "citta", "email",
    "telefono", "cap", "stato_inoccupato")
VALUES ('DCRFNC80D45H456T', 'De Caro', 'Francesco', 'm',
    '1980-04-05', 'Via Betarice', 23, 'Perugia',
    'fra_dec@libero.it', 3425723765, '06250', true);

-- OP2: Aggiunta di una nuova azienda indicando i suoi dati
INSERT INTO AZIENDA ("p_iva", "nomea", sedelegale,
    "statoattivita", "num_dipendenti", "settore")
VALUES (02633000423, 'Fusiera S.p.a', 'Ancona', 'Attivo', 58,
    'Fonditoria');

-- OP3: Aggiunta di un nuovo ufficio
CREATE OR REPLACE FUNCTION public.aggufficio(
    nomeuff character varying,
    capouff numeric)
RETURNS void
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    conta int;
    nomeu character varying;
BEGIN
    IF (capouff IS NULL) THEN
        INSERT INTO ufficio VALUES (nomeuff, 0, capouff);
    ELSIF NOT EXISTS (SELECT ufficio.capoufficio FROM ufficio
        WHERE ufficio.capoufficio = capouff) THEN
        SELECT nomeufficio INTO nomeu FROM personale, ufficio WHERE
            matricola = capouff AND personale.ufficio = ufficio.nomeufficio;
        SELECT n_dipendenti INTO conta FROM personale, ufficio WHERE
            matricola = capouff AND personale.ufficio = ufficio.nomeufficio;
        UPDATE ufficio SET n_dipendenti = conta - 1 WHERE
            nomeufficio = nomeu;
        INSERT INTO ufficio VALUES (nomeuff, 0, capouff);
        UPDATE personale SET ufficio = nomeuff WHERE matricola = capouff;
        UPDATE ufficio SET n_dipendenti = 1 WHERE
            ufficio.nomeufficio = nomeuff;
    ELSE
        RAISE EXCEPTION 'il capo ufficio inserito già afferisce ad un altro ufficio';
    END IF;
END
$BODY$;

-- OP4: Aggiunta di un nuovo corso
INSERT INTO CORSO ("nomecorso", "enteformativo",
    "tiposervizioerogato")
VALUES ('Beverage specialist', 'Business school', 'Corso di formazione');

-- OP5: Aggiunta di un nuovo dipendente indicato i suoi dati
CREATE FUNCTION aggPersonale (mat numeric, np character varying,
    cp character varying, stip numeric, orait time with time zone,
    oraft time with time zone, cfp character varying,
    uff character varying)
RETURNS void AS
$BODY$
DECLARE
    nome int;
BEGIN
    SELECT n_dipendenti INTO nome FROM ufficio WHERE
        uff = ufficio.nomeufficio;
    INSERT INTO personale VALUES (mat, np, cp, stip, orait,
        oraft, cfp, uff);
    UPDATE ufficio SET n_dipendenti = nome + 1 WHERE nomeufficio = uff;
END
$BODY$
LANGUAGE plpgsql VOLATILE;

-- OP6: Permettere al cittadino la richiesta di un’occupazione mediante DID
INSERT INTO DID ("codicedid", "datastipuladid",
    "settore_occupazione", "cittadino", "ufficio")
VALUES (000001, '2017-09-11', 'Muratura', 'CVRRNS91D23G146W',
    'Assunzione');

-- OP7: Permettere alle aziende la ricerca di personale mediante DIA
INSERT INTO DIA("codicedia", "datastipuladia",
    "n_postirichiesti", "ufficio", "azienda")
VALUES (7, '2021-11-01', 5, 'Assunzione', 78945612302);

-- OP8: Aggiungi esperienza lavorativa al cittadino
INSERT INTO esperienza_passata VALUES (7, 'Licenziamento',
    '2019-12-01', '2020-09-11', 'Fabbro', 'BRECLL87R19D765E');

-- OP9: Modifica dati relativi al numero dei dipendenti di un’azienda
UPDATE azienda SET num_dipendenti = 12
WHERE p_iva = 12323568974;

-- OP10: Modifica capo di un ufficio
UPDATE ufficio SET capoufficio = 123
WHERE nomeufficio = 'Accoglienza';

-- OP11: Modifica dati relativi al personale
UPDATE personale SET stipendio = 1200
WHERE matricola = 123;

-- OP12: Modifica stato di attività di un’azienda
UPDATE azienda SET statoattivita = 'non attivo'
WHERE p_iva = 12633000423;

-- OP13: Elimina un cittadino
DELETE FROM cittadino
WHERE cfcittadino = 'ALBTMS78H15P536T';

-- OP14: Elimina un corso
DELETE FROM corso
WHERE NomeCorso = 'Beverage specialist';

-- OP15: Elimina un dipendente
CREATE OR REPLACE FUNCTION public.eliminapersonale(
    mat numeric)
RETURNS void
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    nome int;
    uff varchar;
BEGIN
    SELECT ufficio INTO uff FROM personale WHERE
        personale.matricola = mat;
    SELECT n_dipendenti INTO nome FROM ufficio WHERE
        ufficio.nomeufficio = uff;
    UPDATE ufficio SET n_dipendenti = nome - 1 WHERE nomeufficio = uff;
    DELETE FROM personale WHERE personale.matricola = mat;
END
$BODY$;

-- OP16: Stampa tutti i servizi per i cittadini
SELECT servizio_di_formazione.nomeservizio
FROM servizio_di_formazione
UNION
SELECT servizio_di_ufficio.nomeservizio
FROM servizio_di_ufficio;

-- OP17: Stampa tutti i servizi per le aziende
SELECT servizio_azienda.nomeservizio
FROM servizio_azienda;

-- OP18: Per ogni ufficio visualizzare il capo e il numero di impiegati
SELECT nomeufficio, n_dipendenti, cognomep AS capoUfficio
FROM ufficio, personale
WHERE capoufficio = matricola;

-- OP19: Visualizzare la data di fine rapporto lavorativo dei cittadini disoccupati
SELECT nomec AS nome, cognomec AS cognome, datafine
FROM esperienza_passata, cittadino
WHERE cittadino = cfcittadino AND datafine IN (SELECT
        MAX(datafine)
    FROM esperienza_passata
    GROUP BY cittadino);

-- OP20: Contare il numero di posti lavorativi disponibili in un certo settore
SELECT azienda.settore, SUM(n_postirichiesti) AS numero_posti_richiesti
FROM dia, azienda
WHERE dia.azienda = azienda.p_iva AND
    azienda.settore = 'Elettronica'
GROUP BY azienda.settore;

-- OP21: Contare i posti lavorativi disponibili per ogni azienda
SELECT azienda.nomea, SUM(n_postirichiesti) AS numero_posti_richiesti
FROM dia, azienda
WHERE dia.azienda = azienda.p_iva
GROUP BY azienda.nomea;

-- OP22: Selezionare i titoli di studio dei cittadini in cerca di occupazione per un dato settore
SELECT cittadino.nomec, cittadino.cognomec, attesta.grado,
    attesta.corso
FROM cittadino, attesta, did
WHERE did.cittadino = attesta.cittadino AND did.cittadino =
    cittadino.cfcittadino AND did.settore_occupazione = 'Edilizia';

-- OP23: Mostrare codice fiscale, nome e cognome dei cittadini che hanno avuto più esperienze lavorative rispetto agli altri
SELECT cfcittadino, nomec, cognomec
FROM cittadino
WHERE cfcittadino IN (
    SELECT cittadino
    FROM esperienza_passata GROUP BY cittadino
    HAVING COUNT(*) >= ALL (SELECT COUNT(*)
        FROM esperienza_passata
        GROUP BY cittadino));

-- OP24: Mostrare il codice fiscale dei cittadini che hanno richiesto più di 1 servizio nel 2021
CREATE OR REPLACE VIEW v1 AS
SELECT codicerichiestac, cittadino
FROM richiesta_servizio_cittadino AS RSC
WHERE RSC.datarichiestac BETWEEN '2021-01-01' AND '2021-12-31';

SELECT cittadino, nomec, cognomec,
    COUNT(codicerichiestac) AS ServiziRichiesti
FROM v1 JOIN cittadino AS citt
    ON v1.cittadino = citt.cfcittadino
GROUP BY cittadino, nomec, cognomec
HAVING COUNT(codicerichiestac) > 1;

-- OP25: Mostrare l'ufficio che spende di meno in stipendi per il proprio personale ad eccezione del capo
CREATE OR REPLACE VIEW v2 AS
SELECT matricola, ufficio, stipendio
FROM personale
WHERE matricola <> ALL (SELECT capoufficio
    FROM ufficio);

CREATE OR REPLACE VIEW stipendio_erogato_ufficio (uff, spesa)
AS
SELECT ufficio, SUM(stipendio)
FROM v2
GROUP BY ufficio;

SELECT uff, spesa
FROM stipendio_erogato_ufficio
WHERE spesa = (SELECT MIN(spesa)
    FROM stipendio_erogato_ufficio);

-- OP26: Contare i cittadini in cerca di occupazione per settore
SELECT did.settore_occupazione, COUNT(did.cittadino) AS numero_cittadini
FROM did
GROUP BY did.settore_occupazione;

-- OP27: Mostrare i corsi di formazione
SELECT nomecorso, enteformativo AS Ente
FROM corso;

-- OP28: Visualizzare nome e cognome dei cittadini che hanno frequentato dei corsi
SELECT nomec, cognomec, nomecorso
FROM cittadino, partecipazione_passata
WHERE cfcittadino = cittadino;

-- OP29: Visualizzare gli orari di lavoro del personale
SELECT nomep, cognomep, orainizioturno, orafineturno
FROM personale;