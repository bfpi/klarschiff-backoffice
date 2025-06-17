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

### Get discovery
```
GET http://[API endpoint]/discovery.[format]
```

output values come from the config/citysdk.yml

Sample Response:

```xml
<dicovery>
  <changeset>2015-11-05 08:43</changeset>
  <contact>
    "Hanse- und Universitätsstadt Rostock, Kataster-, Vermessungs- und Liegenschaftsamt,
    Holbeinplatz 14, 18069 Rostock, klarschiff.hro@rostock.de"
  </contact>
  <key_service>klarschiff.hro@rostock.de</key_service>
  <endpoints>
    <endpoint>
      <specification>http://wiki.open311.org/GeoReport_v2</specification>
      <url>https://geo.sv.rostock.de/citysdk</url>
      <changeset>2015-11-05 08:43</changeset>
      <type>production</type>
      <formats>
        <format>application/json</format>
        <format>text/xml</format>
      </formats>
    </endpoint>
    <endpoint>
      <specification>http://wiki.open311.org/GeoReport_v2</specification>
      <url>https://support.klarschiff-hro.de/citysdk</url>
      <changeset>2015-11-05 08:43</changeset>
      <type>test</type>
      <formats>
        <format>application/json</format>
        <format>text/xml</format>
      </formats>
    </endpoint>
    <endpoint>
      <specification>http://wiki.open311.org/GeoReport_v2</specification>
      <url>https://demo.klarschiff-hro.de/citysdk</url>
      <changeset>2015-11-05 08:43</changeset>
      <type>test</type>
      <formats>
        <format>application/json</format>
        <format>text/xml</format>
      </formats>
    </endpoint>
  </endpoints>
</discovery>
```

### GET services list
```
GET http://[API endpoint]/services.[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| api_key | - | String | API key |

Sample Response:

```xml
<services type="array">
  <service>
    <service_code>category.id</service_code>
    <service_name>category.name</service_name>
    <description/>
    <metadata>false</metadata>
    <type>realtime</type>
    <keywords>category.parent.typ [problem|idea|tip]</keywords>
    <group>category.parent.name</group>
  </service>
</services>
```
### Get service definition
```
GET http://[API endpoint]/services/[id].[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| api_key | - | String | API key |
| id | X | Integer | ID of service|

Sample Response:

```xml
<service_definition type="array">
  <service>
    <service_code>category.id</service_code>
    <service_name>category.name</service_name>
    <keywords>category.parent.typ [problem|idea|tip]</keywords>
    <group>category.parent.name</group>
  </service>
</service_definition>
```

### Get service requests list
```
GET http://[API endpoint]/requests.[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| api_key | - | String | API key |
| service_request_id | - | Integer / String | List of multiple Request-IDs, comma delimited |
| service_code | - | Integer | ID of category |
| status | - | String | Filter issues by Open311 status, default = `open` |
| detailed_status |  - | String | Filter issues by CitySDK status |
| start_date | - | Date | Filter for issue date >= value, e.g 2011-01-01T00:00:00Z |
| end_date | - | Date | Filter for isse date <= value, e.g 2011-01-01T00:00:00Z |
| updated_after | - | Date | Filter for issue version >= value, e.g 2011-01-01T00:00:00Z |
| updated_before | - | Date | Filter for issue version <= value, e.g 2011-01-01T00:00:00Z |
| agency_responsible | - | String | Filter for issues by job team |
| extensions | - | Boolean | Include extended attributs in response |
| lat | - | Double | Filter restriction area (lat, long and radius required) |
| long | - | Double | Filter restriction area (lat, long and radius required) |
| radius | - | Double | Meter to filter restriction area (lat, long and radius required) |
| keyword | - | String | Filter issues by kind, options: problem, idea, tip |
| with_picture | - | Boolean | Filter issues with released photos |
| also_archived | - | Boolean | Include already archived issues |
| just_count | - | Boolean | Switch response to only return amount of affected issues |
| max_requests | - | Integer | Maximum number of requests to return |
| observation_key | - | String | UUID of observed area to use as filter |
| area_code | - | Integer | Filter issues by affected area ID |

Available Open311 states for this action: `open`, `closed`\
Available CitySDK states for this action: `PENDING`, `RECEIVED`, `IN_PROCESS`, `PROCESSED`, `REJECTED`

Sample Response:

```xml
<service_requests type="array">
  <request>
    <service_request_id>request.id</service_request_id>
    <status_notes/>
    <status>request.status</status>
    <service_code>request.service.code</service_code>
    <service_name>request.service.name</service_name>
    <description>request.description</description>
    <agency_responsible>request.agency_responsible</agency_responsible>
    <service_notice/>
    <requested_datetime>request.requested_datetime</requested_datetime>
    <updated_datetime>request.updated_datetime</updated_datetime>
    <expected_datetime/>
    <address>request.address</address>
    <adress_id/>
    <lat>request.position.lat</lat>
    <long>request.position.lat</long>
    <media_url/>
    <zipcode/>
  </request>
