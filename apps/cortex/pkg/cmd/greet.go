package cmd

import (
	"log"
	"strings"

	"golang.org/x/net/context"
	"google.golang.org/grpc"

	pb "github.com/thpham/magics/apps/proto"

	"github.com/spf13/cobra"
)

const (
	address     = "localhost:50051"
	defaultName = "world"
)

// greetCmd represents the greet command
var greetCmd = &cobra.Command{
	Use:   "greet",
	Short: "send the arguments in grpc call and print the reply",
	Args:  cobra.MinimumNArgs(1),
	Run: func(cmd *cobra.Command, args []string) {

		// Set up a connection to the server.
		conn, err := grpc.Dial(address, grpc.WithInsecure())
		if err != nil {
			log.Fatalf("did not connect: %v", err)
		}
		defer conn.Close()
		c := pb.NewGreeterClient(conn)

		// Contact the server and print out its response.
		name := defaultName
		if len(args) > 0 {
			name = strings.Join(args, " ")
		}
		r, err := c.Greet(context.Background(), &pb.GreetRequest{Greeting: name})
		if err != nil {
			log.Fatalf("could not greet: %v", err)
		}
		log.Printf("Greeting: %s", r.Reply)

	},
}

func init() {
	RootCmd.AddCommand(greetCmd)
}
