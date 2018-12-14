package cmd

import (
	"log"
	"net"

	"github.com/spf13/cobra"

	pb "github.com/thpham/magics/apps/proto"

	"golang.org/x/net/context"
	"google.golang.org/grpc"
)

const (
	port = ":50051"
)

// server is used to implement helloworld.GreeterServer.
type Server struct{}

// Greet implements helloworld.GreeterServer
func (s *Server) Greet(ctx context.Context, in *pb.GreetRequest) (*pb.GreetReply, error) {
	return &pb.GreetReply{Reply: "Hello " + in.Greeting}, nil
}

// serveCmd represents the serve command
var serveCmd = &cobra.Command{
	Use:   "serve",
	Short: "start the grpc server",

	Run: func(cmd *cobra.Command, args []string) {

		lis, err := net.Listen("tcp", port)
		if err != nil {
			log.Fatalf("failed to listen: %v", err)
		}
		s := grpc.NewServer()
		log.Printf("start gRPC server on port %s", port)
		pb.RegisterGreeterServer(s, &Server{})
		s.Serve(lis)

	},
}

func init() {
	RootCmd.AddCommand(serveCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// serveCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// serveCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