</service_requests>
```

### Get service request
```
GET http://[API endpoint]/requests/[service_request_id].[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| api_key | - | String | API key |
| service_request_id | X | Integer | Issue ID |
| extensions | - | Boolean | Include extended attributes in response |

Sample Response:

```xml
<service_requests type="array">
  <request>
    <service_request_id>request.id</service_request_id>
    <status_notes/>
    <status>request.status</status>
    <service_code>request.service.code</service_code>
    <service_name>request.service.name</service_name>
    <description>request.description</description>
    <agency_responsible>request.agency_responsible</agency_responsible>
    <service_notice/>
    <requested_datetime>request.requested_datetime</requested_datetime>
    <updated_datetime>request.updated_datetime</updated_datetime>
    <expected_datetime/>
    <address>request.address</address>
    <adress_id/>
    <lat>request.position.lat</lat>
    <long>request.position.lat</long>
    <media_url/>
    <zipcode/>
    <extended_attributes>
      <detailed_status>request.detailed_status</detailed_status>
      <media_urls>
        <media_url>request.media.url</media_url>
      </media_urls>
      <photo_required>request.photo_required</photo_required>
      <trust>request.trust</trust>
      <votes>request.votes</votes>
    </extended_attributes>
  </request>
</service_requests>
```
### Create service request
```
POST http://[API endpoint]/requests.[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| api_key | X | String | API key |
| email | X | String | Author email |
| service_code | X | Integer | Category ID |
| description | X | String | Description |
| lat | * | Float | Latitude value of position |
| long | * | Float | Longitude value of position |
| address_string | * | String | Address for position |
| photo_required | - | Boolean | Photo required |
| media | - | String | Photo as Base64 encoded string |
| privacy_policy_accepted | - | Boolean | Confirmation of accepted privacy policy |

*: Either `lat` and `long` or `address_string` are required

Sample Response:

```xml
<service_requests>
  <request>
    <service_request_id>request.id</service_request_id>
  </request>
</service_requests>
```
### Update Service request
```
PATCH http://[API endpoint]/requests/[service_request_id].[format]
PUT   http://[API endpoint]/requests/[service_request_id].[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| api_key | X | String | API key |
| email | X | String | Author email |
| service_code | X | Integer | Category ID |
| description | - | String | Description |
| lat | * | Float | Latitude value of position |
| long | * | Float | Longitude value of position |
| address_string | * | String | Address for position |
| photo_required | - | Boolean | Photo required |
| media | - | String | Photo as Base64 encoded string |
| detailed_status | - | String | CitySDK status |
| status_notes | - | String | Status note |
| priority | - | Integer | Priority |
| delegation | - | String | Delegation to external role |
| job_status | - | Integer | Job status |
| job_priority | - | Integer | Job priority |

*: Either `lat` and `long` or `address_string` are required\
Available CitySDK states for this action: `RECEIVED`, `IN_PROCESS`, `PROCESSED`, `REJECTED`

Sample Response:

```xml
<service_requests type="array">
  <request>
    <service_request_id>request.id</service_request_id>
    <status_notes/>
    <status>request.status</status>
    <service_code>request.service.code</service_code>
    <service_name>request.service.name</service_name>
    <description>request.description</description>
    <agency_responsible>request.agency_responsible</agency_responsible>
    <service_notice/>
    <requested_datetime>request.requested_datetime</requested_datetime>
    <updated_datetime>request.updated_datetime</updated_datetime>
    <expected_datetime/>
    <address>request.address</address>
    <adress_id/>
    <lat>request.position.lat</lat>
    <long>request.position.lat</long>
    <media_url/>
    <zipcode/>
  </request>
</service_requests>
```
### Confirm Service request
```
PUT http://[API endpoint]/requests/[confirmation_hash]/confirm.[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| confirmation_hash | X | String | generated and transmitted UUID |

Sample Response:

```xml
<service_requests>
  <request>
    <service_request_id>request.id</service_request_id>
  </request>
