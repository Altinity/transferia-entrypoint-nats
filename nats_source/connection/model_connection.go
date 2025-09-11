package connection

// ConnectionConfig holds the details required to connect to a NATS server.
type ConnectionConfig struct {
	NatsConnectionOptions *NatsConnectionOptions
}

type NatsConnectionOptions struct {
	URL          string
	MaxReconnect int
}
