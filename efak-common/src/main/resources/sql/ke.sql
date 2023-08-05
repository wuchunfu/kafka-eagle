-- Active: 1683968819703@@127.0.0.1@3306@ke

-- Cluster: 1683968819703@@
CREATE TABLE IF NOT EXISTS ke_clusters(
    id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT 'Primary Key',
    cluster_id VARCHAR(8) NOT NULL COMMENT 'Cluster ID',
    name VARCHAR(128) NOT NULL COMMENT 'Cluster Name',
    status INT NOT NULL COMMENT '2:unknown,1:Normal,0:Error',
    nodes INT NOT NULL COMMENT 'Cluster Nodes',
    modify_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update Time',
    auth CHAR(1) NOT NULL COMMENT 'Y,N',
    auth_config TEXT NOT NULL COMMENT 'Auth Information',
    INDEX idx_name (name)
) COMMENT 'Cluster Manage' CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Broker: 1683968819703@@
CREATE TABLE IF NOT EXISTS ke_brokers(
    id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT 'Primary Key',
    cluster_id VARCHAR(8) NOT NULL COMMENT 'Cluster ID',
    broker_id VARCHAR(128) NOT NULL COMMENT 'Broker ID',
    broker_host VARCHAR(128) NOT NULL COMMENT 'Broker Host',
    broker_port INT NOT NULL COMMENT 'Broker Port',
    broker_port_status SMALLINT NOT NULL COMMENT 'Broker JMX Port Status: 0-Not Available, 1-Available',
    broker_jmx_port INT NOT NULL COMMENT 'Broker JMX Port',
    broker_jmx_port_status SMALLINT NOT NULL COMMENT 'Broker JMX Port Status: 0-Not Available, 1-Available',
    broker_memory_used_rate DOUBLE NOT NULL COMMENT 'Broker Memory Used Rate',
    broker_cpu_used_rate DOUBLE NOT NULL COMMENT 'Broker CPU Used Rate',
    broker_startup_time DATETIME NOT NULL COMMENT 'Broker Startup Time',
    modify_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update Time',
    broker_version VARCHAR(128) NOT NULL COMMENT 'Broker Version',
    INDEX idx_cluster_id (cluster_id),
    INDEX idx_broker_id (broker_id),
    INDEX idx_broker_host (broker_host),
    INDEX idx_clusterid_brokerhost (cluster_id,broker_host),
    INDEX idx_clusterid_brokerid (cluster_id,broker_id),
    INDEX idx_clusterid_brokerid_brokerhost (cluster_id,broker_id,broker_host)
) COMMENT 'Broker Info' CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS ke_clusters_create(
    id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT 'Primary Key ClusterId',
    cluster_id VARCHAR(8) NOT NULL COMMENT 'Cluster ID',
    broker_id VARCHAR(128) NOT NULL COMMENT 'Broker ID',
    broker_host VARCHAR(128) NOT NULL COMMENT 'Broker Host',
    broker_port INT NOT NULL COMMENT 'Broker Port',
    broker_jmx_port INT NOT NULL COMMENT 'Broker JMX Port',
    modify_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update Time',
    INDEX idx_cluster_id (cluster_id)
) COMMENT 'Cluster Create Info' CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS ke_topics(
    id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT 'Primary Key ClusterId',
    cluster_id VARCHAR(8) NOT NULL COMMENT 'Cluster ID',
    topic_name VARCHAR(128) NOT NULL COMMENT 'Topic Name',
    partitions INT COMMENT 'Partitions',
    replications INT COMMENT 'Replications',
    broker_spread INT COMMENT 'Broker Spread',
    broker_skewed INT COMMENT 'Broker Skewed',
    broker_leader_skewed INT COMMENT 'Broker Spread',
    retain_ms BIGINT COMMENT 'Retain Ms',
    modify_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update Time',
    INDEX idx_cluster_id (cluster_id),
    INDEX idx_cluster_topic_id (cluster_id,topic_name)
) COMMENT 'Topic Collect Info' CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS persistent_logins(
    username varchar(64) NOT NULL COMMENT 'Username',
    series varchar(64) NOT NULL COMMENT 'Series',
    token varchar(64) NOT NULL COMMENT  'Token',
    last_used timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last Used',
    PRIMARY KEY (`series`)
) COMMENT 'persistent logins' CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS ke_users_info (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT 'UserId',
  username varchar(20) DEFAULT NULL COMMENT 'UserName',
  password varchar(100) DEFAULT NULL COMMENT 'Password',
  roles varchar(50) DEFAULT NULL COMMENT 'Roles',
  INDEX idx_username (username),
  INDEX idx_user_pwd (username,password)
) COMMENT 'User info' CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS ke_topics_summary(
    id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT 'Primary Key ClusterId',
    cluster_id VARCHAR(8) NOT NULL COMMENT 'Cluster ID',
    topic_name VARCHAR(128) NOT NULL COMMENT 'Topic Name',
    log_size BIGINT COMMENT 'Topic Logsize',
    log_size_diff_val BIGINT COMMENT 'Topic Logsize Diff Value',
    timespan BIGINT COMMENT 'Collect Timespan',
    day VARCHAR(8) COMMENT 'Topic Day',
    modify_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update Time',
    INDEX idx_cluster_id (cluster_id),
    INDEX idx_cluster_topic_id (cluster_id,topic_name),
    INDEX idx_cluster_topic_id_day (cluster_id,topic_name,day),
    INDEX idx_cluster_topic_id_day_timespan (cluster_id,topic_name,day,timespan),
    INDEX idx_cluster_topic_id_timespan (cluster_id,topic_name,timespan)
) COMMENT 'Topic Summary Collect Info' CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS ke_users_audit_log (
  id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT 'UserId',
  host varchar(128) DEFAULT NULL COMMENT 'Remote Host',
  uri varchar(256) DEFAULT NULL COMMENT 'Request Uri',
  params TEXT DEFAULT NULL COMMENT 'Request Params',
  method varchar(32) DEFAULT NULL COMMENT 'Request Method',
  spent_time BIGINT DEFAULT NULL COMMENT 'Request Spent Time',
  code INT DEFAULT NULL COMMENT 'Request Code',
  modify_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update Time',
  INDEX idx_host (host)
) COMMENT 'User Audit Log' CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- quartz task table sql start
CREATE TABLE IF NOT EXISTS QRTZ_JOB_DETAILS(
  SCHED_NAME VARCHAR(120) NOT NULL,
  JOB_NAME VARCHAR(200) NOT NULL,
  JOB_GROUP VARCHAR(200) NOT NULL,
  DESCRIPTION VARCHAR(250) NULL,
  JOB_CLASS_NAME VARCHAR(250) NOT NULL,
  IS_DURABLE VARCHAR(1) NOT NULL,
  IS_NONCONCURRENT VARCHAR(1) NOT NULL,
  IS_UPDATE_DATA VARCHAR(1) NOT NULL,
  REQUESTS_RECOVERY VARCHAR(1) NOT NULL,
  JOB_DATA BLOB NULL,
  PRIMARY KEY (SCHED_NAME,JOB_NAME,JOB_GROUP),
  INDEX IDX_QRTZ_J_REQ_RECOVERY(SCHED_NAME,REQUESTS_RECOVERY),
  INDEX IDX_QRTZ_J_GRP(SCHED_NAME,JOB_GROUP)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS QRTZ_TRIGGERS (
  SCHED_NAME VARCHAR(120) NOT NULL,
  TRIGGER_NAME VARCHAR(200) NOT NULL,
  TRIGGER_GROUP VARCHAR(200) NOT NULL,
  JOB_NAME VARCHAR(200) NOT NULL,
  JOB_GROUP VARCHAR(200) NOT NULL,
  DESCRIPTION VARCHAR(250) NULL,
  NEXT_FIRE_TIME BIGINT(13) NULL,
  PREV_FIRE_TIME BIGINT(13) NULL,
  PRIORITY INTEGER NULL,
  TRIGGER_STATE VARCHAR(16) NOT NULL,
  TRIGGER_TYPE VARCHAR(8) NOT NULL,
  START_TIME BIGINT(13) NOT NULL,
  END_TIME BIGINT(13) NULL,
  CALENDAR_NAME VARCHAR(200) NULL,
  MISFIRE_INSTR SMALLINT(2) NULL,
  JOB_DATA BLOB NULL,
  PRIMARY KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
  INDEX IDX_QRTZ_T_J(SCHED_NAME,JOB_NAME,JOB_GROUP),
  INDEX IDX_QRTZ_T_JG(SCHED_NAME,JOB_GROUP),
  INDEX IDX_QRTZ_T_C(SCHED_NAME,CALENDAR_NAME),
  INDEX IDX_QRTZ_T_G(SCHED_NAME,TRIGGER_GROUP),
  INDEX IDX_QRTZ_T_STATE(SCHED_NAME,TRIGGER_STATE),
  INDEX IDX_QRTZ_T_N_STATE(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP,TRIGGER_STATE),
  INDEX IDX_QRTZ_T_N_G_STATE(SCHED_NAME,TRIGGER_GROUP,TRIGGER_STATE),
  INDEX IDX_QRTZ_T_NEXT_FIRE_TIME(SCHED_NAME,NEXT_FIRE_TIME),
  INDEX IDX_QRTZ_T_NFT_ST(SCHED_NAME,TRIGGER_STATE,NEXT_FIRE_TIME),
  INDEX IDX_QRTZ_T_NFT_MISFIRE(SCHED_NAME,MISFIRE_INSTR,NEXT_FIRE_TIME),
  INDEX IDX_QRTZ_T_NFT_ST_MISFIRE(SCHED_NAME,MISFIRE_INSTR,NEXT_FIRE_TIME,TRIGGER_STATE),
  INDEX IDX_QRTZ_T_NFT_ST_MISFIRE_GRP(SCHED_NAME,MISFIRE_INSTR,NEXT_FIRE_TIME,TRIGGER_GROUP,TRIGGER_STATE),
  FOREIGN KEY (SCHED_NAME,JOB_NAME,JOB_GROUP)
  REFERENCES QRTZ_JOB_DETAILS(SCHED_NAME,JOB_NAME,JOB_GROUP)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS QRTZ_SIMPLE_TRIGGERS (
  SCHED_NAME VARCHAR(120) NOT NULL,
  TRIGGER_NAME VARCHAR(200) NOT NULL,
  TRIGGER_GROUP VARCHAR(200) NOT NULL,
  REPEAT_COUNT BIGINT(7) NOT NULL,
  REPEAT_INTERVAL BIGINT(12) NOT NULL,
  TIMES_TRIGGERED BIGINT(10) NOT NULL,
  PRIMARY KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
  FOREIGN KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
  REFERENCES QRTZ_TRIGGERS(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP))
  ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS QRTZ_CRON_TRIGGERS (
  SCHED_NAME VARCHAR(120) NOT NULL,
  TRIGGER_NAME VARCHAR(200) NOT NULL,
  TRIGGER_GROUP VARCHAR(200) NOT NULL,
  CRON_EXPRESSION VARCHAR(120) NOT NULL,
  TIME_ZONE_ID VARCHAR(80),
  PRIMARY KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
  FOREIGN KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
  REFERENCES QRTZ_TRIGGERS(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP))
  ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS QRTZ_SIMPROP_TRIGGERS
(
  SCHED_NAME VARCHAR(120) NOT NULL,
  TRIGGER_NAME VARCHAR(200) NOT NULL,
  TRIGGER_GROUP VARCHAR(200) NOT NULL,
  STR_PROP_1 VARCHAR(512) NULL,
  STR_PROP_2 VARCHAR(512) NULL,
  STR_PROP_3 VARCHAR(512) NULL,
  INT_PROP_1 INT NULL,
  INT_PROP_2 INT NULL,
  LONG_PROP_1 BIGINT NULL,
  LONG_PROP_2 BIGINT NULL,
  DEC_PROP_1 NUMERIC(13,4) NULL,
  DEC_PROP_2 NUMERIC(13,4) NULL,
  BOOL_PROP_1 VARCHAR(1) NULL,
  BOOL_PROP_2 VARCHAR(1) NULL,
  PRIMARY KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
  FOREIGN KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
  REFERENCES QRTZ_TRIGGERS(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP))
  ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS QRTZ_BLOB_TRIGGERS (
  SCHED_NAME VARCHAR(120) NOT NULL,
  TRIGGER_NAME VARCHAR(200) NOT NULL,
  TRIGGER_GROUP VARCHAR(200) NOT NULL,
  BLOB_DATA BLOB NULL,
  PRIMARY KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
  INDEX (SCHED_NAME,TRIGGER_NAME, TRIGGER_GROUP),
  FOREIGN KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
  REFERENCES QRTZ_TRIGGERS(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP))
  ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS QRTZ_CALENDARS (
  SCHED_NAME VARCHAR(120) NOT NULL,
  CALENDAR_NAME VARCHAR(200) NOT NULL,
  CALENDAR BLOB NOT NULL,
  PRIMARY KEY (SCHED_NAME,CALENDAR_NAME))
  ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS QRTZ_PAUSED_TRIGGER_GRPS (
  SCHED_NAME VARCHAR(120) NOT NULL,
  TRIGGER_GROUP VARCHAR(200) NOT NULL,
  PRIMARY KEY (SCHED_NAME,TRIGGER_GROUP))
  ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS QRTZ_FIRED_TRIGGERS (
  SCHED_NAME VARCHAR(120) NOT NULL,
  ENTRY_ID VARCHAR(95) NOT NULL,
  TRIGGER_NAME VARCHAR(200) NOT NULL,
  TRIGGER_GROUP VARCHAR(200) NOT NULL,
  INSTANCE_NAME VARCHAR(200) NOT NULL,
  FIRED_TIME BIGINT(13) NOT NULL,
  SCHED_TIME BIGINT(13) NOT NULL,
  PRIORITY INTEGER NOT NULL,
  STATE VARCHAR(16) NOT NULL,
  JOB_NAME VARCHAR(200) NULL,
  JOB_GROUP VARCHAR(200) NULL,
  IS_NONCONCURRENT VARCHAR(1) NULL,
  REQUESTS_RECOVERY VARCHAR(1) NULL,
  PRIMARY KEY (SCHED_NAME,ENTRY_ID),
  INDEX IDX_QRTZ_FT_TRIG_INST_NAME(SCHED_NAME,INSTANCE_NAME),
  INDEX IDX_QRTZ_FT_INST_JOB_REQ_RCVRY(SCHED_NAME,INSTANCE_NAME,REQUESTS_RECOVERY),
  INDEX IDX_QRTZ_FT_J_G(SCHED_NAME,JOB_NAME,JOB_GROUP),
  INDEX IDX_QRTZ_FT_JG(SCHED_NAME,JOB_GROUP),
  INDEX IDX_QRTZ_FT_T_G(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
  INDEX IDX_QRTZ_FT_TG(SCHED_NAME,TRIGGER_GROUP)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS QRTZ_SCHEDULER_STATE (
  SCHED_NAME VARCHAR(120) NOT NULL,
  INSTANCE_NAME VARCHAR(200) NOT NULL,
  LAST_CHECKIN_TIME BIGINT(13) NOT NULL,
  CHECKIN_INTERVAL BIGINT(13) NOT NULL,
  PRIMARY KEY (SCHED_NAME,INSTANCE_NAME))
  ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS QRTZ_LOCKS (
  SCHED_NAME VARCHAR(120) NOT NULL,
  LOCK_NAME VARCHAR(40) NOT NULL,
  PRIMARY KEY (SCHED_NAME,LOCK_NAME))
  ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS QRTZ_TASK_HISTORY (
  SCHED_NAME VARCHAR(120) NOT NULL,
  INSTANCE_ID VARCHAR(200) NOT NULL,
  FIRE_ID VARCHAR(95) NOT NULL,
  TASK_NAME VARCHAR(200) NULL,
  TASK_GROUP VARCHAR(200) NULL,
  FIRED_TIME BIGINT(13) NULL,
  FIRED_WAY VARCHAR(8) NULL,
  COMPLETE_TIME BIGINT(13) NULL,
  EXPEND_TIME BIGINT(13) NULL,
  REFIRED INT NULL,
  EXEC_STATE VARCHAR(10) NULL,
  LOG TEXT NULL,
  PRIMARY KEY (FIRE_ID),
  INDEX IDX_QRTZ_TK_S(SCHED_NAME)
)ENGINE=InnoDB;

-- quartz end

CREATE TABLE IF NOT EXISTS ke_consumer_group(
    id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT 'Primary Key ClusterId',
    cluster_id VARCHAR(8) NOT NULL COMMENT 'Cluster ID',
    group_id VARCHAR(128) COMMENT 'Group Name',
    topic_name VARCHAR(128) COMMENT 'Topic Name',
    coordinator VARCHAR(128) COMMENT 'Coordinator',
    state VARCHAR(32) COMMENT 'State',
    status SMALLINT COMMENT 'running(0), shutdown(1), pending(2)',
    modify_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update Time',
    INDEX idx_cluster_id (cluster_id),
    INDEX idx_cluster_group_id (cluster_id,group_id),
    INDEX idx_cluster_group_topic (cluster_id,group_id,topic_name)
) COMMENT 'Consumer Group Summary Collect Info' CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS ke_consumer_group_topic(
    id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT 'Primary Key ClusterId',
    cluster_id VARCHAR(8) NOT NULL COMMENT 'Cluster ID',
    group_id VARCHAR(128) COMMENT 'Group Name',
    topic_name VARCHAR(128) COMMENT 'Topic Name',
    logsize BIGINT COMMENT 'Log Size',
    logsize_diff BIGINT COMMENT 'Log Size Diff',
    offsets BIGINT COMMENT 'Offset',
    offsets_diff BIGINT COMMENT 'Offset Diff',
    lags BIGINT COMMENT 'Lag',
    day VARCHAR(8) COMMENT 'Topic Day',
    timespan BIGINT COMMENT 'Collect Timespan',
    modify_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update Time',
    INDEX idx_cluster_id (cluster_id),
    INDEX idx_cluster_group_id (cluster_id,group_id),
    INDEX idx_cluster_group_topic (cluster_id,group_id,topic_name),
    INDEX idx_cluster_group_topic_day (cluster_id,group_id,topic_name,day),
    INDEX idx_cluster_group_topic_day_timespan (cluster_id,group_id,topic_name,day,timespan)
) COMMENT 'Consumer Group Topic Lag Collect Info' CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS ke_kafka_mbean_metrics(
    id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT 'Primary Key ClusterId',
    cluster_id VARCHAR(8) NOT NULL COMMENT 'Cluster ID',
    mbean_key VARCHAR(128) COMMENT 'MBean key',
    mbean_value VARCHAR(128) COMMENT 'MBean value',
    day VARCHAR(8) COMMENT 'Metrics Day',
    timespan BIGINT COMMENT 'Collect Timespan',
    modify_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update Time',
    INDEX idx_cluster_id (cluster_id),
    INDEX idx_cluster_key (cluster_id,mbean_key),
    INDEX idx_cluster_key_day (cluster_id,mbean_key,day),
    INDEX idx_cluster_key_day_timespan (cluster_id,mbean_key,day,timespan)
) COMMENT 'Kafka MBean Collect Info' CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;