</service_requests>
```
### Destroy Service request
```
PUT http://[API endpoint]/requests/[confirmation_hash]/revoke.[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| confirmation_hash | X | String | generated and transmitted UUID |

Sample Response:

```xml
<service_requests>
  <request>
    <service_request_id>request.id</service_request_id>
  </request>
</service_requests>
```

### Get observable areas
```
GET http://[API endpoint]/areas.[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| api_key | X | String | API key |
| area_code | - | Integer / String | ID to filter districts, separated by comma for multiple values |
| search_class | - | String | specifies which data to search for |
| regional_key | - | Integer / String | RegionalKey to filter region (based on search_class) |
| with_districts | - | Boolean | return all existing districts, not available if using area_code |

The parameter `regional_key` is ignored if parameter `area_code` is given with the request, so you have
to omit the `area_code` parameter to get the response for `regional_key` filter.

Available SeachClasses for this action: `authority`, `district`

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
```
GET http://[API endpoint]/coverage.[format]
```

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

### Get jobs list
```
GET http://[API endpoint]/jobs.[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| api_key | X | String | API key |
| date | X | Date | Filter jobs that are the equal or lower than the given date |
| status | - | String | Job status |

Available job states for this action: `CHECKED`, `UNCHECKED`, `NOT_CHECKABLE`

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
```
POST http://[API endpoint]/jobs.[format]
```

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
```
PATCH http://[API endpoint]/jobs/[service_request_id].[format]
PUT   http://[API endpoint]/jobs/[service_request_id].[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| api_key | X | String | API key |
| service_request_id | X | Integer | Affected issue ID |
| status | X | String | Job status |
| date | X | Date | Date of job |

Available job states for this action: `CHECKED`, `UNCHECKED`, `NOT_CHECKABLE`

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
```
POST http://[API endpoint]/observations.[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| api_key | X | String | API key |
| geometry | * | String | WKT geoemetry for observing area |
| area_code | * | String | IDs of districts, -1 for instance |
| problems | - | Boolean | Include problems |
| problem_service | - | String | Filter problems by main category IDs |
| problem_service_sub | - | String | Filter problems by sub category IDs |
| ideas | - | Boolean | Include problems |
| idea_service | | String | Filter ideas by main category IDs |
| idea_service_sub | | String | Filter ideas by sub category IDs |

*: Either `geometry` or `area_code` is required

Sample Response:

```xml
<observation>
  <rss-id>39a855f0a4924af3217a217c8dc78ece</rss-id>
</observatio>
```

### Create new abuse for service request
```
POST http://[API endpoint]/requests/abuses/[service_request_id].[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| service_request_id | X | Integer | Issue ID |
| author | X | String | Author email |
| comment | X | String | |
| privacy_policy_accepted | - | Boolean | Confirmation of accepted privacy policy |

Sample Response:

```xml
<abuses>
  <abuse>
    <id>abuse.id</id>
  </abuse>
</abuses>
```
### Confirm abuse for service request
```
PUT http://[API endpoint]/requests/abuses/[confirmation_hash]/confirm.[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| confirmation_hash | X | String | generated and transmitted UUID |

Sample Response:

```xml
<service_requests>
  <request>
    <service_request_id>request.id</service_request_id>
  </request>
</service_requests>
```

### Get comments list for service request
```
GET http://[API endpoint]/requests/comments/[service_request_id].[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| service_request_id | X | Integer | Issue ID |
| api_key | X | String | API key |

Sample Response:

```xml
<comments type="array">
  <comment>
    <id>comment.id</id>
    <jurisdiction_id></jurisdiction_id>
    <comment>comment.text</comment>
    <datetime>comment.datetime</datetime>
    <service_request_id>comment.service_request_id</service_request_id>
  </comment>
</comments>
```
### Create new comment for service request
```
POST http://[API endpoint]/requests/comments/[service_request_id].[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| service_request_id | X | Integer | Issue ID |
| api_key | X | String | API key |
| author | X | String | Author email |
| comment | X | String | |
| privacy_policy_accepted | - | Boolean | Confirmation of accepted privacy policy |

