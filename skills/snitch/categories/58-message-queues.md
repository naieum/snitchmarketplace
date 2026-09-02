## CATEGORY 58: Message Queue Security
> Type: posture · Groups: — · CWE: CWE-284

### Detection
- Message broker client imports: `kafkajs`, `kafka-node`, `amqplib`, `amqp-connection-manager`, `bullmq`, `bull`, `bee-queue`, `nats`, `@aws-sdk/client-sqs`, `@aws-sdk/client-sns`, `boto3` (SQS/SNS), `pika` (Python RabbitMQ), `confluent-kafka`, `sarama` (Go Kafka), `go-amqp`, `spring-kafka`, `spring-amqp`, `ioredis` (Pub/Sub)
- Queue/topic producer and consumer definitions
- Message broker connection configuration files
- Dead letter queue and retry policy configuration

### What to Search For

**Queue Connections Without TLS:**
- Kafka `brokers` configuration using plaintext ports (9092) instead of SSL ports (9093)
- KafkaJS with no `ssl: true` or missing SSL certificate configuration
- RabbitMQ connection strings using `amqp://` instead of `amqps://`
- NATS connections using `nats://` instead of `tls://` or without TLS options
- Redis Pub/Sub connections without `tls: {}` option
- Go `sarama.Config` without `Net.TLS.Enable = true`
- Spring Kafka without `spring.kafka.ssl.*` properties

**Default/Weak Credentials for Message Brokers:**
- RabbitMQ connections using `guest:guest` credentials
- Kafka with no SASL authentication configured
- Default credentials in broker connection strings (admin/admin, rabbit/rabbit)
- Credentials hardcoded in source files rather than environment variables
- NATS connections without authentication tokens or user credentials
- Redis Pub/Sub without `password` or `AUTH` configuration

**Missing Message Encryption at Rest:**
- AWS SQS queues created without `KmsMasterKeyId` or SSE configuration
- SNS topics without `KmsMasterKeyId` encryption
- Kafka topics without encryption-at-rest configuration
- RabbitMQ without disk encryption or message-level encryption
- Sensitive data (PII, credentials, payment info) sent as plaintext message payloads

**No Dead Letter Queue Configuration:**
- SQS queues without `RedrivePolicy` (no DLQ) — availability posture; caps at Medium
- BullMQ jobs without `attempts` and `backoff` configuration and no failed job handling
- RabbitMQ queues without `x-dead-letter-exchange` argument
- Kafka consumers without error topic or DLQ pattern for failed messages
- Spring Kafka without `DeadLetterPublishingRecoverer` or error handling configuration
- No alerting or monitoring on dead letter queues

**Unbounded Queue Consumers (No Backpressure):**
- Kafka consumers with no `maxBytesPerPartition` or `maxWaitTimeInMs` limits
- BullMQ workers with no `concurrency` limit or `limiter` configuration
- RabbitMQ consumers with no `prefetch` count (`channel.prefetch(...)`)
- SQS consumers polling with `MaxNumberOfMessages: 10` but no concurrency limit on processing
- NATS subscriptions without `maxMsgs` or pending message limits
- Go consumers processing messages in unbounded goroutine spawning

**Missing Message Validation on Consumer Side:**
- Consumer handlers that deserialize and process messages without schema validation
- No JSON schema, Avro, or Protobuf schema validation on incoming messages
- Missing type checking or field validation after `JSON.parse(message.value)`
- Consumer trusting message content for file paths, URLs, SQL, or shell commands
- No message format versioning or backwards-compatible deserialization

**Topic/Queue ACLs Too Permissive:**
- Kafka ACLs granting `*` (all operations) to broad principal groups
- RabbitMQ vhost permissions with `.* .* .*` (full access to all resources)
- AWS SQS/SNS IAM policies with `sqs:*` or `sns:*` actions
- NATS without subject-level authorization rules
- Any user/service able to publish to or consume from any topic/queue

**No Message TTL:**
- SQS queues without `MessageRetentionPeriod` or set to maximum (14 days) without reason
- RabbitMQ queues without `x-message-ttl` argument
- BullMQ jobs without `removeOnComplete` or `removeOnFail` TTL configuration
- Kafka topics with infinite retention (`retention.ms: -1`) storing sensitive data
- No cleanup policy for processed or stale messages

