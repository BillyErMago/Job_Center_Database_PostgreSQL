-- CITTADINO:
CREATE TABLE public."Cittadino"(
    "CFCittadino" character varying(16) NOT NULL,
    "NomeC" character varying(20),
    "CognomeC" character varying(20),
    "Sesso" character varying(1),
    "DataN" date,
    "NomeVia" character varying(50),
    "Civico" numeric(4, 0),
    "Cap" numeric(10, 0),
    "Citta" character varying(20),
    "Email" character varying(20),
    "Telefono" numeric(15, 0),
    CONSTRAINT "Cittadino_pkey" PRIMARY KEY ("CFCittadino"),
    CONSTRAINT "Cittadino_DataN_check"
        CHECK ((datediff('hour'::character varying
            "DataN"::timestamp without time zone,
            CURRENT_DATE::timestamp without time zone) / 8766) > 17),
    CONSTRAINT "Cittadino_DataN_check1" CHECK
        ((datediff('hour'::character varying, "DataN"::timestamp
            without time zone, CURRENT_DATE::timestamp without time
            zone) / 8766) < 66)
    CONSTRAINT cittadino_cf_check
        CHECK (char_length(cfcittadino) = 16) NOT VALID,
    CONSTRAINT cittadino_cap_check
        CHECK (char_length(cap) = 5) NOT VALID
)

-- CONOSCENZE_LINGUISTICHE:
CREATE TABLE public."Conoscenze_Linguistiche"(
    "Lingua" character varying(20) NOT NULL unique,
    "Livello" character varying(3) NOT NULL unique,
    CONSTRAINT "Conoscenze_Linguistiche_pkey"
        PRIMARY KEY ("Lingua", "Livello")
)

--TITOLO_STUDIO:
CREATE TABLE public."Titolo_di_studio"(
    "Grado" character varying(20) NOT NULL unique,
    "Corso" character varying(20) NOT NULL unique,
    CONSTRAINT "Titolo_di_studio_pkey"
        PRIMARY KEY ("Grado", "Corso")
)

--CONOSCENZE_INFORMATICHE:
CREATE TABLE public."Conoscenze_informatiche"(
    "Descrizione" character varying(200) NOT NULL,
    CONSTRAINT "Conoscenze_informatiche_pkey"
        PRIMARY KEY ("Descrizione")
)

--DISOCCUPATO:
CREATE TABLE public."Disoccupato"(
    "CFCittadino" character varying(16) NOT NULL,
    CONSTRAINT "Disoccupato_pkey"
        PRIMARY KEY ("CFCittadino"),
    CONSTRAINT "Disoccupato_CFCittadino_fkey"
        FOREIGN KEY ("CFCittadino")
            REFERENCES public."Cittadino" ("CFCittadino")
            MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE CASCADE
)

--ESPERIENZA_PASSATA:
CREATE TABLE public."Esperienza_passata"(
    "CodiceEsp" numeric(20, 0) NOT NULL,
    "Motivo_cessazione" character varying(50),
    "DataInizio" date,
    "DataFine" date,
    "NomeLavoro" character varying(20),
    "Cittadino" character varying(16),
    CONSTRAINT "Esperienza_passata_pkey"
        PRIMARY KEY ("CodiceEsp"),
    CONSTRAINT "Esperienza_passata_Cittadino_fkey"
        FOREIGN KEY ("Cittadino")
            REFERENCES public."Cittadino" ("CFCittadino")
            MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE CASCADE,
    CONSTRAINT "Esperienza_passata_NomeLavoro_fkey"
        FOREIGN KEY ("NomeLavoro")
            REFERENCES public."Lavoro" ("NomeLavoro")
            MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE NO ACTION
    CONSTRAINT "Esperienza_passata_check"
        CHECK ("DataFine" > "DataInizio")
)

--LAVORO:
CREATE TABLE public."Lavoro"(
    "NomeLavoro" character varying(20) NOT NULL,
    CONSTRAINT "Lavoro_pkey" PRIMARY KEY ("NomeLavoro")
)

-- CONOSCENZE_ACQUISITE:
CREATE TABLE public."Conoscenze_acquisite"(
    "CodiceC" numeric(20, 0) NOT NULL,
    "Descrizione" character varying(50),
    CONSTRAINT "Conoscenze_acquisite_pkey"
        PRIMARY KEY ("CodiceC")
)