Sample Response:

```xml
<comments>
  <comment>
    <id>comment.id</id>
    <jurisdiction_id></jurisdiction_id>
    <comment>comment.text</comment>
    <datetime>comment.datetime</datetime>
    <service_request_id>comment.service_request_id</service_request_id>
  </comment>
</comments>
```

### Create new completion for service request
```
POST http://[API endpoint]/requests/completions/[service_request_id].[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| service_request_id | X | Integer | Issue ID |
| author | X | String | Author email |
| privacy_policy_accepted | - | Boolean | Confirmation of accepted privacy policy |

Sample Response:

```xml
<completions>
  <completion>
    <id>completion.id</id>
  </completion>
</completions>
```
### Confirm completion for service request
```
PUT [API endpoint]/requests/completions/[confirmation_hash]/confirm.[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| confirmation_hash | X | String | generated and transmitted UUID |

Sample Response:

```xml
<service_requests>
  <request>
    <service_request_id>request.id</service_request_id>
  </request>
</service_requests>
```

### Get notes list for service request
```
GET http://[API endpoint]/requests/notes/[service_request_id].[format]
```

Notes are internal comments on issues.

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| service_request_id | X | Integer | Issue ID |
| api_key | X | String | API key |

Sample Response:

```xml
<notes type="array">
  <note>
    <jurisdiction_id></jurisdiction_id>
    <comment>note.text</comment>
    <datetime>note.datetime</datetime>
    <service_request_id>note.service_request_id</service_request_id>
    <author>note.author</author>
  </note>
</notes>
```
### Create new note for service request
```
POST http://[API endpoint]/requests/notes/[service_request_id].[format]
```

Notes are internal comments on issues.

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| service_request_id | X | Integer | Issue ID |
| api_key | X | String | API key |
| author | X | String | Author email |
| note | X | String | Internal comment for issue |

Sample Response:

```xml
<notes>
  <note>
    <jurisdiction_id></jurisdiction_id>
    <comment>note.text</comment>
    <datetime>note.datetime</datetime>
    <service_request_id>note.service_request_id</service_request_id>
    <author>note.author</author>
  </note>
</notes>
```

### Create new photo for service request
```
POST http://[API endpoint]/requests/photos/[service_request_id].[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| service_request_id | X | Integer | Issue ID |
| author | X | String | Author email |
| media | X | String | Photo as Base64 encoded string |

Sample Response:

```xml
<photos>
  <photo>
    <id>photo.id</id>
  </photo>
</photos>
```
### Confirm photo for service request
```
PUT http://[API endpoint]/requests/photos/[confirmation_hash]/confirm.[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| confirmation_hash | X | String | generated and transmitted UUID |

Sample Response:

```xml
<service_requests>
  <request>
    <service_request_id>request.id</service_request_id>
  </request>
</service_requests>
```

### Create new vote for service request
```
POST http://[API endpoint]/requests/votes/[service_request_id].[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| service_request_id | X | Integer | Issue ID |
| author | X | String | Author email |
| privacy_policy_accepted | - | Boolean | Confirmation of accepted privacy policy |

Sample Response:

```xml
<votes>
  <vote>
    <id>vote.id</id>
  </vote>
</votes>
```
### Confirm vote for service request
```
PUT http://[API endpoint]/requests/votes/[confirmation_hash]/confirm.[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| confirmation_hash | X | String | generated and transmitted UUID |

Sample Response:

```xml
<service_requests>
  <request>
    <service_request_id>request.id</service_request_id>
  </request>
</service_requests>
```

### Get users
```
GET http://[API endpoint]/users.[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| api_key | X | String | API key |
| login | X | String | Username |

Sample Response:

```xml
<users>
  <user>
    <id>user.id</id>
    <name>user.last_name, user.first_name</name>
    <email>user.email</email>
    <field_service_team/>
  </user>
</users>
```
### Create users
```
POST http://[API endpoint]/users.[format]
```

Parameters:

| Name | Required | Type | Notes |
|:--|:-:|:--|:--|
| api_key | X | String | API key |
| login | X | String | Username |
| password | X | String |  |
| field_service_team | X | Integer |  |

Sample Response:

```xml
<users>
  <user>
    <id>user.id</id>
    <name>user.last_name, user.first_name</name>
    <email>user.email</email>
    <field_service_team/>
  </user>
</users>
```