### Actually Vulnerable
- KafkaJS configuration with `brokers: ['kafka:9092']` and no `ssl` or `sasl` options -- plaintext connection with no authentication
- RabbitMQ connection: `amqp://guest:guest@rabbitmq:5672` -- default credentials over unencrypted connection
- Consumer handler: `const data = JSON.parse(msg.content); exec(data.command)` -- arbitrary command execution from queue message
- Kafka ACL granting `Allow` on `Topic:*` to `User:*` -- any authenticated user can read/write all topics
- BullMQ worker with no `concurrency` limit on a queue an unauthenticated endpoint can enqueue to -- attacker-controlled resource exhaustion
- SNS topic without `KmsMasterKeyId` publishing PII in plaintext -- data at rest not encrypted
- RabbitMQ consumer with no `prefetch` count -- broker can flood consumer, causing OOM

### NOT Vulnerable
- KafkaJS with `ssl: true` and `sasl: { mechanism: 'scram-sha-256', username: process.env.KAFKA_USER, password: process.env.KAFKA_PASS }`
- RabbitMQ with `amqps://` connection, credentials from vault/secret manager, and `prefetch(10)`
- SQS queue with `KmsMasterKeyId`, `RedrivePolicy` pointing to DLQ, and `MessageRetentionPeriod` set appropriately
- Consumer that validates messages against Avro/Protobuf schema before processing
- Kafka ACLs with per-topic, per-service-account granular permissions
- BullMQ with `concurrency: 5`, `limiter: { max: 100, duration: 60000 }`, and `removeOnComplete: { age: 3600 }`
- Local development message brokers without TLS (explicitly for local dev)
- Queues within the same VPC with network-level isolation and security groups

### Context Check
1. Are broker connections using TLS/SSL in production?
2. Are broker credentials sourced from environment variables or a secret manager (not hardcoded)?
3. Are dead letter queues configured for handling failed messages?
4. Is there backpressure/concurrency control on consumers (prefetch, concurrency limits)?
5. Are incoming messages validated against a schema before processing?
6. Are topic/queue ACLs following least-privilege principles?
7. Is message TTL and retention configured appropriately for the data sensitivity?

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Confirmed broker connection uses plaintext protocol (not TLS/SSL) in production
2. [ ] Verified credentials are default or hardcoded (not from environment variables or secrets manager)
3. [ ] Checked for dead letter queue configuration (RedrivePolicy for SQS, x-dead-letter-exchange for RabbitMQ)
4. [ ] Verified consumers validate incoming messages against a schema before processing
5. [ ] Checked for backpressure/concurrency control (prefetch count, concurrency limits)
6. [ ] Confirmed sensitive data in message payloads is encrypted at rest
7. [ ] Verified this is a production broker (not a local development docker-compose service)

### Confidence Scoring
- **HIGH**: Broker connection uses plaintext protocol with default credentials (`guest:guest`, no SASL). Or consumer processes message content directly in shell commands or SQL queries. Or a consumer that fails open — an error path that acknowledges and drops a message it never authorized or validated.
- **MEDIUM**: Broker uses TLS but credentials are hardcoded in source. Or a missing DLQ / retry policy, which is availability posture and caps here — a silently dropped message is a reliability defect, not attacker impact. Or consumers lack schema validation but the message payloads are simple and from trusted producers.
- **LOW**: Broker connection lacks TLS but runs within the same VPC with network-level isolation. Or message broker is local development only (docker-compose). Or ACLs are broad but the cluster is internal.
- **SKIP**: Broker with TLS, SASL authentication from secrets manager, DLQ configured, consumers validating messages against Avro/Protobuf schemas, per-topic ACLs, and appropriate message TTLs.

### Files to Check
- `**/queue/**`, `**/jobs/**`, `**/workers/**`, `**/consumers/**`, `**/producers/**`
- `**/kafka/**`, `**/rabbitmq/**`, `**/sqs/**`, `**/sns/**`, `**/nats/**`
- `**/bull*.ts`, `**/bull*.js`, `**/processor*.ts`
- `docker-compose.yml`, `docker-compose.yaml` (broker service definitions)
- `**/config/queue*`, `**/config/broker*`, `**/config/messaging*`
- Terraform/CloudFormation files defining SQS, SNS, or MSK resources
- `application.yml`, `application.properties` (Spring Kafka/AMQP configuration)
