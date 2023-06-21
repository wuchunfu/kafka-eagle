/**
 * KafkaSchemaFactory.java
 * <p>
 * Copyright 2023 smartloli
 * <p>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.kafka.eagle.core.kafka;

import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.admin.AdminClient;
import org.apache.kafka.clients.admin.DescribeTopicsResult;
import org.apache.kafka.clients.admin.NewTopic;
import org.apache.kafka.clients.admin.TopicDescription;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.Node;
import org.apache.kafka.common.TopicPartitionInfo;
import org.apache.kafka.common.config.TopicConfig;
import org.kafka.eagle.pojo.cluster.KafkaClientInfo;
import org.kafka.eagle.pojo.topic.MetadataInfo;
import org.kafka.eagle.pojo.topic.NewTopicInfo;

import java.util.*;

/**
 * Get the Kafka topic metadata information through the broker address.
 *
 * @Author: smartloli
 * @Date: 2023/6/18 19:56
 * @Version: 3.4.0
 */
@Slf4j
public class KafkaSchemaFactory {
    private final KafkaStoragePlugin plugin;
    private Set<String> tableNames;

    public KafkaSchemaFactory(final KafkaStoragePlugin plugin) {
        this.plugin = plugin;
    }

    public boolean createTableName(KafkaClientInfo kafkaClientInfo, NewTopicInfo newTopicInfo) {
        boolean status = false;
        AdminClient adminClient = null;
        try {
            adminClient = AdminClient.create(plugin.getKafkaAdminClientProps(kafkaClientInfo));
            NewTopic newTopic = new NewTopic(newTopicInfo.getTopicName(), newTopicInfo.getPartitions(), newTopicInfo.getReplication());
            newTopic.configs(Collections.singletonMap(TopicConfig.RETENTION_MS_CONFIG, String.valueOf(newTopicInfo.getRetainMs())));
            adminClient.createTopics(Collections.singleton(newTopic)).all().get();
            status = true;
        } catch (Exception e) {
            status = false;
            log.error("Create kafka topic has error, new topic [{}], msg is {}", newTopicInfo, e);
        } finally {
            adminClient.close();
        }

        return status;
    }

    public Set<String> getTopicNames(KafkaClientInfo kafkaClientInfo) {
        if (tableNames == null) {
            KafkaConsumer<?, ?> kafkaConsumer = null;
            try {
                kafkaConsumer = new KafkaConsumer<>(plugin.getKafkaConsumerProps(kafkaClientInfo));
                tableNames = kafkaConsumer.listTopics().keySet();
            } catch (Exception e) {
                log.error("Failure while loading table names for database '{}': {}", kafkaClientInfo, e);
            } finally {
                plugin.registerToClose(kafkaConsumer);
            }
        }
        return tableNames;
    }

    public List<String> getTopicPartitionsOfString(KafkaClientInfo kafkaClientInfo, String topic) {
        List<String> partitions = new ArrayList<>();
        AdminClient adminClient = null;
        try {
            adminClient = AdminClient.create(plugin.getKafkaAdminClientProps(kafkaClientInfo));
            DescribeTopicsResult describeTopicsResult = adminClient.describeTopics(Arrays.asList(topic));
            for (TopicPartitionInfo tp : describeTopicsResult.all().get().get(topic).partitions()) {
                partitions.add(String.valueOf(tp.partition()));
            }
        } catch (Exception e) {
            log.error("Failure while loading topic '{}' meta for kafka '{}': {}", kafkaClientInfo, topic, e);
        } finally {
            plugin.registerToClose(adminClient);
        }
        return partitions;
    }

    public Set<Integer> getTopicPartitionsOfInt(KafkaClientInfo kafkaClientInfo, String topic) {
        Set<Integer> partitions = new HashSet<>();
        AdminClient adminClient = null;
        try {
            adminClient = AdminClient.create(plugin.getKafkaAdminClientProps(kafkaClientInfo));
            DescribeTopicsResult describeTopicsResult = adminClient.describeTopics(Arrays.asList(topic));
            for (TopicPartitionInfo tp : describeTopicsResult.all().get().get(topic).partitions()) {
                partitions.add(tp.partition());
            }
        } catch (Exception e) {
            log.error("Failure while loading topic '{}' meta for kafka '{}': {}", kafkaClientInfo, topic, e);
        } finally {
            plugin.registerToClose(adminClient);
        }
        return partitions;
    }

