SELECT 
    
    -- 86400 is one day, 3600 is one hour (bin every 60 minutes)
    INTEGER(INTEGER(((web100_log_entry.log_time-OFFSET)%86400))/TSBIN)*TSBIN AS ts,

    COUNT(web100_log_entry.log_time)                       as SITE_count,
    -- RATE
    AVG(8*web100_log_entry.snap.HCThruOctetsAcked/(
                     web100_log_entry.snap.SndLimTimeRwin +
                     web100_log_entry.snap.SndLimTimeCwnd +
                     web100_log_entry.snap.SndLimTimeSnd)) as SITE_avg,
    NTH(10,QUANTILES(8*web100_log_entry.snap.HCThruOctetsAcked/(
                     web100_log_entry.snap.SndLimTimeRwin +
                     web100_log_entry.snap.SndLimTimeCwnd +
                     web100_log_entry.snap.SndLimTimeSnd),101)) as SITE_10th_percentile,
    NTH(25,QUANTILES(8*web100_log_entry.snap.HCThruOctetsAcked/(
                     web100_log_entry.snap.SndLimTimeRwin +
                     web100_log_entry.snap.SndLimTimeCwnd +
                     web100_log_entry.snap.SndLimTimeSnd),101)) as SITE_25th_percentile,
    NTH(50,QUANTILES(8*web100_log_entry.snap.HCThruOctetsAcked/(
                     web100_log_entry.snap.SndLimTimeRwin +
                     web100_log_entry.snap.SndLimTimeCwnd +
                     web100_log_entry.snap.SndLimTimeSnd),101)) as SITE_50th_percentile,
    NTH(60,QUANTILES(8*web100_log_entry.snap.HCThruOctetsAcked/(
                     web100_log_entry.snap.SndLimTimeRwin +
                     web100_log_entry.snap.SndLimTimeCwnd +
                     web100_log_entry.snap.SndLimTimeSnd),101)) as SITE_60th_percentile,
    NTH(70,QUANTILES(8*web100_log_entry.snap.HCThruOctetsAcked/(
                     web100_log_entry.snap.SndLimTimeRwin +
                     web100_log_entry.snap.SndLimTimeCwnd +
                     web100_log_entry.snap.SndLimTimeSnd),101)) as SITE_70th_percentile,
    NTH(75,QUANTILES(8*web100_log_entry.snap.HCThruOctetsAcked/(
                     web100_log_entry.snap.SndLimTimeRwin +
                     web100_log_entry.snap.SndLimTimeCwnd +
                     web100_log_entry.snap.SndLimTimeSnd),101)) as SITE_75th_percentile,
    NTH(80,QUANTILES(8*web100_log_entry.snap.HCThruOctetsAcked/(
                     web100_log_entry.snap.SndLimTimeRwin +
                     web100_log_entry.snap.SndLimTimeCwnd +
                     web100_log_entry.snap.SndLimTimeSnd),101)) as SITE_80th_percentile,
    NTH(85,QUANTILES(8*web100_log_entry.snap.HCThruOctetsAcked/(
                     web100_log_entry.snap.SndLimTimeRwin +
                     web100_log_entry.snap.SndLimTimeCwnd +
                     web100_log_entry.snap.SndLimTimeSnd),101)) as SITE_85th_percentile,
    NTH(90,QUANTILES(8*web100_log_entry.snap.HCThruOctetsAcked/(
                     web100_log_entry.snap.SndLimTimeRwin +
                     web100_log_entry.snap.SndLimTimeCwnd +
                     web100_log_entry.snap.SndLimTimeSnd),101)) as SITE_90th_percentile,
    NTH(95,QUANTILES(8*web100_log_entry.snap.HCThruOctetsAcked/(
                     web100_log_entry.snap.SndLimTimeRwin +
                     web100_log_entry.snap.SndLimTimeCwnd +
                     web100_log_entry.snap.SndLimTimeSnd),101)) as SITE_95th_percentile,
FROM 
    DATETABLE
WHERE
        IS_EXPLICITLY_DEFINED(project)
    AND IS_EXPLICITLY_DEFINED(connection_spec.data_direction)
    AND IS_EXPLICITLY_DEFINED(web100_log_entry.is_last_entry)
    AND IS_EXPLICITLY_DEFINED(web100_log_entry.snap.HCThruOctetsAcked)
    AND IS_EXPLICITLY_DEFINED(web100_log_entry.snap.CongSignals)
    AND IS_EXPLICITLY_DEFINED(web100_log_entry.connection_spec.remote_ip)
    AND IS_EXPLICITLY_DEFINED(web100_log_entry.connection_spec.local_ip)
    -- NDT download
    AND project = 0
    AND connection_spec.data_direction = 1
    AND web100_log_entry.is_last_entry = True
    AND web100_log_entry.snap.HCThruOctetsAcked >= 8192 
    AND web100_log_entry.snap.HCThruOctetsAcked < 1000000000
    AND web100_log_entry.snap.CongSignals > 0
    AND (web100_log_entry.snap.SndLimTimeRwin +
         web100_log_entry.snap.SndLimTimeCwnd +
         web100_log_entry.snap.SndLimTimeSnd) >= 9000000
    AND (web100_log_entry.snap.SndLimTimeRwin +
         web100_log_entry.snap.SndLimTimeCwnd +
         web100_log_entry.snap.SndLimTimeSnd) < 3600000000
    AND web100_log_entry.snap.MinRTT < 1e7
    AND 8*web100_log_entry.snap.HCThruOctetsAcked/(
                     web100_log_entry.snap.SndLimTimeRwin +
                     web100_log_entry.snap.SndLimTimeCwnd +
                     web100_log_entry.snap.SndLimTimeSnd) < RATE
    -- restrict to NY lga01 servers, and given ISP address ranges.
    AND web100_log_entry.connection_spec.local_ip IN(SERVERIPS)
    AND ( include(ISP_FILTER_FILENAME) )
GROUP BY 
    ts
ORDER BY 
    ts;

