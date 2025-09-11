# Nats Provider

This repository is a [NATS](https://nats.io/) provider in the [Transferia](https://github.com/transferia/transferia) ecosystem.

## Overview

A provider implementation (source as of now) that handles reading messages from NATS jetstreams and creating change items from it. It's designed to be integrated into the Transferia ecosystem as a new data processing provider.

**Prerequisites:**

- Go 1.24 or higher
- Docker or equivalent setup (for running tests with testcontainers)
- Make

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/Altinity/transferia-entrypoint-nats.git
cd transferia-entrypoint-nats
```

2. Install dependencies:
```bash
go mod download
```

3. Build the project:
```bash
make build
```

4. Use the binary:
Binary is saved in the ``binaries`` directory. Provide a transfer.yaml file with the configuration and use the binary.
Sample usage:
```bash
./binaries/trcli replicate --transfer=<path to your yaml file>
```

A sample yaml file with all configurations would be as follows:
```yaml
id: test
type: INCREMENT_ONLY
src:
  type: "nats"
  params:
    Config:
      Connection:
        NatsConnectionOptions:
          URL: "nats://localhost:4222"
          MaxReconnect: 10
      StreamIngestionConfigs:
        - Stream: "events_stream"
          SubjectIngestionConfigs:
            - TableName: "events_table"
              ConsumerConfig:
                Durable_Name: "events_consumer"
                Name: "events_consumer"
                Deliver_Policy: 0
                Ack_Policy: 1
                Filter_Subject: "events.*"
                Max_Batch: 100
              ParserConfig:
                "json.lb":
                  AddRest: false
                  AddSystemCols: false
                  DropUnparsed: false
                  Fields:
                    - Name: "cluster_id"
                      Type: "string"
                    - Name: "cluster_name"
                      Type: "string"
                    - Name: "host"
                      Type: "string"
                    - Name: "database"
                      Type: "string"
                    - Name: "pid"
                      Type: "uint32"
                    - Name: "version"
                      Type: "uint64"
dst:
  type: ch
  params:
    ShardsList:
      - Hosts:
          - "localhost"
    HTTPPort: 8123
    NativePort: 9000
    Database: "transfer_demo"
    User: "default"
    Password: ""

```

## Project Structure

- `cmd/` - Main application entry points, it's custom main file same as in transfer, but with extra plugin
- `binaries/` - Compiled binaries
- `doc/` - Documentation, including design documents

## Key Features
- **Batch Fetch** Consumers should be able to fetch messages in batches to improve throughput.
- **Support for multiple Acknowledgement modes** Once messages are consumed, they can be acknowledged cumulatively, individually or acknowledgement can be skipped all together. This should be driven by the consumer configuration.
- **Independent Ingestion per Consumer:**  Each consumer operates autonomously, maximizing throughput and ensuring a clear separation of responsibilities. In this approach, every group of subjects is assigned to its own consumer, so that the entire lifecycle—from message consumption and parsing, to pushing to the sink and acknowledgment—is handled independently without interference from other consumers.
- **Graceful Shutdown And Error Handling:** The source implementation should be able to handle errors gracefully and shutdowns should not leave streams and consumers in an inconsistent state.
- **Use of existing constructs in Transferia repository:** The implementation should not go about reinventing the wheel and should use existing constructs like waitable parse queues, parsers etc.. for implementation.
- **At least once semantics:** This implementation currently provides atleast once semantics.

## Assumptions
-  **Subject to Table Mapping:** A group of nats subjects, within a stream map to a single table. This approach helps reduce metadata overhead, simplifies management, and enables cross-subject analytics.
- **JetStreams are pre created and not the responsibility of the framework:**  It is assumed that there is a pre existing stream with one or more subjects through which the messages are to be consumerd by NATS Jetstream source.
- **[Consumer](https://docs.nats.io/nats-concepts/jetstream/consumers) Creation and Upsertion:** A consumer is created with filtered subjects on a stream. This behavior is driven by the configuration provided during connector startup.
- **Usage of [Simplified Jetstream Api](https://natsbyexample.com/examples/jetstream/api-migration/go):**
  This pr is based on the simplified jetstream API. The new JetStream API provides simplified semantics for JetStream asset management and message consumption. It removes the complexity of Subscribe() in favor of more explicit separation of creating consumers and consuming messages.

## Motivation
Modern distributed systems are increasingly adopting NATS Jetstream as their preferred messaging solution due to its:
- **Scalability & Performance:** NATS Jetstream offers low latency and high throughput, ideal for handling high-volume, real-time data.
- **Reliability:** Its built-in at-least-once delivery and durable message storage ensure high reliability and fault tolerance.
- **Widespread Adoption:** As more systems embrace NATS Jetstream for distributed messaging, integrating it into Transferia positions the platform to meet contemporary architectural demands and attract a broader user base.