    public List<MetadataInfo> getTopicPartitionsLeader(KafkaClientInfo kafkaClientInfo, String topic) {
        List<MetadataInfo> partitions = new ArrayList<>();
        AdminClient adminClient = null;
        try {
            adminClient = AdminClient.create(plugin.getKafkaAdminClientProps(kafkaClientInfo));
            DescribeTopicsResult describeTopicsResult = adminClient.describeTopics(Arrays.asList(topic));
            for (TopicPartitionInfo tp : describeTopicsResult.all().get().get(topic).partitions()) {
                MetadataInfo metadata = new MetadataInfo();
                metadata.setPartitionId(tp.partition());
                metadata.setLeader(tp.leader().id());
                partitions.add(metadata);
            }
        } catch (Exception e) {
            log.error("Failure while loading topic '{}' meta for kafka '{}': {}", kafkaClientInfo, topic, e);
        } finally {
            plugin.registerToClose(adminClient);
        }
        return partitions;
    }

    public List<MetadataInfo> getTopicMetaData(KafkaClientInfo kafkaClientInfo, String topic) {
        List<MetadataInfo> partitions = new ArrayList<>();
        AdminClient adminClient = null;
        try {
            adminClient = AdminClient.create(plugin.getKafkaAdminClientProps(kafkaClientInfo));
            DescribeTopicsResult describeTopicsResult = adminClient.describeTopics(Arrays.asList(topic));
            for (TopicPartitionInfo tp : describeTopicsResult.all().get().get(topic).partitions()) {
                MetadataInfo metadata = new MetadataInfo();
                metadata.setPartitionId(tp.partition());
                metadata.setLeader(tp.leader().id());
                List<Integer> isr = new ArrayList<>();
                for (Node node : tp.isr()) {
                    isr.add(node.id());
                }
                metadata.setIsr(isr.toString());

                List<Integer> replicas = new ArrayList<>();
                for (Node node : tp.replicas()) {
                    replicas.add(node.id());
                }
                metadata.setReplicas(replicas.toString());
                partitions.add(metadata);
            }
        } catch (Exception e) {
            log.error("Failure while loading topic '{}' meta for kafka '{}': {}", kafkaClientInfo, topic, e);
        } finally {
            plugin.registerToClose(adminClient);
        }
        return partitions;
    }

    public Map<String,List<MetadataInfo>> getTopicMetaData(KafkaClientInfo kafkaClientInfo, List<String> topics) {
        Map<String,List<MetadataInfo>> topicMetas = new HashMap<>();

        AdminClient adminClient = null;
        try {
            adminClient = AdminClient.create(plugin.getKafkaAdminClientProps(kafkaClientInfo));
            DescribeTopicsResult describeTopicsResult = adminClient.describeTopics(topics);
            for (Map.Entry<String, TopicDescription> entry : describeTopicsResult.allTopicNames().get().entrySet()) {
                List<MetadataInfo> partitions = new ArrayList<>();
                for (TopicPartitionInfo tp : entry.getValue().partitions()) {
                    MetadataInfo metadata = new MetadataInfo();
                    metadata.setPartitionId(tp.partition());
                    metadata.setLeader(tp.leader().id());
                    List<Integer> isr = new ArrayList<>();
                    for (Node node : tp.isr()) {
                        isr.add(node.id());
                    }
                    metadata.setIsr(isr.toString());

                    List<Integer> replicas = new ArrayList<>();
                    for (Node node : tp.replicas()) {
                        replicas.add(node.id());
                    }
                    metadata.setReplicas(replicas.toString());
                    partitions.add(metadata);
                }
                topicMetas.put(entry.getKey(),partitions);
            }
        } catch (Exception e) {
            log.error("Failure while loading topics meta for kafka '{}': {}", kafkaClientInfo, e);
        } finally {
            plugin.registerToClose(adminClient);
        }
        return topicMetas;
    }

    public static void main(String[] args) {
        KafkaSchemaFactory ksf = new KafkaSchemaFactory(new KafkaStoragePlugin());

        KafkaClientInfo kafkaClientInfo = new KafkaClientInfo();
        kafkaClientInfo.setBrokerServer("127.0.0.1:9092");
        log.info("topic name is : {}", ksf.getTopicNames(kafkaClientInfo).toString());

        Map<String,List<MetadataInfo>> metadataInfos = ksf.getTopicMetaData(kafkaClientInfo, Arrays.asList("ke28","k30","ke_test30"));
        log.info("metadataInfos: {}", metadataInfos.toString());
    }
}
