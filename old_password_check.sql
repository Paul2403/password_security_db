-- FUNCTION: public.old_password_check(json)

-- DROP FUNCTION IF EXISTS public.old_password_check(json);

CREATE OR REPLACE FUNCTION public.old_password_check(
	params json DEFAULT '{}'::json)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
-- select old_password_check('{"id":"1","typedPass":"459125523424d1fcabb6e01d8bda4f8b35e26b604c4b4af41dd7de3e2aa7ccbadb18"}')
declare 
errorMsg integer;
userId integer;
typedPasswrd varchar;
tempDetails jsonb;
begin
userId = (params ->> 'id')::smallint;
typedPasswrd = (params->>'typedPass')::varchar;

errorMsg = 0;

-- If the current password = typed password
 IF typedPasswrd = (SELECT current_password FROM public.login_credentials WHERE id = userId) then
 	RAISE INFO 'check 1:%', typedPasswrd;
 	errorMsg=  1;
 ELSE 
 -- checking if the typed password is equal to any old passwords
 	 FOR tempDetails IN SELECT jsonb_array_elements(old_passwords) AS data FROM public.login_credentials WHERE id = userId
		LOOP
		  IF typedPasswrd = tempDetails->>'password'  then
		  	RAISE INFO 'check 2:%', tempDetails->>'password';
		  	errorMsg = 1;
		  end if;
    	END LOOP;
 END IF;

 IF errorMsg = 0 THEN
 	return '{"status": 200, "data": "Password is okay!", "message": "Password is okay!"}';
 ELSE
 	return '{"status": 400, "data": "Password already exists", "message": "Password already exists"}';
 END IF;
 
 EXCEPTION
		WHEN unique_violation THEN
			return'{"status": 500, "data": "Unique key violation"}';
		WHEN check_violation THEN
			return '{"status": 500, "data": "Check violation"}';
		WHEN others THEN
			RAISE INFO 'Error Name:%', SQLERRM;
		   	RAISE INFO 'Error State:%', SQLSTATE;
			return '{"status": 500, "data": "'|| SQLERRM ||'"}';
	end;

$BODY$;

ALTER FUNCTION public.old_password_check(json)
    OWNER TO postgres;
