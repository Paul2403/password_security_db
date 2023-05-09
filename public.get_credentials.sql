-- FUNCTION: public.get_credentials(json)

-- DROP FUNCTION IF EXISTS public.get_credentials(json);

CREATE OR REPLACE FUNCTION public.get_credentials(
	params json DEFAULT '{}'::json)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
-- select get_credentials('{"email_id":"paul.issac@gmail.com","current_password":"abc"}')

declare 
creds json;
query text;
unitValue smallint;
dosesPerVial smallint;
manufactureId smallint;
startDate date;
intervalValue integer;
email_id varchar;
begin
	
query := 'Select id FROM public.login_credentials where email_id= ''' || (params->>'email_id') || ''' and current_password=''' || (params->>'current_password') || '''';

RAISE info '%',query;	
	EXECUTE format
($ex$
SELECT
    json_agg (row_to_json(t))
FROM (%s) t $ex$,
    query
) INTO creds;
if creds is null then
	return '{"status": 400, "data": "No records found", "message": "No records found"}';
end if;
return '{"status": 200, "data": ' || creds || '}';
end
$BODY$;

ALTER FUNCTION public.get_credentials(json)
    OWNER TO postgres;
