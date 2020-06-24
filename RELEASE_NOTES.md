# Roughly cronological set of release notes

### canvassing web UI

* added web UI to create canvasser shifts
* added integrations to submit canvasser shifts and registrations to the Blocks system
* added api v4 param (report_type_) to registrant CSV report creation to request extended CSV format, e.g.
** curl -X POST "http://localhost:3000/api/v4/registrant_reports?partner_id=1&partner_API_key=<apikey>&since=2020-01-01&report_type=extended" -d ''