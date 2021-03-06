package cmd

import (
	"github.com/spf13/cobra"
)

// ============================================================================
//  `hello` command
// ============================================================================

// helloCmd is the actual `hello` command, generated by `createHelloCmd()`.
// Defined since `hello` has a child command `ext` and needs to be added later.
// See the `init()` of `ext` command ("helloExtended.go").
var helloCmd = createHelloCmd()

// ----------------------------------------------------------------------------
//  Functions of `root` command
// ----------------------------------------------------------------------------

// createHelloCmd creates/generates an instance of hello command.
// Having a generator function like this, eases unit testing of a command.
// See the "hello_test.go" how.
func createHelloCmd() *cobra.Command {
	cmd := &cobra.Command{
		// If the command is a child, "Use" will be the one-line message for
		// "Usage:" in the help. Also note that the first word in "Use" will be
		// the command name.
		Use:   "hello",
		Short: "Says hello to the world. (Has a sub command)",
		Long: `About:
  'hello' is a command that simply displays the "Hello, world!".

  But this command has a sub command 'ext' that extends it's output in various ways.
  See the help of 'ext' for the details:
    Hello-Cobra hello ext --help`,
		Example: `
  Hello-Cobra hello

  Hello-Cobra hello -h
  Hello-Cobra hello --help

  Hello-Cobra hello ext`,
		// RunE runs the passed function, only when `hello` command was called.
		// One of the best practices in Cobra is to use `RunE`. Instead of `Run`
		// and return `error` only if an error occurs. That will ease testing.
		// In that manner try not to use `os.Exit()` or `panic()` in the child
		// commands but return error instead and let the main package handle it.
		RunE: func(cmd *cobra.Command, args []string) error {
			return sayHello(cmd)
		},
	}

	return cmd
}

// init runs on app initialization.
// Regardless of whether sub command was specified or not.
func init() {
	// Add "helloCmd" command as a child of the root command(`rootCmd`).
	rootCmd.AddCommand(helloCmd)
	// Set default value when no conf file found. ConfUser was defined in `root.go`.
	ConfUser.NameToGreet = "world"
}

// sayHello is the main function of "hello"(helloCmd).
func sayHello(cmd *cobra.Command) error {
	var to string = ConfUser.NameToGreet

	// Outputs "Hello, world!".
	// We use `cobra.Command`'s `fmt.Println` wrapper to ease testing.
	// Which can be changed it's output. See how: hello_test.sh
	cmd.Println("Hello, " + to + "!")

	return nil
}
