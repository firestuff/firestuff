delimiter |

DROP PROCEDURE IF EXISTS convert_to_innodb|

CREATE PROCEDURE convert_to_innodb ()
	BEGIN
		DECLARE table_name BLOB;
		DECLARE table_engine BLOB;
		DECLARE junk BLOB;
		DECLARE done INT DEFAULT 0;
		DECLARE table_cur CURSOR FOR SHOW TABLE STATUS;
		DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;

		OPEN table_cur;

each_table:
		WHILE done = 0 DO
			BEGIN
				FETCH table_cur INTO table_name,table_engine,junk,junk,junk,junk,junk,junk,junk,junk,junk,junk,junk,junk,junk,junk,junk,junk;
				IF table_engine = 'InnoDB' THEN ITERATE each_table; END IF;

				SET @qtext = CONCAT('ALTER TABLE ',table_name,' ENGINE=InnoDB;');

				PREPARE aquery FROM @qtext;

				EXECUTE aquery;

				DEALLOCATE PREPARE aquery;
			END;
		END WHILE;

		CLOSE table_cur;
	END|

CALL convert_to_innodb()|

DROP PROCEDURE convert_to_innodb|
