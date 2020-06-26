# Roughly cronological set of release notes

### 2020-06-29 canvassing web UI

* added web UI to create canvasser shifts
* added integrations to submit canvasser shifts and registrations to the Blocks system
* added api v4 param (report_type) to registrant CSV report creation to request extended CSV format, e.g.

  curl -X POST "https://<domain_name>/api/v4/registrant_reports?partner_id=<partner_id>&partner_API_key=<api_key>&since=2020-01-01&report_type=extended" -d ''