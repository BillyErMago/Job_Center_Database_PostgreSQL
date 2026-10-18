-- Funzione che calcola la differenza tra una data passata e la data corrente
CREATE OR REPLACE FUNCTION datediff (
    date_part VARCHAR(30),
    start_t TIMESTAMP,
    end_t TIMESTAMP
)
RETURNS INT AS $diff$
DECLARE
    years INT = 0;
    days INT = 0;
    hours INT = 0;
    minutes INT = 0;
BEGIN
    years = DATE_PART('year', end_t) - DATE_PART('year', start_t);
    IF date_part IN ('y', 'yr', 'yrs', 'year', 'years') THEN
        RETURN years;
    END IF;
    IF date_part IN ('quarter', 'quarters', 'qtr', 'qtrs') THEN
        RETURN years * 4 + (DATE_PART('quarter', end_t) - DATE_PART('quarter', start_t));
    END IF;
    IF date_part IN ('month', 'months', 'mon', 'mons') THEN
        RETURN years * 12 + (DATE_PART('month', end_t) - DATE_PART('month', start_t));
    END IF;
    IF date_part IN ('week', 'weeks', 'w') THEN
        RETURN DATE_PART('day', (DATE_TRUNC('week', end_t) - DATE_TRUNC('week', start_t)) / 7);
    END IF;
    days = DATE_PART('day', DATE_TRUNC('day', end_t) - DATE_TRUNC('day', start_t));
    IF date_part IN ('day', 'days', 'd') THEN
        RETURN days;
    END IF;
    hours = days * 24 + (DATE_PART('hour', end_t) - DATE_PART('hour', start_t));
    IF date_part IN ('hour', 'hours', 'h', 'hr', 'hrs') THEN
        RETURN hours;
    END IF;
    minutes = hours * 60 + (DATE_PART('minute', end_t) - DATE_PART('minute', start_t));
    IF date_part IN ('minute', 'minutes', 'm', 'min', 'mins') THEN
        RETURN minutes;
    END IF;
    IF date_part IN ('second', 'seconds', 's', 'sec', 'secs') THEN
        RETURN minutes * 60 + (DATE_PART('second', end_t) - DATE_PART('second', start_t));
    END IF;
    RETURN 0;
END;
$diff$ LANGUAGE plpgsql;

-- Funzione utilizzata per controllare se un cittadino è inoccupato o no
CREATE OR REPLACE FUNCTION public.check_disoccupato(
    cf_cittadino character
)
RETURNS boolean
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    RETURN (SELECT cittadino.stato_inoccupato FROM cittadino
            WHERE cittadino.cfcittadino = cf_cittadino);
END
$BODY$;

-- Funzione utilizzata per eliminare il personale
CREATE OR REPLACE FUNCTION public.aggpersonale(
    mat numeric,
    np character varying,
    cp character varying,
    stip numeric,
    orait time with time zone,
    oraft time with time zone,
    cfp character varying,
    uff character varying
)
RETURNS void
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    nome int;
BEGIN
    SELECT n_dipendenti INTO nome FROM ufficio
    WHERE uff = ufficio.nomeufficio;
    INSERT INTO personale VALUES (mat, np, cp, stip, orait, oraft, cfp, uff);
    UPDATE ufficio SET n_dipendenti = nome + 1 WHERE nomeufficio = uff;
END
$BODY$;

-- Funzione utilizzata per aggiungere un nuovo ufficio
CREATE OR REPLACE FUNCTION public.aggufficio(
    nomeuff character varying,
    capouff numeric
)
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
    ELSEIF NOT EXISTS (SELECT ufficio.capoufficio FROM ufficio
                       WHERE ufficio.capoufficio = capouff) THEN
        SELCT nomeufficio INTO nomeu FROM personale, ufficio WHERE
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

-- Funzione utilizzata per aggiungere il personale
CREATE OR REPLACE FUNCTION public.aggpersonale(
    mat numeric,
    np character varying,
    cp character varying,
    stip numeric,
    orait time with time zone,
    oraft time with time zone,
    cfp character varying,
    uff character varying
)
RETURNS void
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    nome int;
BEGIN
    SELECT n_dipendenti INTO nome FROM ufficio WHERE
        uff = ufficio.nomeufficio;
    INSERT INTO personale VALUES (mat, np, cp, stip, orait, oraft, cfp, uff);
    UPDATE ufficio SET n_dipendenti = nome + 1 WHERE nomeufficio = uff;
END
$BODY$;


