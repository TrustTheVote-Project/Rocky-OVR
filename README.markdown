Rocky provides a cloud-hosted service to 3rd-party registrar organizations (3RO) to create their own online voter registration (OVR) web service to voters. The public-facing service is a web application, presented with the 3RO's branding and choices among Rocky configuration options. In the public-facing service, citizens enter their OVR information for online form completion. If the user is eligble for their state's paperless OVR submission process, users are directed to their state's web site to complete; otherwise, Rocky prepares a PDF of their voter registration form that they can print, sign and mail in to get registered. Rocky also includes a 3RO portal where 3RO staff can log in to generate reports, download data, change branding and configuration options, and use other services specific to 3ROs.

Developers: see doc/setup.md

Deployment: see doc/production.md


curl -vX POST http://localhost:3000/api/v3/voterregistrationrequest -d @grommet_req.json --header "Content-Type: application/json"

curl -vX POST https://staging.rocky.rockthevote.com/api/v3/voterregistrationrequest -d @grommet_req.json --header "Content-Type: application/json"



curl -X POST -d registration[lang]=en -d registration[date_of_birth]=1979-10-24 -d registration[email_address]=test@test.com -d registration[first_name]=Test -d registration[home_address]=Colenso -d registration[home_city]=Carrum -d registration[home_state_id]=NV -d registration[home_zip_code]=89001 -d registration[last_name]=User -d registration[name_title]=Mr. -d registration[partner_id]=13 -d registration[party]=Democratic -d registration[race]=Other -d registration[id_number]=1234 -d registration[us_citizen]=1 -d registration[opt_in_email]=1 -d registration[opt_in_sms]=0 -d registration[send_confirmation_reminder_emails]=1 http://localhost:3000/api/v3/registrations.json