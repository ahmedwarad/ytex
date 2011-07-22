
CREATE TABLE $(db_schema).umls_ms_2009 (
  cui nvarchar(10) NOT NULL,
  fword nvarchar(80) NOT NULL,
  text ntext,
  code nvarchar(45) NOT NULL,
  sourcetype nvarchar(45) NOT NULL,
  tui nvarchar(4) NOT NULL
);


CREATE TABLE $(db_schema).umls_snomed_map (
  cui nvarchar(10) NOT NULL,
  code nvarchar(45) NOT NULL,
);