-- DID:
CREATE TABLE public."Did"(
    "CodiceDID" numeric(20, 0) NOT NULL,
    "DataStipulaDID" date,
    "Settore_occupazione" character varying(50),
    "Cittadino" character varying(16),
    "Ufficio" character varying(20),
    CONSTRAINT "Did_pkey" PRIMARY KEY ("CodiceDID"),
    CONSTRAINT "Did_Cittadino_fkey" FOREIGN KEY
        ("Cittadino")
            REFERENCES public."Cittadino" ("CFCittadino")
            MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE CASCADE,
    CONSTRAINT "Did_Ufficio_fkey" FOREIGN KEY ("Ufficio")
        REFERENCES public."Ufficio" ("NomeUfficio")
        MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "Did_DataStipulaDID_check"
        CHECK ("DataStipulaDID" <= CURRENT_DATE)
)

-- UFFICIO:
CREATE TABLE public.ufficio(
    nomeufficio character varying(50) NOT NULL,
    n_dipendenti numeric(100, 0),
    capoufficio numeric(20, 0) NOT NULL,
    CONSTRAINT ufficio_pkey PRIMARY KEY (nomeufficio),
    CONSTRAINT ufficio_capoufficio_fkey
        FOREIGN KEY (capoufficio)
            REFERENCES public.personale (matricola)
            MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE NO ACTION
)

-- PERSONALE:
CREATE TABLE public.personale(
    matricola numeric(3, 0) NOT NULL,
    nomep character varying(20),
    cognomep character varying(20),
    stipendio numeric(10, 0),
    orainizioturno time with time zone,
    orafineturno time with time zone,
    cfpersonale character varying(16),
    ufficio character varying(50),
    CONSTRAINT personale_pkey PRIMARY KEY (matricola),
    CONSTRAINT personale_ufficio_fkey FOREIGN KEY (ufficio)
        REFERENCES public.ufficio (nomeufficio) MATCH
            SIMPLE
            ON UPDATE NO ACTION
            ON DELETE CASCADE,
    CONSTRAINT personale_check
        CHECK (orafineturno > orainizioturno),
    CONSTRAINT personale_cf_check CHECK
        (char_length(cfpersonale::text) = 16)
)

-- DIA:
CREATE TABLE public.dia(
    codicedia numeric(20, 0) NOT NULL,
    datastipuladia date,
    n_postirichiesti numeric(100, 0),
    ufficio character varying(20),
    azienda numeric(11, 0),
    CONSTRAINT dia_pkey PRIMARY KEY (codicedia),
    CONSTRAINT dia_azienda_fkey FOREIGN KEY (azienda)
        REFERENCES public.azienda (p_iva)
        MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT dia_datastipuladia_check
        CHECK (datastipuladia <= CURRENT_DATE),
    CONSTRAINT dia_ufficio_check
        CHECK (ufficio::text ~~ 'Assunzione%'::text)
)

-- AZIENDA:
CREATE TABLE public.azienda(
    p_iva numeric NOT NULL,
    nomea character varying(20),
    sedelegale character varying(20),
    statoattivita character varying(20),
    num_dipendenti numeric(100, 0),
    settore character varying(100),
    CONSTRAINT azienda_pkey PRIMARY KEY (p_iva)
)

