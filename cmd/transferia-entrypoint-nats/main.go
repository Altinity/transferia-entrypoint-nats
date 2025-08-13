package main

import (
  "context"
  "github.com/Altinity/transferia-entrypoint-nats"
)

func main() {
  transferiaentrypointnats.Run(context.Background())
}
