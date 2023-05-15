-- FUNCTION: public.update_password(json)

-- DROP FUNCTION IF EXISTS public.update_password(json);

CREATE OR REPLACE FUNCTION public.update_password(
	params json)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare
scheduleId 				integer;
secondScheduleId integer;
eventId                 integer;
error                   smallint;
message                 text;
msg						varchar;
responsejson            jsonb;
response			    json;
refrenceId              integer;
sendData                json;
eventData               json;
responseData            json;
allTimeslots            boolean;
eventResponseData       json;
checkResponseData		json;
tempDetails             json;
tempArray				jsonb;
tempPassword			varchar;
currPass				json;

-- select update_password('{"otp":"fdsfse","id":1,"passwd":"kithu"}')
begin
	error = 0;
-- 	message = '';
	begin
	
	-- The main code: Params for id should always be there. 
	if params->>'id' is not null THEN
	
	-- Here, we are building another object and sending the data to the old_password_check function and we get the data as responseData.
	sendData = (SELECT json_build_object(
                  'id', (params->>'id')::int,
                  'typedPass', (params->>'passwd')::varchar
                )
            );
	    select old_password_check(sendData) INTO responseData;
		
		--If the status of the responseData indicates Password already exists or anyother issue the below code is executed
		IF (responseData->>'status')::integer != 200 THEN 
			response = (select row_to_json(t) FROM (Select 400 as "status", (responseData->>'data') as "data")t);	
			message = responseData->>'data';
		
		-- if the status of the responseData conditions are satisfied then the below code is executed.
		ELSE
		
		--here we are only showing the first 3 elements in the old_passwords array.
		UPDATE public.login_credentials SET old_passwords = jsonb_build_array(old_passwords[0], old_passwords[1], old_passwords[2])  WHERE id = (params->>'id')::int;
		
		--we are putting the current password to the first element of the array
		UPDATE public.login_credentials
		SET old_passwords = jsonb_insert(
			COALESCE(old_passwords, '[]'::jsonb), 
			'{0}', 
			jsonb_build_object('password', current_password)
		)
		WHERE id = (params->>'id')::int;
		
		--We are setting the new inputted password to the current password field.
		UPDATE public.login_credentials SET current_password =  (params->>'passwd')::varchar where id = (params->>'id')::int;
		
		--construction of the response data from the database.
		responseJson = (select row_to_json(t) FROM (Select * FROM public.login_credentials where id= (params->>'id')::int)t);
		msg = 'Password Successfully Updated!';
		response = (select row_to_json(t) FROM (Select 200 as "status", msg as "data")t);
		END IF;
-- 		RAISE EXCEPTION '%',message;
	END IF;

-- 	EXCEPTION
-- 		WHEN unique_violation THEN
-- 			response = '{"status": 500, "data": "Unique key violation"}';
-- 		WHEN check_violation THEN
-- 			response = '{"status": 500, "data": "Check violation"}';
-- 		WHEN others THEN
-- 			RAISE INFO 'Error Name:%', SQLERRM;
-- 		   	RAISE INFO 'Error State:%', SQLSTATE;
-- 			response = '{"status": 500, "data": "'|| SQLERRM ||'"}';
	end;
	return response;
end
$BODY$;

ALTER FUNCTION public.update_password(json)
    OWNER TO postgres;