-- SERVIZIO:
CREATE TABLE public.servizio(
    nomeservizio character varying(30) NOT NULL,
    ufficio character varying(20),
    CONSTRAINT servizio_pkey PRIMARY KEY (nomeservizio),
    CONSTRAINT ufficio_servizio_fkey FOREIGN KEY (ufficio)
        REFERENCES public.ufficio (nomeufficio)
        MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

-- SERVIZIO_DI_FORMAZIONE:
CREATE TABLE public.servizio_di_formazione(
    nomeservizio character varying(50) NOT NULL,
    CONSTRAINT servizio_di_formazione_pkey
        PRIMARY KEY (nomeservizio),
    CONSTRAINT servizio_di_formazione_nomeservizio_fkey
        FOREIGN KEY (nomeservizio)
            REFERENCES public.servizio (nomeservizio)
            MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE CASCADE
)

-- CORSO:
CREATE TABLE public.corso(
    nomecorso character varying(20) NOT NULL,
    enteformativo character varying(20) NOT NULL,
    tiposervizioerogato character varying(30),
    CONSTRAINT corso_pkey
        PRIMARY KEY (nomecorso, enteformativo),
    CONSTRAINT corso_enteformativo_key
        UNIQUE (enteformativo),
    CONSTRAINT corso_nomecorso_key UNIQUE (nomecorso),
    CONSTRAINT corso_tiposervizioerogato_fkey
        FOREIGN KEY (tiposervizioerogato)
            REFERENCES public.servizio_di_formazione(nomeservizio)
            MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE CASCADE
)

-- SERVIZIO_DI_UFFICIO:
CREATE TABLE public.servizio_di_ufficio(
    nomeservizio character varying(30) NOT NULL,
    CONSTRAINT servizio_di_ufficio_pkey
        PRIMARY KEY (nomeservizio),
    CONSTRAINT servizio_di_ufficio_nomeservizio_fkey
        FOREIGN KEY (nomeservizio)
            REFERENCES public.servizio (nomeservizio)
            MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE CASCADE
)

-- RICHIESTA_SERVIZIO_CITTADINO:
CREATE TABLE public.richiesta_servizio_cittadino(
    codicerichiestac numeric(20, 0) NOT NULL,
    datarichiestac date,
    tiposervizioerogato character varying(30),
    cittadino character varying(16),
    CONSTRAINT "primary key" PRIMARY KEY (codicerichiestac),
    CONSTRAINT richiesta_servizio_cittadino_cittadino_fkey
        FOREIGN KEY (cittadino)
            REFERENCES public.cittadino (cfcittadino)
            MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE CASCADE,
    CONSTRAINT
        richiesta_servizio_cittadino_tiposervizioerogato_fkey
        FOREIGN KEY (tiposervizioerogato)
            REFERENCES public.servizio_di_ufficio
                (nomeservizio)
            MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT
        richiesta_servizio_cittadino_datarichiestac_check
        CHECK (datarichiestac <= CURRENT_DATE))

-- SERVIZIO_AZIENDA:
CREATE TABLE public.servizio_azienda(
    nomeservizio character varying(50) NOT NULL,
    CONSTRAINT servizio_azienda_pkey
        PRIMARY KEY (nomeservizio),
    CONSTRAINT servizio_azienda_nomeservizio_fkey
        FOREIGN KEY (nomeservizio)
            REFERENCES public.servizio (nomeservizio)
            MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE CASCADE
)

-- RICHIESTA_SERVIZIO_AZIENDA:
CREATE TABLE public.richiesta_sevizio_azienda(
    codicerichiestaa numeric(30, 0) NOT NULL,
    datarichiestaa date,
    tiposervizioerogato character varying(50),
    azienda numeric(11, 0),
    CONSTRAINT richiesta_sevizio_azienda_pkey
        PRIMARY KEY (codicerichiestaa),
    CONSTRAINT richiesta_sevizio_azienda_azienda_fkey
        FOREIGN KEY (azienda)
            REFERENCES public.azienda (p_iva) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT
        richiesta_sevizio_azienda_tiposervizioerogato_fkey
        FOREIGN KEY (tiposervizioerogato)
            REFERENCES public.servizio_azienda (nomeservizio)
            MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT
        richiesta_sevizio_azienda_datarichiestaa_check
        CHECK (datarichiestaa <= CURRENT_DATE)
)

-- CERTIFICA:
CREATE TABLE public.certifica(
    cittadino character varying(16) NOT NULL,
    lingua character varying(20) NOT NULL,
    livello character varying(2) NOT NULL,
    certificato boolean,
    CONSTRAINT certifica_pkey
        PRIMARY KEY (cittadino, lingua, livello),
    CONSTRAINT certifica_cittadino_fkey
        FOREIGN KEY (cittadino)
            REFERENCES public.cittadino (cfcittadino)
            MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE CASCADE,
    CONSTRAINT certifica_lingua_livello_fkey
        FOREIGN KEY (lingua, livello)
            REFERENCES public.conoscenze_linguistiche(lingua,
                livello)
            MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE NO ACTION
)

-- ATTESTA:
CREATE TABLE public."Attesta"(
    "Cittadino" character varying(16) NOT NULL,
    "Grado" character varying(20) NOT NULL,
    "Corso" character varying(20) NOT NULL,
    "Valutazione" numeric(3, 0),
    CONSTRAINT "Attesta_pkey"
        PRIMARY KEY ("Grado", "Cittadino", "Corso"),
    CONSTRAINT "Attesta_Cittadino_fkey"
        FOREIGN KEY ("Cittadino")
            REFERENCES public."Cittadino" ("CFCittadino")
            MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE CASCADE,
    CONSTRAINT "Attesta_Corso_fkey" FOREIGN KEY ("Corso")
        REFERENCES public."Titolo_di_studio" ("Corso")
        MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "Attesta_Grado_fkey" FOREIGN KEY ("Grado")
        REFERENCES public."Titolo_di_studio" ("Grado")
        MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

-- ASSERISCE:
CREATE TABLE public."Asserisce"(
    "Cittadino" character varying(16) NOT NULL,
    "Descrizione" character varying(50) NOT NULL,
    CONSTRAINT "Asserisce_pkey"
        PRIMARY KEY ("Cittadino", "Descrizione"),
    CONSTRAINT "Asserisce_Cittadino_fkey"
        FOREIGN KEY ("Cittadino")
            REFERENCES public."Cittadino" ("CFCittadino")
            MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE CASCADE,
    CONSTRAINT "Asserisce_Descrizione_fkey"
        FOREIGN KEY ("Descrizione")
            REFERENCES public."Conoscenze_informatiche"
                ("Descrizione") MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE NO ACTION
)

-- PARTECIPAZIONE_PASSATA:
CREATE TABLE public.partecipazione_passata(
    cittadino character varying NOT NULL,
    nomecorso character varying NOT NULL,
    enteformativo character varying NOT NULL,
    datainizio date,
    datafine date,
    CONSTRAINT partecipazione_passata_pkey
        PRIMARY KEY (cittadino, nomecorso, enteformativo),
    CONSTRAINT partecipazione_passata_cittadino_fkey
        FOREIGN KEY (cittadino)
            REFERENCES public.cittadino (cfcittadino)
            MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE CASCADE,
    CONSTRAINT
        partecipazione_passata_nomecorso_enteformativo_fkey
        FOREIGN KEY (enteformativo, nomecorso)
            REFERENCES public.corso (enteformativo, nomecorso)
            MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT partecipazione_passata_check
        CHECK (datafine > datainizio)
)

-- DERIVA:
CREATE TABLE public."Deriva"(
    "CodiceC" numeric(20, 0) NOT NULL,
    "CodiceEsp" numeric(20, 0) NOT NULL,
    CONSTRAINT "Deriva_pkey"
        PRIMARY KEY ("CodiceC", "CodiceEsp"),
    CONSTRAINT "Deriva_CodiceC_fkey" FOREIGN KEY ("CodiceC")
        REFERENCES
            public."Conoscenze_acquisite"("CodiceC")
            MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE NO ACTION,
    CONSTRAINT "Deriva_CodiceEsp_fkey"
        FOREIGN KEY ("CodiceEsp")
            REFERENCES public."Esperienza_passata"("CodiceEsp")
            MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE CASCADE
)

-- PARTECIPAZIONE_PRESENTE:
CREATE TABLE public.partecipazione_presente(
    cittadino character varying(16) NOT NULL,
    nomecorso character varying(50) NOT NULL,
    datainizio date,
    enteformativo character varying(20),
    CONSTRAINT partecipazione_presente_pkey
        PRIMARY KEY (cittadino, nomecorso),
    CONSTRAINT partecipazione_presente_cittadino_fkey
        FOREIGN KEY (cittadino)
            REFERENCES public.cittadino (cfcittadino)
            MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE CASCADE,
    CONSTRAINT
        partecipazione_presente_nomecorso_enteformativo_fkey
        FOREIGN KEY (enteformativo, nomecorso)
            REFERENCES public.corso (enteformativo, nomecorso)
            MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE CASCADE
)