# Klarschiff-CitySDK
Implementation of CitySDK-Smart-Participation-API for Klarschiff

## Supported formats and encoding
The API supports both JSON and XML. All strings are encoded with UTF-8.

## General info
The Issue Reporting API is based on GeoReport API version 2, better known as the [Open311 specification](http://open311.org/).
The interface is designed in such a way that any GeoReport v2 compatible client is able to use the interface.
This interface is compliant with [CitySDK](http://www.citysdk.eu/) specific enhancements to Open311.
To support some special functions there are also some additional enhancements to Open311 and CitySDK.

## API methods

### Get observable areas
<code>http://[API endpoint]/areas.[format]</code>
HTTP Method: GET
Parameters:
| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| api_key | X | String | API key |
| area_code | - | Integer[] | IDs to filter districts |
| with_districts | - | Boolean | return all existing districts, not available if using area_code |
Sample Response:
```xml
<areas>
<area>
<id>30</id>
<name>Biestow</name>
<grenze>MULTIPOLYGON (((...)))</grenze>
</area>
...
</areas>
```

### Get position coverage
<code>http://[API endpoint]/coverage.[format]</code>
HTTP Method: GET
Parameters:
| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| api_key | X | String | API key |
| lat | X | Float | latitude value |
| long | X | Float | longitude value |
Sample Response:
```xml
<hash>
<result type="boolean">false</result>
</hash>
```

### Get discovery
<code>http://[API endpoint]/discovery.[format]</code>
HTTP Method: GET

### Get jobs list
<code>http://[API endpoint]/jobs.[format]</code>
HTTP Method: GET
Parameters:
| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| api_key | X | String | API key |
| date | X | Date | Filter jobs that are the equal or lower than the given date |
| status | - | String | Status (CHECKED, UNCHECKED, NOT_CHECKABLE) |
Sample Response:
```xml
<jobs>
<job>
<id>job.id</id>
<service-request-id>job.service_request_id</service-request-id>
<date>job.date</date>
<agency-responsible>job.agency_responsible</agency-responsible>
<status>job.status</status>
</job>
...
</jobs>
```
### Create new job
<code>http://[API endpoint]/jobs.[format]</code>
HTTP Method: POST
Parameters:
| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| api_key | X | String | API key |
| service_request_id | X | Integer | Affected issue ID |
| agency_responsible | X | String | Name of team |
| date | X | Date | Date for job |
Sample Response:
```xml
<jobs>
<job>
<id>job.id</id>
<service-request-id>job.service_request_id</service-request-id>
<date>job.date</date>
<agency-responsible>job.agency_responsible</agency-responsible>
<status>job.status</status>
</job>
</jobs>
```
### Update job
<code>http://[API endpoint]/jobs/[service_request_id].[format]</code>
HTTP Method: PUT / PATCH
Parameters:
| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| api_key | X | String | API key |
| service_request_id | X | Integer | Affected issue ID |
| status | X | String | Status (CHECKED, UNCHECKED, NOT_CHECKABLE) |
| date | X | Date | Date of job |
Sample Response:
```xml
<jobs>
<job>
<id>job.id</id>
<service-request-id>job.service_request_id</service-request-id>
<date>job.date</date>
<agency-responsible>job.agency_responsible</agency-responsible>
<status>job.status</status>
</job>
</jobs>
```

### Create new observation
<code>http://[API endpoint]/observations.[format]</code>
HTTP Method: POST
Parameters:
| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| api_key | X | String | API key |
| geometry | * | String | WKT gemoemetry for observing area |
| area_code | * | String | IDs of districts, -1 for instance |
| problems | - | Boolean | Include problems |
| problem_service | - | String | Filter problems by main category IDs |
| problem_service_sub | - | String | Filter problems by sub category IDs |
| ideas | - | Boolean | Include problems |
| idea_service | | String | Filter ideas by main category IDs |
| idea_service_sub | | String | Filter ideas by sub category IDs |
*: Either geometry or area_code is required
Sample Response:
```xml
<observation>
<rss-id>39a855f0a4924af3217a217c8dc78ece</rss-id>
</observatio>
```

Einzelner Vorgang nach ID
params:
service_request_id  pflicht  - Vorgang-ID
api_key             optional - API-Key
extensions          optional - Response mit erweitereten Attributsausgaben

