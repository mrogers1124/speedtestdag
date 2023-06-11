/*
 * DDL for speedtestdag SQLite database
 */


/*
 * RAW_RESULTS
 * Table that holds JSON formatted data returned from speedtest CLI
 */

CREATE TABLE IF NOT EXISTS RAW_RESULTS (
	"id" TEXT,
	"result" TEXT,
	CONSTRAINT RAW_RESULTS_PK PRIMARY KEY (id)
);


/*
 * V_RESULTS
 * View that presents raw results in tabular format
 */

DROP VIEW IF EXISTS V_RESULTS;

CREATE VIEW V_RESULTS AS
SELECT
    json_extract("result", '$.timestamp') AS "timestamp",

    json_extract("result", '$.ping.jitter') AS "ping_jitter",
    json_extract("result", '$.ping.latency') AS "ping_latency",
    json_extract("result", '$.ping.low') AS "ping_low",
    json_extract("result", '$.ping.high') AS "ping_high",

    json_extract("result", '$.download.bandwidth') AS "download_bandwidth",
    json_extract("result", '$.download.bytes') AS "download_bytes",
    json_extract("result", '$.download.elapsed') AS "download_elapsed",
    json_extract("result", '$.download.latency.iqm') AS "download_latency_iqm",
    json_extract("result", '$.download.latency.low') AS "download_latency_low",
    json_extract("result", '$.download.latency.high') AS "download_latency_high",
    json_extract("result", '$.download.latency.jitter') AS "download_latency_jitter",

    json_extract("result", '$.upload.bandwidth') AS "upload_bandwidth",
    json_extract("result", '$.upload.bytes') AS "upload_bytes",
    json_extract("result", '$.upload.elapsed') AS "upload_elapsed",
    json_extract("result", '$.upload.latency.iqm') AS "upload_latency_iqm",
    json_extract("result", '$.upload.latency.low') AS "upload_latency_low",
    json_extract("result", '$.upload.latency.high') AS "upload_latency_high",
    json_extract("result", '$.upload.latency.jitter') AS "upload_latency_jitter",

    json_extract("result", '$.packetLoss') AS "packetLoss",
    json_extract("result", '$.isp') AS "isp",

    json_extract("result", '$.interface.internalIp') AS "interface_internalIp",
    json_extract("result", '$.interface.name') AS "interface_name",
    json_extract("result", '$.interface.macAddr') AS "interface_macAddr",
    json_extract("result", '$.interface.isVpn') AS "interface_isVpn",
    json_extract("result", '$.interface.externalIp') AS "interface_externalIp",

    json_extract("result", '$.server.id') AS "server_id",
    json_extract("result", '$.server.host') AS "server_host",
    json_extract("result", '$.server.port') AS "server_port",
    json_extract("result", '$.server.name') AS "server_name",
    json_extract("result", '$.server.location') AS "server_location",
    json_extract("result", '$.server.country') AS "server_country",
    json_extract("result", '$.server.ip') AS "server_ip",

    json_extract("result", '$.result.id') AS "result_id",
    json_extract("result", '$.result.url') AS "result_url",
    json_extract("result", '$.result.persisted') AS "result_persisted"

FROM RAW_RESULTS
ORDER BY "timestamp";
